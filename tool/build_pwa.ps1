param(
  [string]$BaseHref = '/'
)

$ErrorActionPreference = 'Stop'
flutter pub get
if ($LASTEXITCODE -ne 0) { throw 'Flutter dependency installation failed.' }
flutter build web --release --base-href $BaseHref --pwa-strategy none
if ($LASTEXITCODE -ne 0) { throw 'Flutter web build failed.' }
node tool/prepare_pwa.mjs
if ($LASTEXITCODE -ne 0) { throw 'Offline cache preparation failed.' }

Write-Host 'PWA built in build/web with the complete offline cache.'
