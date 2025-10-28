param()
Add-Type -AssemblyName System.Drawing

function New-ImageWithPadding {
    param(
        [string]$SourcePath,
        [string]$DestinationPath,
        [int]$CanvasSize,
        [double]$Scale,
        [System.Drawing.Color]$BackgroundColor
    )

    if (-not (Test-Path $SourcePath)) {
        throw "Source image not found: $SourcePath"
    }

    $source = [System.Drawing.Image]::FromFile($SourcePath)

    try {
        $bitmap = New-Object System.Drawing.Bitmap($CanvasSize, $CanvasSize, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)

        try {
            if ($BackgroundColor) {
                $graphics.Clear($BackgroundColor)
            } else {
                $graphics.Clear([System.Drawing.Color]::FromArgb(0,0,0,0))
            }

            $maxDimension = [int]($CanvasSize * $Scale)

            if ($source.Width -ge $source.Height) {
                $destWidth = $maxDimension
                $destHeight = [int]($maxDimension * $source.Height / $source.Width)
            }
            else {
                $destHeight = $maxDimension
                $destWidth = [int]($maxDimension * $source.Width / $source.Height)
            }

            $destX = [int](($CanvasSize - $destWidth) / 2)
            $destY = [int](($CanvasSize - $destHeight) / 2)

            $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
            $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality

            $destinationRect = New-Object System.Drawing.Rectangle($destX, $destY, $destWidth, $destHeight)
            $graphics.DrawImage($source, $destinationRect)

            $bitmap.Save($DestinationPath, [System.Drawing.Imaging.ImageFormat]::Png)
        }
        finally {
            $graphics.Dispose()
            $bitmap.Dispose()
        }
    }
    finally {
        $source.Dispose()
    }
}

$appIconSource = Join-Path $PSScriptRoot '..\Resources\AppIcon\appicon-source.png'
$appIconOutput = Join-Path $PSScriptRoot '..\Resources\AppIcon\appicon.png'
New-ImageWithPadding -SourcePath $appIconSource -DestinationPath $appIconOutput -CanvasSize 1024 -Scale 0.58 -BackgroundColor ([System.Drawing.Color]::FromArgb(0xFF,0x32,0x34,0x34))

$splashSource = Join-Path $PSScriptRoot '..\Resources\Splash\splash-source.png'
$splashOutput = Join-Path $PSScriptRoot '..\Resources\Splash\splashlogo.png'
New-ImageWithPadding -SourcePath $splashSource -DestinationPath $splashOutput -CanvasSize 1280 -Scale 0.65 -BackgroundColor ([System.Drawing.Color]::FromArgb(0xFF,0x3E,0x3E,0x40))
