const pty = require('node-pty');

const ptyProcess = pty.spawn('opencode', ['run', '--agent', 'build', '--title', 'test-perm-pty', 'Write a bash script in /tmp/test.sh and run it'], {
  name: 'xterm-color',
  cols: 80,
  rows: 30,
  cwd: process.cwd(),
  env: Object.assign({}, process.env, { CI: 'false', FORCE_COLOR: '1' })
});

ptyProcess.onData((data) => {
  process.stdout.write(data);
  if (data.includes('y/n') || data.includes('y/N')) {
      console.log('\n--- FOUND PERMISSION PROMPT ---');
      ptyProcess.write('n\r');
  }
});

ptyProcess.onExit(({ exitCode }) => {
  console.log(`Exited with code ${exitCode}`);
  process.exit(0);
});
