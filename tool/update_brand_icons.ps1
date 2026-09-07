# Resize the existing app logo for platform icon slots; no new artwork.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$brandingRoot = Split-Path $PSScriptRoot -Parent
$brandingSource = [System.Drawing.Image]::FromFile((Join-Path $brandingRoot 'assets/icons/logo.png'))
function Write-BrandPng([string]$relativePath, [int]$size) {
  $bitmap = [System.Drawing.Bitmap]::new($size, $size)
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  try {
    $graphics.Clear([System.Drawing.Color]::White)
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.DrawImage($brandingSource, 0, 0, $size, $size)
    $bitmap.Save((Join-Path $brandingRoot $relativePath), [System.Drawing.Imaging.ImageFormat]::Png)
  } finally { $graphics.Dispose(); $bitmap.Dispose() }
}
function Write-BrandIco([string]$relativePath) {
  $sizes = @(16, 32, 48, 64, 128, 256)
  $images = foreach ($size in $sizes) {
    $bitmap = [System.Drawing.Bitmap]::new($size, $size)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $stream = [System.IO.MemoryStream]::new()
    try {
      $graphics.Clear([System.Drawing.Color]::White)
      $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
      $graphics.DrawImage($brandingSource, 0, 0, $size, $size)
      # Store standard DIB frames for Windows resource compiler compatibility.
      $bitmap.Save($stream, [System.Drawing.Imaging.ImageFormat]::Bmp)
      $bmp = $stream.ToArray()
      $maskLength = [int]([Math]::Ceiling($size / 32.0) * 4 * $size)
      $frame = [byte[]]::new($bmp.Length - 14 + $maskLength)
      [Array]::Copy($bmp, 14, $frame, 0, $bmp.Length - 14)
      [Array]::Copy([BitConverter]::GetBytes([int]($size * 2)), 0, $frame, 8, 4)
      ,$frame
    } finally { $stream.Dispose(); $graphics.Dispose(); $bitmap.Dispose() }
  }
  $file = [System.IO.File]::Create((Join-Path $brandingRoot $relativePath))
  $writer = [System.IO.BinaryWriter]::new($file)
  try {
    $writer.Write([uint16]0); $writer.Write([uint16]1); $writer.Write([uint16]$sizes.Count)
    $offset = 6 + 16 * $sizes.Count
    for ($i = 0; $i -lt $sizes.Count; $i++) {
      $dimension = if ($sizes[$i] -eq 256) { 0 } else { $sizes[$i] }
      $writer.Write([byte]$dimension); $writer.Write([byte]$dimension)
      $writer.Write([byte]0); $writer.Write([byte]0)
      $writer.Write([uint16]1); $writer.Write([uint16]32)
      $writer.Write([uint32]$images[$i].Length); $writer.Write([uint32]$offset)
      $offset += $images[$i].Length
    }
    foreach ($bytes in $images) { $writer.Write([byte[]]$bytes) }
  } finally { $writer.Dispose(); $file.Dispose() }
}
try {
  Write-BrandPng 'web/himbaza-imana.png' 32
  Write-BrandPng 'web/icons/himbaza-imana-180.png' 180
  foreach ($size in @(192, 512)) {
    Write-BrandPng "web/icons/himbaza-imana-$size.png" $size
    Write-BrandPng "web/icons/himbaza-imana-maskable-$size.png" $size
    Write-BrandPng "web_backup/icons/Icon-$size.png" $size
    Write-BrandPng "web_backup/icons/Icon-maskable-$size.png" $size
  }
  Write-BrandPng 'web_backup/favicon.png' 32
  foreach ($size in @(16, 32, 64, 128, 256, 512, 1024)) {
    Write-BrandPng "macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_$size.png" $size
  }
  Write-BrandIco 'windows/runner/resources/app_icon.ico'
} finally { $brandingSource.Dispose() }
