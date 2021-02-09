<#
.SYNOPSIS
    Download latest Bing Daily Images for different locales

.DESCRIPTION
    Download latest Bing Daily Images for different locales

.LINK
    https://github.com/ykmn/Get-BingDaily

.EXAMPLE
    .\Get-BingDaily.ps1
#>

<#
v1.00 2021-02-09 Initial release
#>

# Check if download folder exists and otherwise create it
[string]$downloadFolder = "$([Environment]::GetFolderPath("MyPictures"))\Bing Wallpapers"
#[string]$downloadFolder = $PSScriptRoot
if (!(Test-Path $downloadFolder)) {
    New-Item -ItemType Directory $downloadFolder
}

$Locales = @(
# available locales are:
#    'ar-XA', 'bg-BG', 'cs-CZ', 'da-DK', 'de-AT', 'de-CH', 'de-DE', 'el-GR', 'en-AU', 'en-CA',
#    'en-GB', 'en-ID', 'en-IE', 'en-IN', 'en-MY', 'en-NZ', 'en-PH', 'en-SG', 'en-US', 'en-XA',
#    'en-ZA', 'es-AR', 'es-CL', 'es-ES', 'es-MX', 'es-US', 'es-XL', 'et-EE', 'fi-FI', 'fr-BE',
#    'fr-CA', 'fr-CH', 'fr-FR', 'he-IL', 'hr-HR', 'hu-HU', 'it-IT', 'ja-JP', 'ko-KR', 'lt-LT',
#    'lv-LV', 'nb-NO', 'nl-BE', 'nl-NL', 'pl-PL', 'pt-BR', 'pt-PT', 'ro-RO', 'ru-RU', 'sk-SK',
#    'sl-SL', 'sv-SE', 'th-TH', 'tr-TR', 'uk-UA', 'zh-CN', 'zh-HK', 'zh-TW'

    'de-CH', 'de-DE', 'en-AU', 'en-IN', 'en-GB', 'en-US', 'fr-CA', 'fr-FR',  'ja-JP', 'zh-CN'
);

[string]$hostname = "https://www.bing.com"
# Download the latest $files wallpapers
[int]$files = 3
# Max item count: the number of images we'll query for
[int]$maxItemCount = [System.Math]::max(1, [System.Math]::max($files, 8))
# Available resolutions of the image to download:
# '1024x768', '1280x720', '1366x768', '1920x1080', '1920x1200'
[string]$resolution = '1920x1080'

foreach ($locale in $Locales) {
    Write-Host Processing [$locale] -ForegroundColor Yellow
    [string]$uri = "$hostname/HPImageArchive.aspx?format=xml&idx=0&n=$maxItemCount&mkt=$locale"
    $request = Invoke-WebRequest -Uri $uri
    [xml]$content = $request.Content
    $items = New-Object System.Collections.ArrayList
    foreach ($xmlImage in $content.images.image) {
        [datetime]$imageDate = [datetime]::ParseExact($xmlImage.startdate, 'yyyyMMdd', $null)
        [string]$imageUrl = "$hostname$($xmlImage.urlBase)_$resolution.jpg"
        # Add item to our array list
        $item = New-Object System.Object
        $item | Add-Member -Type NoteProperty -Name date -Value $imageDate
        $item | Add-Member -Type NoteProperty -Name url -Value $imageUrl
        $null = $items.Add($item)
    }
    Write-Host "Downloading:"
    $client = New-Object System.Net.WebClient
    foreach ($item in $items) {
        $baseName = $item.date.ToString("yyyy-MM-dd")
        $destination = "$downloadFolder\$baseName.jpg"
        $urlBase = $xmlImage.urlBase -replace "\/th\?id=",""
        $url = $item.url
        #$destination = "$downloadFolder\Bing Daily $baseName $Locale $urlBase.jpg"
        $destination = "D:\Bing Daily $baseName $Locale $urlBase.jpg"
        Write-Host $basename : $url
        # Download the enclosure if we haven't done so already
        if (!(Test-Path $destination)) {
            Write-Debug "Downloading image to $destination"
        $client.DownloadFile($url, "$destination")
       }
    }
}