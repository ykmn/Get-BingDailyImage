

<#
.SYNOPSIS
    Download latest Windows Spotlight Images for different locales

.DESCRIPTION
    Download latest  Windows SpotlightImages for different locales in maximum resolution:
    if image is not exist in top resolution we're saving previous resolution from the list.
    Images are unique i.e. if the same image exists in different locales we're saving only one.
    Files will be saved in ~/Pictures/Windows Spotlight Images

.LINK
    https://github.com/ykmn/Get-SpotlightDaily

.EXAMPLE
    .\Get-SpotlightDaily.ps1
#>

<#
Roman Ermakov <r.ermakov@emg.fm>
v1.00 2021-03-01 Initial release
#>

$ErrorActionPreference = 'SilentlyContinue'
#$ErrorActionPreference = 'Continue'
# Check if download folder exists and otherwise create it
#[string]$downloadFolder = $PSScriptRoot
[string]$downloadFolder = Join-Path -Path "$([Environment]::GetFolderPath("MyPictures"))" -ChildPath "Microsoft Spotlight Daily Images"
if (!(Test-Path $downloadFolder)) {
    Write-Host "No download folder found. Creating: " -ForegroundColor Yellow
    New-Item -ItemType Directory $downloadFolder
}

$Locales = @(
<#
Currently only the values 'de-DE', 'en-AU', 'en-CA', 'en-GB', 'en-IN', 'en-US', 'fr-CA', 'fr-FR', 'ja-JP', 'zh-CN'
will have their own localized version. Other values will be considered by Bing as the "Rest of the World".
#>
<#
Available locales are:
'ar-XA', 'bg-BG', 'cs-CZ', 'da-DK', 'de-AT', 'de-CH', 'de-DE', 'el-GR', 'en-AU', 'en-CA',
'en-GB', 'en-ID', 'en-IE', 'en-IN', 'en-MY', 'en-NZ', 'en-PH', 'en-SG', 'en-XA',
'en-ZA', 'es-AR', 'es-CL', 'es-ES', 'es-MX', 'es-US', 'es-XL', 'et-EE', 'fi-FI', 'fr-BE',
'fr-CA', 'fr-CH', 'fr-FR', 'he-IL', 'hr-HR', 'hu-HU', 'it-IT', 'ja-JP', 'ko-KR', 'lt-LT',
'lv-LV', 'nb-NO', 'nl-BE', 'nl-NL', 'pl-PL', 'pt-BR', 'pt-PT', 'ro-RO', 'ru-RU', 'sk-SK',
'sl-SL', 'sv-SE', 'th-TH', 'tr-TR', 'uk-UA', 'zh-CN', 'zh-HK', 'zh-TW', 'en-US' 
#>
'de-DE', 'en-AU', 'fr-CA', 'en-GB', 'en-IN', 'en-US', 'fr-FR', 'ja-JP', 'zh-CN', 'ru-RU', 'tr-TR'
);

$loop = 9 # download locales set 9 times
#[Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("utf-8")
#[System.Console]::OutputEncoding = [System.Console]::InputEncoding = [System.Text.Encoding]::UTF8
#$OutputEncoding = [Console]::OutputEncoding = New-Object System.Text.Utf8Encoding
[Console]::OutputEncoding = [Text.UTF8Encoding]::UTF8

function ConvertTo-Encoding ([string]$From, [string]$To){
    Begin{
            $encFrom = [System.Text.Encoding]::GetEncoding($from)
            $encTo = [System.Text.Encoding]::GetEncoding($to)
    }
    Process{
            $bytes = $encTo.GetBytes($_)
            $bytes = [System.Text.Encoding]::Convert($encFrom, $encTo, $bytes)
            $encTo.GetString($bytes)
    }
}

Write-Host "Processing online locales: " -ForegroundColor Yellow
$items = New-Object System.Collections.ArrayList

