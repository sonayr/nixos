# Opencode Repo Workflow Rules

Whenever you make any modifications to the files in this NixOS configuration repository, you MUST strictly follow these post-edit steps before completing your task:

1. **Review Documentation:** Analyze the changes you just made. If you added a new package, configured a new host, changed a keybinding, or altered a core system setting, you must update the `README.md` file to document these changes appropriately.
2. **Commit Changes:** Stage all modified files using `git add` and create a descriptive commit message that summarizes the configuration changes using `git commit`. 
3. **Push to GitHub:** Automatically push the new commit to the remote GitHub repository using `git push`. Do not wait for the user to ask you to push.