<#
.SYNOPSIS
    Download latest Bing Daily Images for different locales

.DESCRIPTION
    Download latest Bing Daily Images for different locales in maximum resolution:
    if image is not exist in top resolution we're saving previous resolution from the list.
    Images are unique i.e. if the same image exists in different locales we're saving only one.
    Files will be saved in ~/Pictures/Bing Daily Images

.LINK
    https://github.com/ykmn/Get-BingDaily

.EXAMPLE
    .\Get-BingDaily.ps1
#>

<#
Roman Ermakov <r.ermakov@emg.fm>
v1.01 2021-02-26 Compare online images list and already downloaded files
v1.00 2021-02-09 Initial release
#>

$ErrorActionPreference = 'SilentlyContinue'
# Check if download folder exists and otherwise create it
[string]$downloadFolder = Join-Path -Path "$([Environment]::GetFolderPath("MyPictures"))" -ChildPath "Bing Daily Images"
#[string]$downloadFolder = $PSScriptRoot
if (!(Test-Path $downloadFolder)) {
    Write-Host "No download folder found. Creating: " -ForegroundColor Yellow
    New-Item -ItemType Directory $downloadFolder
}

$Locales = @(
<# Available locales are:
    'ar-XA', 'bg-BG', 'cs-CZ', 'da-DK', 'de-AT', 'de-CH', 'de-DE', 'el-GR', 'en-AU', 'en-CA',
    'en-GB', 'en-ID', 'en-IE', 'en-IN', 'en-MY', 'en-NZ', 'en-PH', 'en-SG', 'en-XA',
    'en-ZA', 'es-AR', 'es-CL', 'es-ES', 'es-MX', 'es-US', 'es-XL', 'et-EE', 'fi-FI', 'fr-BE',
    'fr-CA', 'fr-CH', 'fr-FR', 'he-IL', 'hr-HR', 'hu-HU', 'it-IT', 'ja-JP', 'ko-KR', 'lt-LT',
    'lv-LV', 'nb-NO', 'nl-BE', 'nl-NL', 'pl-PL', 'pt-BR', 'pt-PT', 'ro-RO', 'ru-RU', 'sk-SK',
    'sl-SL', 'sv-SE', 'th-TH', 'tr-TR', 'uk-UA', 'zh-CN', 'zh-HK', 'zh-TW', 'en-US' 
Currently only the values 'de-DE', 'en-AU', 'en-CA', 'en-GB', 'en-IN', 'en-US', 'fr-CA', 'fr-FR', 'ja-JP', 'zh-CN'
will have their own localized version. Other values will be considered as the "Rest of the World" by Bing.
#>
    'de-DE', 'en-AU', 'en-CA', 'en-GB', 'en-IN', 'en-US', 'fr-CA', 'fr-FR', 'ja-JP', 'zh-CN', 'ru-RU'
);

[string]$hostname = "https://www.bing.com"

#$resolutions = @( '1920x1080' ) # FullHD
#$resolutions = @( '1080x1920' ) # vertical
$resolutions = @( '1920x1080', '1920x1200' )

Write-Host "Processing locales online: " -NoNewline -ForegroundColor Yellow
$items = New-Object System.Collections.ArrayList
foreach ($locale in $Locales) {
    Write-Host [$locale"] " -NoNewline
    [string]$uri = "$hostname/HPImageArchive.aspx?format=xml&idx=0&n=8&mkt=$locale"
    $request = Invoke-WebRequest -Uri $uri
    [xml]$content = $request.Content

    foreach ($xmlImage in $content.images.image) {
        foreach ($resolution in $resolutions) {
            [datetime]$imageDate = [datetime]::ParseExact($xmlImage.startdate, 'yyyyMMdd', $null)
            [string]$imageUrl = "$hostname$($xmlImage.urlBase)_$resolution.jpg"
            [string]$imageUrlBase = $xmlImage.urlBase
            [string]$imageCopyright = $xmlImage.copyright
            # Add item to our array list
            $item = New-Object System.Object
            $item | Add-Member -Type NoteProperty -Name date -Value $imageDate
            $item | Add-Member -Type NoteProperty -Name url -Value $imageUrl
            $imageUrlBase = $imageUrlBase -replace "\/th\?id=",""
            $imageUrlBase = $imageUrlBase -replace $locale,""
            $imageUrlBase = $imageUrlBase -replace "OHR.",""
            $imageUrlBase = $imageUrlBase -replace "ROW",""
            $imageUrlBase = $imageUrlBase -replace "_\d{8,12}.",""
            $item | Add-Member -Type NoteProperty -Name id -Value $imageUrlBase
            $item | Add-Member -Type NoteProperty -Name copyright -Value $imageCopyright
            
            $null = $items.Add($item)
        }
    }
}
$items = $($items | Sort-Object -Unique -Property id)
Write-Host "`nUnique images in all locales:" -ForegroundColor Yellow
$items | Format-Table

$files = New-Object System.Collections.ArrayList
foreach ($jpgFile in (Get-ChildItem -Path $downloadFolder)) {
    [string]$id = $jpgFile.Name -replace "Bing\ Daily\ \d{4}\-\d{2}\-\d{2}\ ",""
    [string]$id = $id -replace "\.jpg",""
    $file = New-Object System.Object
    $file | Add-Member -Type NoteProperty -Name path -Value $jpgFile.FullName
    $file | Add-Member -Type NoteProperty -Name id -Value $id
    $null = $files.Add($file)
}
$files | Sort-Object -Unique -Property id
<#
Write-Host "`nUnique existing files:" -ForegroundColor Yellow
$files | Format-Table
#>

Write-Host "`nComparison local and online images:" -ForegroundColor Yellow
$c = Compare-Object -ReferenceObject $items -DifferenceObject $files -Property id -PassThru
$c | Format-Table

Write-Host "`nDownloading:" -ForegroundColor Yellow
$client = New-Object System.Net.WebClient
foreach ($cc in $c)  {
    if ($cc.SideIndicator -eq "<=") {
        $baseDate = $cc.date.ToString("yyyy-MM-dd")
        $baseName = $cc.id
        $url = $cc.url
        $destination = Join-Path -Path "$downloadFolder" -ChildPath "Bing Daily $baseDate $baseName.jpg"
        #Write-Host $baseDate : $url with BASENAME $baseName to $destination
        Write-Host $baseDate : $url
        Write-Host "->" $destination
        Write-Host $cc.copyright "`n"
        #Write-Host "Downloading image to $destination"
        $client.DownloadFile($url, "$destination")
    }
}
Write-Host "`nAll done."
Start-Sleep -Seconds 3
break