for ($num = 1 ; $num -le $loop ; $num++) {
	Write-Host "Pass $num of $loop`: " -NoNewline
	foreach ($locale in $Locales) {
		Write-Host [$locale"] " -NoNewline
		# sample url: https://arc.msn.com/v3/Delivery/Placement?pid=209567&fmt=json&rafb=0&ua=WindowsShellClient%2F0&cdm=1&disphorzres=9999&dispvertres=9999&lo=80217&&lc=eu-US&ctry=US
		[string]$uri = "https://arc.msn.com/v3/Delivery/Placement?pid=209567&fmt=json&rafb=0&ua=WindowsShellClient%2F0&cdm=1&disphorzres=9999&dispvertres=9999&lo=80217&&lc="+$locale+"&ctry="+$(($locale -split '-')[1])
		# whoa, there's a bug with website: it sends unicode as ISO-8859-1
		$wb = New-Object System.Net.WebClient -Property @{Encoding = [System.Text.Encoding]::UTF8}
		$wb.Headers.Add("Content-Type","application/json;charset=utf-8")
		$jsonfile = $wb.DownloadString($uri) | ConvertFrom-Json
#    ($jsonfile.batchrsp.items[1].item | ConvertFrom-JSON).ad.image_fullscreen_001_landscape.u
#    ($jsonfile.batchrsp.items[0].item | ConvertFrom-JSON).ad.title_text.tx
#    ($jsonfile.batchrsp.items[1].item | ConvertFrom-JSON).ad.title_text.tx
		$jsonfile.batchrsp.items | foreach-object {
			[datetime]$imageDate = Get-Date -Format "yyyy-MM-dd"
			[string]$imageUrl = $(($_.item | ConvertFrom-JSON).ad.image_fullscreen_001_landscape.u)
			[string]$imageTitle = $(($_.item | ConvertFrom-JSON).ad.title_text.tx)
			#$id = $imageUrl -replace "https://img-prod-cms-rt-microsoft-com.akamaized.net/cms/api/am/imageFileData/",""
			#$id = $id -replace "\?ver\=\w{4}",""
			Clear-Variable $matches,$id
			$id = $imageUrl -match "\/\w{7}\?"
			$id = $($matches[0]) -replace "\/","" -replace "\?",""
			# Add item to our array list
			$item = New-Object System.Object
			$item | Add-Member -Type NoteProperty -Name date -Value $imageDate
			$item | Add-Member -Type NoteProperty -Name url -Value $imageUrl
			$item | Add-Member -Type NoteProperty -Name title -Value $imageTitle
			$item | Add-Member -Type NoteProperty -Name id -Value $id
			$item | Add-Member -Type NoteProperty -Name locale -Value $locale
			$item | Add-Member -Type NoteProperty -Name size -Value "desktop"
			$null = $items.Add($item)

			[string]$imageUrl = $(($_.item | ConvertFrom-JSON).ad.image_fullscreen_001_portrait.u)
			[string]$imageTitle = $(($_.item | ConvertFrom-JSON).ad.title_text.tx)
			Clear-Variable $matches
			$id = $imageUrl -match "\/\w{7}\?"
			$id = $($matches[0]) -replace "\/","" -replace "\?","" -replace "\s",""
			# Add item to our array list
			$item = New-Object System.Object
			$item | Add-Member -Type NoteProperty -Name date -Value $imageDate
			$item | Add-Member -Type NoteProperty -Name url -Value $imageUrl
			$item | Add-Member -Type NoteProperty -Name title -Value $imageTitle
			$item | Add-Member -Type NoteProperty -Name id -Value $id
			$item | Add-Member -Type NoteProperty -Name locale -Value $locale
			$item | Add-Member -Type NoteProperty -Name size -Value "mobile"
			$null = $items.Add($item)
		}
	}
	Write-Host "`n" -NoNewline
}

$items = $($items | Sort-Object -Unique -Property id,size)
Write-Host "`nGathered total" $items.Count "images online." -ForegroundColor Yellow
# $items | Format-Table

Clear-Variable $files
$files = New-Object System.Collections.ArrayList
foreach ($jpgFile in (Get-ChildItem -Path $downloadFolder)) {
    #[string]$name = $jpgFile.Name -replace "Spotlight\ Daily\ \d{4}\-\d{2}\-\d{2}\ ",""
    #[string]$name = $name -replace "\.jpg","" -replace "\a{2}\-a{2}",""
    Clear-Variable $matches
    [string]$id = $jpgFile.Name -match "^\w{7}"
    $id = $matches[0] -replace " ","" -replace " ",""
    $file = New-Object System.Object
    $file | Add-Member -Type NoteProperty -Name path -Value $jpgFile.FullName
    $file | Add-Member -Type NoteProperty -Name id -Value $id
    $null = $files.Add($file)
}
$files = $($files | Sort-Object -Unique -Property id)
Write-Host "`nFound" $files.Count "local images." -ForegroundColor Yellow

Write-Host "`nComparison local and online images." -ForegroundColor Yellow
$c = Compare-Object -ReferenceObject $items -DifferenceObject $files -Property id -PassThru
Write-Debug $c | Format-Table

Write-Host "`nDownloading new images:" -ForegroundColor Yellow
$wb = New-Object System.Net.WebClient
foreach ($cc in $c)  {
    if ($cc.SideIndicator -eq "<=") {
        #$baseDate = $_.date.ToString("yyyy-MM-dd")
        $id = $cc.id
        $url = $cc.url
        $title = $cc.title
        $baseLocale = $cc.locale
        if ($title -eq "") {
            $destination = Join-Path -Path "$downloadFolder" -ChildPath "$id ($($cc.size)).jpg"
        } else {
            $destination = Join-Path -Path "$downloadFolder" -ChildPath "$id $title ($($cc.size)).jpg"
        }
        $wb.DownloadFile($url, "$destination")
        Write-Host "#" -NoNewline
    }
}


Write-Host "`n`nCleaning up duplicates." -ForegroundColor Yellow
# .NOTES
# Author: Patrick Gruenauer | Microsoft MVP on PowerShell [2018-2020]
# https://sid-500.com/2020/04/26/find-duplicate-files-with-powershell/
############# Find Duplicate Files based on Hash Value ###############
Write-Host "Searching for duplicates, please wait: " -NoNewline
$duplicates = Get-ChildItem -Path $downloadFolder -File -Recurse | `
		Get-FileHash -Algorithm MD5 | `
		Group-Object -Property Hash | `
		Where-Object Count -GT 1
If ($duplicates.count -lt 1) {
	Write-Host "no duplicates found."
} else {
	Write-Host $duplicates.count "duplicates found." 
	$result = foreach ($d in $duplicates) {
		$d.Group | Select-Object -Property Path,Hash -Skip 1 # All duplicate files except first!
	}
	#$itemstomove = $result | Out-GridView -Title "Duplicates found. Select files (CTRL for multiple) and press OK. Selected files will be moved to $downloadFolder\Duplicates_$date" -PassThru
	#$result | Format-Table
	$result | ForEach-Object { Remove-Item -LiteralPath $_.Path } # -literalpath because we have ][ in filename
	Write-Host "Duplicates deleted."
}




Write-Host "`nAll done."

#Start-Sleep -Seconds 3
break