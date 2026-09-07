import { createHash } from 'node:crypto';
import { readdir, readFile, writeFile } from 'node:fs/promises';
import path from 'node:path';

const output = path.resolve(process.argv[2] || 'build/web');
async function filesIn(directory) {
  const entries = await readdir(directory, { withFileTypes: true });
  const files = await Promise.all(entries.map(async (entry) => {
    const file = path.join(directory, entry.name);
    return entry.isDirectory() ? filesIn(file) : [file];
  }));
  return files.flat();
}
const files = (await filesIn(output))
  .map((file) => path.relative(output, file).split(path.sep).join('/'))
  .filter((file) => !['pwa_service_worker.js', 'flutter_service_worker.js'].includes(file) && !file.endsWith('.map'))
  .sort();
for (const required of ['index.html', 'flutter_bootstrap.js', 'main.dart.js', 'assets/assets/Bride_songs.json', 'assets/assets/hymns_praise_songs.json']) {
  if (!files.includes(required)) throw new Error(`Missing offline resource: ${required}`);
}
const hash = createHash('sha256');
for (const file of files) {
  hash.update(file);
  hash.update(await readFile(path.join(output, file)));
}
const template = await readFile(new URL('../web/pwa_service_worker.js', import.meta.url), 'utf8');
hash.update(template);
const version = hash.digest('hex').slice(0, 20);
await writeFile(path.join(output, 'pwa_service_worker.js'), template
  .replace('__BUILD_HASH__', version)
  .replace('/* __APP_SHELL__ */ []', JSON.stringify(files.map((file) => file.split('/').map(encodeURIComponent).join('/')), null, 2)));
console.log(`Prepared ${files.length} offline resources (${version}).`);
