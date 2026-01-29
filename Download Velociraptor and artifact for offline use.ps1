# Script: Download Velociraptor and artifacts for offline use
# Author: Yaniv Radunsky @ 10Root

param (
    [Parameter(Mandatory=$true)]
    [string]$destinationFolder
)

function GetLatestGithubRelease {
param ($outputFolder, $repo, $filenamePattern)
$asset = ((Invoke-RestMethod -Method GET -Uri "https://api.github.com/repos/$repo/releases")[0].assets | Where-Object name -like $filenamePattern | Select-Object -Last 1)
if ($null -eq $asset) {
    Write-Error "No asset found matching pattern: $filenamePattern in $repo"
    return
}
$source = $asset.browser_download_url
$outputFile = Join-Path -Path $outputFolder -ChildPath $asset.name
Invoke-WebRequest -Uri $source -Out $outputFile
}

function GetFile{
param ($outputFolder, $source)
$outputFile = Join-Path -Path $outputFolder -ChildPath $(Split-Path -Path $source -Leaf)
Invoke-WebRequest -Uri $source -Out $outputFile
}

function GetMicrosoftMRT {
param ($outputFolder)
# Get the Microsoft Malicious Software Removal Tool (KB890830) using Microsoft's stable redirect URL
# This URL always points to the latest version
$downloadUrl = "https://go.microsoft.com/fwlink/?LinkId=212732"
$tempFile = Join-Path -Path $outputFolder -ChildPath "mrt_temp.exe"
Invoke-WebRequest -Uri $downloadUrl -Out $tempFile
# Get version from the downloaded file and rename appropriately
$fileVersion = (Get-Item $tempFile).VersionInfo.ProductVersion
if ($fileVersion) {
    $finalName = "Windows-KB890830-x64-V$fileVersion.exe"
} else {
    $finalName = "Windows-KB890830-x64-MRT.exe"
}
$finalPath = Join-Path -Path $outputFolder -ChildPath $finalName
if (Test-Path $finalPath) { Remove-Item $finalPath -Force }
Rename-Item -Path $tempFile -NewName $finalName
}

$downloadFolder = Join-Path -Path $destinationFolder -ChildPath "VelociraptorPlus"
if (-not (Test-Path $downloadFolder)) {
    New-Item -ItemType Directory -Path $downloadFolder -Force
}

echo "-- download latest velociraptor exe and msi --"
GetLatestGithubRelease $downloadFolder "Velocidex/velociraptor" "*windows-amd64.exe"
GetLatestGithubRelease $downloadFolder "Velocidex/velociraptor" "*windows-amd64.msi"
GetLatestGithubRelease $downloadFolder "Velocidex/velociraptor" "velociraptor-collector"
GetLatestGithubRelease $downloadFolder "Velocidex/velociraptor" "*linux-amd64"

echo "-- download latest EVTXHussar --"
GetLatestGithubRelease $downloadFolder "yarox24/EvtxHussar" "*windows_amd64.zip"

echo "-- download latest PersistenceSniper --"
GetLatestGithubRelease $downloadFolder "last-byte/PersistenceSniper" "PersistenceSniper.zip"
GetFile $downloadFolder "https://raw.githubusercontent.com/ablescia/Windows.PersistenceSniper/main/false_positives.csv"

echo "-- download latest WinPMwem --"
GetLatestGithubRelease $downloadFolder "Velocidex/WinPmem" "winpmem64.exe"

echo "-- download latest DetectRaptor --"
GetLatestGithubRelease $downloadFolder "mgreen27/DetectRaptor" "DetectRaptorVQL.zip"

echo "-- download latest Nirsoft LastActivityView --"
GetFile $downloadFolder "https://www.nirsoft.net/utils/lastactivityview.zip"

echo "-- download latest artifactExchange --"
GetFile $downloadFolder "https://github.com/Velocidex/velociraptor-docs/raw/gh-pages/exchange/artifact_exchange_v2.zip"

echo "-- download latest Nirsoft BrowserHistory --"
GetFile $downloadFolder "https://www.nirsoft.net/utils/browsinghistoryview-x64.zip"

echo "-- download latest Hayabusa --"
GetLatestGithubRelease $downloadFolder "Yamato-Security/hayabusa" "hayabusa-*-win-x64.zip"
GetLatestGithubRelease $downloadFolder "Yamato-Security/hayabusa" "hayabusa-*-win-x64-live-response.zip"
$hayabusaZip = Get-Item "$downloadFolder\hayabusa-*-win-x64.zip" | Select-Object -Last 1
Expand-Archive $hayabusaZip.FullName -DestinationPath "$downloadFolder\Hayabusa" -Force
cd "$downloadFolder\Hayabusa"
Remove-Item -Path "$downloadFolder\Hayabusa\rules" -Recurse -Force
$hayabusaExe = Get-Item "$downloadFolder\Hayabusa\hayabusa-*-win-x64.exe" | Select-Object -Last 1
& $hayabusaExe.FullName update-rules
Compress-Archive "$downloadFolder\Hayabusa\*" -DestinationPath "$downloadFolder\hayabusaUpdated.zip"

