<#
.SYNOPSIS
    Download latest Bing Daily Images for different locales

.DESCRIPTION
    Download latest Bing Daily Images for different locales in maximum resolution:
    if image is not exist in top resolution we're saving previous resolution.
    Images are unique i.e. if the same image exists in different locales we're saving only one.

.LINK
    https://github.com/ykmn/Get-BingDaily

.EXAMPLE
    .\Get-BingDaily.ps1
#>

<#
v1.00 2021-02-09 Initial release
#>

$ErrorActionPreference = 'SilentlyContinue'
# Check if download folder exists and otherwise create it
[string]$downloadFolder = "$([Environment]::GetFolderPath("MyPictures"))\Bing Wallpapers"
#[string]$downloadFolder = $PSScriptRoot
if (!(Test-Path $downloadFolder)) {
    New-Item -ItemType Directory $downloadFolder
}

$Locales = @(
# Available locales are:
#    'ar-XA', 'bg-BG', 'cs-CZ', 'da-DK', 'de-AT', 'de-CH', 'de-DE', 'el-GR', 'en-AU', 'en-CA',
#    'en-GB', 'en-ID', 'en-IE', 'en-IN', 'en-MY', 'en-NZ', 'en-PH', 'en-SG', 'en-US', 'en-XA',
#    'en-ZA', 'es-AR', 'es-CL', 'es-ES', 'es-MX', 'es-US', 'es-XL', 'et-EE', 'fi-FI', 'fr-BE',
#    'fr-CA', 'fr-CH', 'fr-FR', 'he-IL', 'hr-HR', 'hu-HU', 'it-IT', 'ja-JP', 'ko-KR', 'lt-LT',
#    'lv-LV', 'nb-NO', 'nl-BE', 'nl-NL', 'pl-PL', 'pt-BR', 'pt-PT', 'ro-RO', 'ru-RU', 'sk-SK',
#    'sl-SL', 'sv-SE', 'th-TH', 'tr-TR', 'uk-UA', 'zh-CN', 'zh-HK', 'zh-TW'
# Currently only the values 'de-DE', 'en-AU', 'en-CA', 'en-GB', 'en-IN', 'en-US', 'fr-CA', 'fr-FR', 'ja-JP', 'zh-CN'
# will have their own localized version. Other values will be considered as the "Rest of the World" by Bing.

    'de-DE', 'en-AU', 'en-CA', 'en-GB', 'en-IN', 'en-US', 'fr-CA', 'fr-FR', 'ja-JP', 'zh-CN'
);

[string]$hostname = "https://www.bing.com"
# Download the latest $files wallpapers
[int]$files = 1
# Max item count: the number of images we'll query for
[int]$maxItemCount = [System.Math]::max(1, [System.Math]::max($files, 8))
# Available resolutions of the image to download:
# '1024x768', '1280x720', '1366x768', '1920x1080', '1920x1200'
$resolutions = @( '1920x1080', '1920x1200' )

Write-Host "Processing: " -NoNewline -ForegroundColor Yellow
$items = New-Object System.Collections.ArrayList

foreach ($locale in $Locales) {
    Write-Host [$locale"] " -NoNewline
    [string]$uri = "$hostname/HPImageArchive.aspx?format=xml&idx=0&n=$maxItemCount&mkt=$locale"
    $request = Invoke-WebRequest -Uri $uri
    [xml]$content = $request.Content

    foreach ($xmlImage in $content.images.image) {
        foreach ($resolution in $resolutions) {
            [datetime]$imageDate = [datetime]::ParseExact($xmlImage.startdate, 'yyyyMMdd', $null)
            [string]$imageUrl = "$hostname$($xmlImage.urlBase)_$resolution.jpg"
            [string]$imageUrlBase = $xmlImage.urlBase
            # Add item to our array list
            $item = New-Object System.Object
            $item | Add-Member -Type NoteProperty -Name date -Value $imageDate
            $item | Add-Member -Type NoteProperty -Name url -Value $imageUrl
            $imageUrlBase = $imageUrlBase -replace "\/th\?id=",""
            $imageUrlBase = $imageUrlBase -replace $locale,""
            $imageUrlBase = $imageUrlBase -replace "OHR.",""
            $imageUrlBase = $imageUrlBase -replace "_\d{8,12}.",""
            $item | Add-Member -Type NoteProperty -Name imageUrlBase -Value $imageUrlBase
            $null = $items.Add($item)
        }
    }
}

$items = $($items | Sort-Object -Unique -Property imageUrlBase)
<#
Write-Host "`nFound unique images:" -ForegroundColor Yellow
$items | Format-Table
#>

Write-Host "Downloading:"
$client = New-Object System.Net.WebClient
foreach ($item in $items) {
    $baseDate = $item.date.ToString("yyyy-MM-dd")
    $baseName = $item.imageUrlBase
    $url = $item.url
    $destination = "$downloadFolder\Bing Daily $baseDate $baseName.jpg"
    #$destination = "D:\Bing Daily $baseDate $Locale $baseName.jpg"
    Write-Host $baseDate : $url
    # Download the enclosure if we haven't done so already
    if (!(Test-Path $destination)) {
        Write-Debug "Downloading image to $destination"
    $client.DownloadFile($url, "$destination")
    }
}
