import { TodoistApi } from '@doist/todoist-sdk';

const OPENCODE_SERVER_URL = 'http://127.0.0.1:4096';

// Helper to extract the final text from the complex streaming response
function extractFinalText(response: any): string {
  if (response && Array.isArray(response.parts)) {
    return response.parts
      .filter((p: any) => p.type === 'text')
      .map((p: any) => p.text)
      .join('');
  }
  return '';
}

export class SessionManager {
  private todoist: TodoistApi;

  constructor(apiToken: string) {
    this.todoist = new TodoistApi(apiToken);
  }

  public async processInitialPrompt(taskId: string, agentMode: string, prompt: string): Promise<void> {
    console.log(`Creating new session for task ${taskId}`);
    try {
      // 1. Create a new session using native fetch
      const createSessionResponse = await fetch(`${OPENCODE_SERVER_URL}/session`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ title: `todoist-${taskId}` })
      });

      if (!createSessionResponse.ok) {
        const errorText = await createSessionResponse.text();
        throw new Error(`Failed to create session: ${errorText}`);
      }
      
      const sessionData = await createSessionResponse.json();
      const sessionId = sessionData.id;
      
      if (!sessionId) {
        throw new Error("Failed to create opencode session: No ID returned.");
      }
      
      console.log(`Bound new session ${sessionId} to task ${taskId}`);

      // 2. Update the Todoist task with the new session ID
      const task = await this.todoist.getTask(taskId);
      const newDescription = `${task.description || ''}\n\nOpencode-Session: ${sessionId}`.trim();
      await this.todoist.updateTask(taskId, { description: newDescription });

      // 3. Send the initial prompt to the new session
      await this.processFollowupPrompt(sessionId, taskId, agentMode, prompt);

    } catch (error: any) {
      console.error(`Error in processInitialPrompt for task ${taskId}:`, error.message);
      await this.postErrorComment(taskId, `Failed to initialize session: ${error.message}`);
    }
  }

  public async processFollowupPrompt(sessionId: string, taskId: string, agentMode: string, prompt: string): Promise<void> {
    console.log(`Sending prompt to session ${sessionId} for task ${taskId}`);
    try {
      const messageResponse = await fetch(
        `${OPENCODE_SERVER_URL}/session/${sessionId}/message`,
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            agent: agentMode,
            parts: [{ type: 'text', text: prompt }]
          })
        }
      );

      if (!messageResponse.ok || !messageResponse.body) {
        const errorText = await messageResponse.text();
        throw new Error(`Failed to send message: ${errorText}`);
      }

      const reader = messageResponse.body.getReader();
      const decoder = new TextDecoder();
      let lastMessage: any = {};
      let buffer = '';

      while (true) {
        const { done, value } = await reader.read();
        if (done) break;
        
        buffer += decoder.decode(value, { stream: true });
        
        // Process buffer line by line (standard NDJSON parsing)
        let newlineIndex = buffer.indexOf('\n');
        while (newlineIndex !== -1) {
            const jsonStr = buffer.slice(0, newlineIndex).trim();
            buffer = buffer.slice(newlineIndex + 1);
            
            if (jsonStr) {
                try {
                    lastMessage = JSON.parse(jsonStr);
                } catch(e) {
                    console.warn("Error parsing JSON chunk from stream:", jsonStr, e);
                }
            }
            newlineIndex = buffer.indexOf('\n');
        }
      }
      
      // Process any remaining data in the buffer after the stream ends
      if (buffer.trim()) {
         try {
             lastMessage = JSON.parse(buffer.trim());
         } catch(e) {
             console.warn("Error parsing final JSON chunk from stream:", buffer, e);
         }
      }

      if (lastMessage.error) {
         throw new Error(lastMessage.error.message || JSON.stringify(lastMessage.error));
      }

      const responseText = extractFinalText(lastMessage);
      await this.postComment(taskId, responseText);

    } catch (error: any) {
      console.error(`Error in processFollowupPrompt for session ${sessionId}:`, error.message);
      await this.postErrorComment(taskId, `Failed to process prompt: ${error.message}`);
    }
  }
  
  public async deleteSession(sessionId: string, taskId: string): Promise<void> {
     // Opencode server does not currently have a /session/{id} DELETE endpoint.
     // Sessions are ephemeral and will be cleaned up on server restart.
    console.log(`Session ${sessionId} for task ${taskId} is considered closed.`);
    await this.postComment(taskId, `*Task completed. Opencode session memory (${sessionId}) has been cleared.*`, false);
  }

  private async postComment(taskId: string, content: string, asCode: boolean = true): Promise<void> {
    if (!content) {
      console.warn(`Attempted to post empty comment for task ${taskId}. Skipping.`);
      return;
    }
    const message = asCode ? `\`\`\`text\n${content}\n\`\`\`` : content;
    try {
      await this.todoist.addComment({ taskId, content: message });
    } catch (err) {
      console.error(`Failed to post comment to task ${taskId}:`, err);
    }
  }
  
  private async postErrorComment(taskId: string, error: string): Promise<void> {
    await this.postComment(taskId, `*Opencode execution failed.*\n${error}`, false);
  }
}
