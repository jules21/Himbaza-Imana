param(
  [ValidateSet('html', 'canvaskit')]
  [string]$Renderer = 'html',
  [string]$BaseHref = '/'
)

$ErrorActionPreference = 'Stop'
flutter pub get
flutter build web --release --web-renderer $Renderer --base-href $BaseHref

Write-Host "PWA built in build/web using the $Renderer renderer."