echo "-- download latest Loki --"
GetLatestGithubRelease $downloadFolder "Neo23x0/Loki" "loki*.zip"

echo "-- download Thor and Adding License --"
Invoke-WebRequest "https://update1.nextron-systems.com/getupdate.php?product=thor10lite-win" -OutFile "$downloadFolder\thor.zip"
# Expand-Archive "$downloadFolder\thorTemp.zip" -DestinationPath "$downloadFolder\Thor" -Force
# Invoke-WebRequest "https://info.nextron-systems.com/e3t/Ctc/GJ+113/dk8wH404/VWb1rD6Yzx_0W780Wgb8md08fW5NMkyh5GF-x-N8GDX5n5kvg8W50kH_H6lZ3pMN3ccYyrBZLc5W6CH0sg5pF74XW60MYcv8Y9XXkW4FP8yt6G8kCwW3TB1571rZxjcW5YzhrC5Yr-HPW2Mj_7W4Q9f9JN76bvCLPLh_cW3pgnzZ44krSrW1-kLSJ6RzbtkW79fkWH6fQV1qW55H3wN2mfLJRW4rzvWd3PdPtcN6TlhRplVwPsW8ZJS1Q7Bx9VHV5yNlc8BXJJcW3XyPqD6sTf29W5f9pdL31gHwrW3xmYHW2wFg0NW7TLrP82TF22MW7z0KNh87V4d2W4p4k-s2ZzSG8W6B4Vd26pZPSBW1fRSwV8Pf5HyW5Rs68h7w1xHPW7ZxmlQ4-s3QYW2h2N394KSwB8W5YVrR76LwYwmW4bl_947kTH7lVkS_l92k9fn6W2jQnj74VF28PW2kDXj08nWn9Qf6CLxss04" -OutFile "$downloadFolder\Thor\thor-lite.lic"
# cd "$downloadFolder\Thor"
# .\thor-lite-util.exe upgrade
# Compress-Archive "$downloadFolder\Thor\*" -DestinationPath "$downloadFolder\thor10.7lite-win-pack.zip" -Force

echo "-- download Velociraptor Sigma Artifacts --"
GetFile $downloadFolder "https://sigma.velocidex.com/Velociraptor.Sigma.Artifacts.zip"

echo "-- download Rapid7Labs VQL --"
GetFile $downloadFolder "https://github.com/rapid7/Rapid7-Labs/raw/main/Vql/release/Rapid7LabsVQL.zip"

echo "-- download Registry Hunter --"
GetFile $downloadFolder "https://registry-hunter.velocidex.com/Windows.Registry.Hunter.zip"

echo "-- download SQLiteHunter --"
GetFile $downloadFolder "https://sqlitehunter.velocidex.com/SQLiteHunter.zip"

echo "-- download Triage Artifacts --"
GetFile $downloadFolder "https://triage.velocidex.com/artifacts/Velociraptor_Triage_v0.1.zip"

echo "-- download 10Root Artifacts --"
GetFile $downloadFolder "https://github.com/10RootOrg/Velociraptor-Artifacts/archive/refs/heads/main.zip"
Rename-Item -Path "$downloadFolder\main.zip" -NewName 10root_artifacts.zip

echo "-- download DetectRaptor YARA rules --"
GetFile $downloadFolder "https://github.com/mgreen27/DetectRaptor/raw/master/yara/full_windows_file.yar.gz"
GetFile $downloadFolder "https://github.com/mgreen27/DetectRaptor/raw/master/yara/full_linux_file.yar.gz"
GetFile $downloadFolder "https://github.com/mgreen27/DetectRaptor/raw/master/yara/yara-rules-full.yar"

echo "-- download latest YaraForge --"
GetLatestGithubRelease $downloadFolder "YARAHQ/yara-forge" "*core.zip"
GetLatestGithubRelease $downloadFolder "YARAHQ/yara-forge" "*extended.zip"
GetLatestGithubRelease $downloadFolder "YARAHQ/yara-forge" "*full.zip"

echo "-- download latest Yara --"
GetLatestGithubRelease $downloadFolder "VirusTotal/yara" "yara*-win32.zip"
GetLatestGithubRelease $downloadFolder "VirusTotal/yara" "yara*-win64.zip"

