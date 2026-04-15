import { SessionManager } from './src/SessionManager';

async function run() {
  const sm = new SessionManager('dummy-token');
  // Monkey-patch to avoid actual Todoist API calls
  (sm as any).postComment = async (taskId: string, content: string, asCode: boolean) => {
    console.log("SUCCESS! WOULD POST COMMENT:", { taskId, content, asCode });
  };
  (sm as any).postErrorComment = async (taskId: string, error: string) => {
    console.error("WOULD POST ERROR:", { taskId, error });
  };

  try {
    console.log("Starting processFollowupPrompt");
    // Create session to guarantee valid id
    const createRes = await fetch('http://127.0.0.1:4096/session', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ title: 'test5' })
    });
    const sessionData = await createRes.json();
    
    // Start a real request but capture the log output
    await sm.processFollowupPrompt(sessionData.id, 'dummy-task', 'plan', 'hello plan mode');
    console.log("Done processFollowupPrompt");
  } catch (e) {
    console.error("Caught error:", e);
  }
}

run();
