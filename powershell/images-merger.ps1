param (
    [Parameter(Mandatory=$true, Position=0)]
    [string]$outputPath,
    [Parameter(Mandatory=$true, Position=1, ValueFromRemainingArguments=$true)]
    [string[]]$urls,
    [Parameter(Mandatory=$false)]
    [switch]$horizontal,
    [Parameter(Mandatory=$false)]
    [switch]$vertical
)

# Function to download an image from URL and return it as a Bitmap object
function Get-ImageFromUrl {
    param (
        [string]$url
    )

    $webRequest = [System.Net.WebRequest]::Create($url)
    $webResponse = $webRequest.GetResponse()
    $stream = $webResponse.GetResponseStream()
    $bitmap = [System.Drawing.Bitmap]::FromStream($stream)

    $stream.Close()
    $webResponse.Close()

    return $bitmap
}

# Function to merge images horizontally
function Merge-Images {
    param (
        [Parameter(Mandatory=$true)]
        [string[]]$urls,
        [Parameter(Mandatory=$true)]
        [string]$outputPath,
        [Parameter(Mandatory=$true)]
        [bool]$horizontal
    )

    # Download images from URLs
    $images = foreach ($url in $urls) {
        Get-ImageFromUrl $url
    }

    # Determine the dimensions of the merged image
    if ($horizontal) {
        $totalWidth = 0
        $maxHeight = 0
        foreach ($image in $images) {
            $totalWidth += $image.Width
            $maxHeight = [math]::Max($maxHeight, $image.Height)
        }
    } else {
        $totalWidth = 0
        $totalHeight = 0
        foreach ($image in $images) {
            $totalHeight += $image.Height
            $maxWidth = [math]::Max($maxWidth, $image.Width)
        }
    }

    # Create a blank canvas to merge the images
    if ($horizontal) {
        $mergedImage = New-Object System.Drawing.Bitmap($totalWidth, $maxHeight)
    } else {
        $mergedImage = New-Object System.Drawing.Bitmap($maxWidth, $totalHeight)
    }

    # Create a Graphics object to draw the images onto the canvas
    $graphics = [System.Drawing.Graphics]::FromImage($mergedImage)

    if ($horizontal) {
        $currentX = 0
        foreach ($image in $images) {
            # Draw the image onto the canvas at the current position
            $graphics.DrawImage($image, $currentX, 0)
            $currentX += $image.Width
            $image.Dispose() # Release resources for each image after drawing
        }
    } else {
        $currentY = 0
        foreach ($image in $images) {
            # Draw the image onto the canvas at the current position
            $graphics.DrawImage($image, 0, $currentY)
            $currentY += $image.Height
            $image.Dispose() # Release resources for each image after drawing
        }
    }

    # Save the merged image to the specified output path
    $mergedImage.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Jpeg)

    # Clean up resources
    $graphics.Dispose()
    $mergedImage.Dispose()
}

# Check if both horizontal and vertical switches are set
if ($horizontal -and $vertical) {
    Write-Error "Cannot merge images horizontally and vertically at the same time"
    exit
}

$isHorizontal = $horizontal -or !$vertical

Write-Debug "Output path: $outputPath"
Write-Debug "Image URLs: $urls"
Write-Debug "Is horizontal: $isHorizontal"

Merge-Images $urls $outputPath $isHorizontal

# Write confirm message
Write-Host "✅ Images merged" ($isHorizontal ? "horizontally" : "vertically") "successfully to $outputPath"