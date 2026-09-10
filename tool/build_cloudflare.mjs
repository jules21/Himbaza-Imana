import { existsSync, mkdirSync } from 'node:fs';
import { homedir } from 'node:os';
import path from 'node:path';
import { spawnSync } from 'node:child_process';

const isWindows = process.platform === 'win32';

function run(command, args, options = {}) {
  const result = spawnSync(command, args, {
    cwd: process.cwd(),
    env: process.env,
    shell: isWindows && /\.(bat|cmd)$/i.test(command),
    stdio: 'inherit',
    ...options,
  });
  if (result.error) throw result.error;
  if (result.status !== 0) {
    throw new Error(`${command} ${args.join(' ')} exited with ${result.status}`);
  }
}

let flutter = 'flutter';
if (isWindows) {
  const lookup = spawnSync('where.exe', ['flutter'], { encoding: 'utf8' });
  if (lookup.status === 0) {
    const matches = lookup.stdout.trim().split(/\r?\n/);
    flutter = matches.find((candidate) => /\.bat$/i.test(candidate)) || matches[0];
  }
}
const installed = spawnSync(flutter, ['--version'], {
  shell: isWindows && /\.(bat|cmd)$/i.test(flutter),
  stdio: 'ignore',
});

if (installed.status !== 0) {
  const cacheRoot = process.env.XDG_CACHE_HOME || path.join(homedir(), '.cache');
  const flutterDirectory = path.join(cacheRoot, 'flutter');
  flutter = path.join(
    flutterDirectory,
    'bin',
    isWindows ? 'flutter.bat' : 'flutter',
  );

  if (!existsSync(flutter)) {
    if (existsSync(flutterDirectory)) {
      throw new Error(`Incomplete Flutter SDK cache at ${flutterDirectory}`);
    }
    mkdirSync(cacheRoot, { recursive: true });
    run('git', [
      'clone',
      '--depth',
      '1',
      '--branch',
      'stable',
      'https://github.com/flutter/flutter.git',
      flutterDirectory,
    ]);
  }
}

run(flutter, ['config', '--enable-web']);
run(flutter, ['clean']);
run(flutter, ['pub', 'get']);
run(flutter, ['build', 'web', '--release', '--base-href', '/']);
run(process.execPath, ['tool/prepare_pwa.mjs']);
run(process.execPath, ['--test', 'test/pwa_service_worker_test.mjs']);
