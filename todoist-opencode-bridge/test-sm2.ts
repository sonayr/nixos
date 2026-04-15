import { SessionManager } from './src/SessionManager';

async function run() {
  const sm = new SessionManager('dummy-token');
  // Monkey-patch to avoid actual Todoist API calls
  (sm as any).postComment = async (taskId: string, content: string, asCode: boolean) => {
    console.log("WOULD POST COMMENT:", { taskId, content, asCode });
  };
  (sm as any).postErrorComment = async (taskId: string, error: string) => {
    console.error("WOULD POST ERROR:", { taskId, error });
  };

  try {
    console.log("Starting processFollowupPrompt");
    // Start a real request but capture the log output
    await sm.processFollowupPrompt('ses_26e54697dffejyxp1wR58HmH2m', 'dummy-task', 'plan', 'hi there again!');
    console.log("Done processFollowupPrompt");
  } catch (e) {
    console.error("Caught error:", e);
  }
}

run();
