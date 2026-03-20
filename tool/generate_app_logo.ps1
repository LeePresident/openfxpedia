param(
    [string]$OutputPath = 'assets/branding/openfxpedia_logo.png',
    [int]$Size = 1024
)

$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Drawing

$dir = Split-Path -Parent $OutputPath
if (-not [string]::IsNullOrWhiteSpace($dir) -and -not (Test-Path $dir)) {
    New-Item -Path $dir -ItemType Directory -Force | Out-Null
}

$bitmap = New-Object System.Drawing.Bitmap($Size, $Size)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)

try {
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.Clear([System.Drawing.Color]::FromArgb(0, 0, 0, 0))

    $outer = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 11, 44, 79))
    $inner = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 20, 86, 128))
    $accent = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 97, 218, 251))
    $white = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 245, 250, 255))

    $pad = [int]($Size * 0.08)
    $innerPad = [int]($Size * 0.2)
    $graphics.FillEllipse($outer, $pad, $pad, $Size - 2 * $pad, $Size - 2 * $pad)
    $graphics.FillEllipse($inner, $innerPad, $innerPad, $Size - 2 * $innerPad, $Size - 2 * $innerPad)

    $ringPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(220, 97, 218, 251), [float]($Size * 0.035))
    $ringInset = [int]($Size * 0.14)
    $graphics.DrawArc($ringPen, $ringInset, $ringInset, $Size - 2 * $ringInset, $Size - 2 * $ringInset, 20, 300)

    $fontSize = [float]($Size * 0.33)
    $font = New-Object System.Drawing.Font('Segoe UI', $fontSize, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
    $text = 'FX'
    $sf = New-Object System.Drawing.StringFormat
    $sf.Alignment = [System.Drawing.StringAlignment]::Center
    $sf.LineAlignment = [System.Drawing.StringAlignment]::Center
    $graphics.DrawString($text, $font, $white, [float]($Size / 2), [float]($Size / 2), $sf)

    $dotSize = [int]($Size * 0.08)
    $graphics.FillEllipse($accent, [int]($Size * 0.73), [int]($Size * 0.23), $dotSize, $dotSize)

    $bitmap.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    Write-Host "Generated logo: $OutputPath"
}
finally {
    if ($sf) { $sf.Dispose() }
    if ($font) { $font.Dispose() }
    if ($ringPen) { $ringPen.Dispose() }
    if ($outer) { $outer.Dispose() }
    if ($inner) { $inner.Dispose() }
    if ($accent) { $accent.Dispose() }
    if ($white) { $white.Dispose() }
    $graphics.Dispose()
    $bitmap.Dispose()
}