echo "-- download latest Takajo --"
GetLatestGithubRelease $downloadFolder "Yamato-Security/takajo" "takajo*-win-x64.zip"

echo "-- download DetectRaptor LOLRMM CSV --"
GetFile $downloadFolder "https://github.com/mgreen27/DetectRaptor/raw/master/csv/lolrmm.csv"

echo "-- download Linforce script --"
GetFile $downloadFolder "https://raw.githubusercontent.com/RCarras/linforce/main/linforce.sh"

echo "-- download Volatility --"
GetFile $downloadFolder "https://github.com/volatilityfoundation/volatility/archive/master.zip"
Rename-Item -Path "$downloadFolder\master.zip" -NewName volatility.zip

echo "-- download Sigma profiles --"
GetFile $downloadFolder "https://sigma.velocidex.com/profiles.json"

echo "-- download Eric Zimmerman Tools (.NET 4) --"
GetFile $downloadFolder "https://download.ericzimmermanstools.com/AmcacheParser.zip"
GetFile $downloadFolder "https://download.ericzimmermanstools.com/AppCompatCacheParser.zip"
GetFile $downloadFolder "https://download.ericzimmermanstools.com/bstrings.zip"
GetFile $downloadFolder "https://download.ericzimmermanstools.com/EvtxECmd.zip"
GetFile $downloadFolder "https://download.ericzimmermanstools.com/hasher.zip"
GetFile $downloadFolder "https://download.ericzimmermanstools.com/JLECmd.zip"
GetFile $downloadFolder "https://download.ericzimmermanstools.com/LECmd.zip"
GetFile $downloadFolder "https://download.ericzimmermanstools.com/MFTECmd.zip"
GetFile $downloadFolder "https://download.ericzimmermanstools.com/PECmd.zip"
GetFile $downloadFolder "https://download.ericzimmermanstools.com/RBCmd.zip"
GetFile $downloadFolder "https://download.ericzimmermanstools.com/RecentFileCacheParser.zip"
GetFile $downloadFolder "https://download.ericzimmermanstools.com/RECmd.zip"
GetFile $downloadFolder "https://download.ericzimmermanstools.com/rla.zip"
GetFile $downloadFolder "https://download.ericzimmermanstools.com/SBECmd.zip"
GetFile $downloadFolder "https://download.ericzimmermanstools.com/SrumECmd.zip"
GetFile $downloadFolder "https://download.ericzimmermanstools.com/SumECmd.zip"
GetFile $downloadFolder "https://download.ericzimmermanstools.com/iisGeolocate.zip"
GetFile $downloadFolder "https://download.ericzimmermanstools.com/net6/TimelineExplorer.zip"

echo "-- download Sysinternals Tools --"
GetFile $downloadFolder "https://live.sysinternals.com/tools/autorunsc64.exe"
GetFile $downloadFolder "https://live.sysinternals.com/tools/disk2vhd64.exe"
GetFile $downloadFolder "https://live.sysinternals.com/tools/procexp64.exe"
GetFile $downloadFolder "https://live.sysinternals.com/tools/sigcheck64.exe"
GetFile $downloadFolder "https://live.sysinternals.com/tools/strings64.exe"
GetFile $downloadFolder "https://live.sysinternals.com/tools/Sysmon64.exe"

echo "-- download ForensicTools Kit --"
GetLatestGithubRelease $downloadFolder "cristianzsh/forensictools" "forensictools*setup.exe"

echo "-- download PingCastle --"
GetLatestGithubRelease $downloadFolder "netwrix/pingcastle" "ping*.zip"

echo "-- download HardeningKitty --"
GetFile $downloadFolder "https://github.com/0x6d69636b/windows_hardening/archive/refs/heads/master.zip"
Rename-Item -Path "$downloadFolder\master.zip" -NewName HardeningKitty.zip

echo "-- download Microsoft Malicious Software Removal Tool (KB890830) --"
GetMicrosoftMRT $downloadFolder

echo "-- download FTK Imager Command Line --"
Invoke-WebRequest -Uri "https://www.dropbox.com/scl/fi/juz70umd0clt2np4hf0d6/FTKImager-commandline.zip?rlkey=0320go01k20eyh3qutwb0pwg0&dl=1" -OutFile "$downloadFolder\FTKImager-commandline.zip"

echo "-- download latest Chainsaw --"
GetLatestGithubRelease $downloadFolder "WithSecureLabs/chainsaw" "chainsaw_all_platforms+rules*.zip"

echo "Download finished, Please add Thor license manually"