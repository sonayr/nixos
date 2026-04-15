import express from 'express';
import crypto from 'crypto';
import dotenv from 'dotenv';
import { TodoistApi } from '@doist/todoist-sdk';
import { SessionManager } from './SessionManager';
import { v4 as uuidv4 } from 'uuid';
import { setGlobalDispatcher, Agent } from 'undici';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import { z } from 'zod';
import { LRUCache } from 'lru-cache';

// Disable timeout for long-running opencode streams
setGlobalDispatcher(new Agent({ headersTimeout: 0, bodyTimeout: 0 }));

dotenv.config();

const PORT = process.env.PORT || 3000;
const TODOIST_CLIENT_SECRET = process.env.TODOIST_CLIENT_SECRET;
const TODOIST_API_TOKEN = process.env.TODOIST_API_TOKEN;

if (!TODOIST_CLIENT_SECRET || !TODOIST_API_TOKEN) {
  console.error("Missing TODOIST_CLIENT_SECRET or TODOIST_API_TOKEN in environment.");
  process.exit(1);
}

// Zod schema for expected webhook payload
const WebhookPayloadSchema = z.object({
  event_name: z.string(),
  event_data: z.object({
    id: z.string().optional(),
    item_id: z.string().optional(),
    labels: z.array(z.string()).optional(),
    content: z.string().optional(),
    description: z.string().optional(),
    checked: z.boolean().optional(),
  }).passthrough(), // Allow other properties we don't strictly need
}).passthrough();

// LRU Cache for replay attack prevention (1000 items, 15m TTL)
const processedWebhooksCache = new LRUCache<string, boolean>({
  max: 1000,
  ttl: 1000 * 60 * 15, // 15 minutes
});

const api = new TodoistApi(TODOIST_API_TOKEN);
const sessionManager = new SessionManager(TODOIST_API_TOKEN);

const app = express();

// Trust proxy is required because Cloudflared tunnels forward the real IP
app.set('trust proxy', 1);

// Security Headers
app.use(helmet());

// Rate limiting (100 requests per 15 minutes)
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, 
  max: 100, 
  message: 'Too many requests from this IP, please try again later.',
  standardHeaders: true, 
  legacyHeaders: false, 
});

app.use('/webhook', limiter);

// Use raw body parsing to correctly compute the HMAC signature
app.use(express.json({
  verify: (req: any, res, buf) => {
    req.rawBody = buf;
  }
}));

// Helper to extract session ID from description
const getSessionIdFromDescription = (description: string): string | null => {
  const match = description.match(/Opencode-Session:\s*(ses_[a-zA-Z0-9]+)/i);
  return match && match[1] ? match[1] : null;
};

// Helper to determine agent mode from labels
const getAgentMode = (labels: string[]): string => {
  if (labels.includes('@Build') || labels.includes('Build')) {
    return 'build';
  }
  return 'plan';
};

app.post('/webhook', async (req: any, res: any) => {
  console.log('--- NEW WEBHOOK RECEIVED ---');
  console.log('Headers:', JSON.stringify(req.headers, null, 2));

  const signature = req.headers['x-todoist-hmac-sha256'];
  if (!signature) {
    console.log('REJECTED: Missing signature');
    return res.status(401).send('Missing signature');
  }

  // Verify HMAC
  const hmac = crypto.createHmac('sha256', TODOIST_CLIENT_SECRET.trim());
  hmac.update(req.rawBody);
  const expectedSignature = hmac.digest('base64');

  const signatureBuffer = Buffer.from(signature as string);
  const expectedSignatureBuffer = Buffer.from(expectedSignature);

  if (signatureBuffer.length !== expectedSignatureBuffer.length || !crypto.timingSafeEqual(signatureBuffer, expectedSignatureBuffer)) {
    console.log(`REJECTED: Signature mismatch! Expected: ${expectedSignature}, Received: ${signature}`);
    return res.status(403).send('Invalid signature');
  }

  // Strict Payload Validation
  const validationResult = WebhookPayloadSchema.safeParse(req.body);
  if (!validationResult.success) {
    console.log(`REJECTED: Invalid payload format`, validationResult.error.format());
    return res.status(400).send('Invalid payload format');
  }

  const { event_name, event_data } = validationResult.data;

  // Replay Attack Prevention
  const eventId = event_data?.id || event_data?.item_id;
  if (eventId) {
    const cacheKey = `${event_name}:${eventId}`;
    if (processedWebhooksCache.has(cacheKey)) {
      console.log(`ACCEPTED & IGNORED: Webhook ${cacheKey} already processed recently.`);
      return res.status(200).send('Already processed');
    }
    processedWebhooksCache.set(cacheKey, true);
  }

  console.log(`ACCEPTED: Event: ${event_name}, Item ID: ${eventId}`);
  console.log(`Labels found on item: ${JSON.stringify(event_data?.labels)}`);

  try {
    const labels = event_data.labels || [];
    const hasAgentLabel = labels.includes('@agent') || labels.includes('agent');

    if (event_name === 'item:added' && hasAgentLabel && event_data.id) {
        // This is a new task, kick off the initial prompt flow
        const initialPrompt = event_data.content || 'Hello!';
        // We don't need to await this, let it run in the background
        sessionManager.processInitialPrompt(event_data.id, getAgentMode(labels), initialPrompt);

    } else if (event_name === 'item:updated' && hasAgentLabel && event_data.checked === true && event_data.id) {
        // This is a completed task, close the session
        const sessionId = getSessionIdFromDescription(event_data.description || '');
        if (sessionId) {
          console.log(`Task ${event_data.id} completed. Closing session ${sessionId}`);
          sessionManager.deleteSession(sessionId, event_data.id);
        }

    } else if (event_name === 'note:added' && event_data.item_id) {
        // This is a follow-up comment, process it
        // Check if this is an agent comment to avoid infinite loops
        const content = event_data.content || '';
        if (content.startsWith('```text') || content.includes('*Opencode session') || content.includes('*Opencode execution failed')) {
          return res.status(200).send('Ignored agent comment');
        }

        const task = await api.getTask(event_data.item_id);
        const taskLabels = task.labels || [];
        if (taskLabels.includes('@agent') || taskLabels.includes('agent')) {
            const sessionId = getSessionIdFromDescription(task.description);
            if (sessionId) {
              const agentMode = getAgentMode(taskLabels);
              console.log(`Forwarding comment to session ${sessionId} (Task ${task.id})`);
              sessionManager.processFollowupPrompt(sessionId, task.id, agentMode, content);
            } else {
              console.log(`Ignoring comment for task ${task.id} as no session ID was found yet.`);
            }
        }
    }

    res.status(200).send('OK');
  } catch (error) {
    console.error('Error handling webhook:', error);
    res.status(500).send('Internal Server Error');
  }
});

app.listen(PORT, () => {
  console.log(`Todoist Webhook Server listening on port ${PORT}`);
});
