#!/bin/bash
# Script: Download Velociraptor and artifacts for offline use (Linux)
# Author: Yaniv Radunsky @ 10Root

# Default destination folder
DEFAULT_DEST="/home/tenroot/setup_platform/workdir/tmp"
DEST_FOLDER="${1:-$DEFAULT_DEST}"

# Create VelociraptorPlus subfolder
DOWNLOAD_FOLDER="$DEST_FOLDER/VelociraptorPlus"
mkdir -p "$DOWNLOAD_FOLDER"

# Function to download latest GitHub release
get_latest_github_release() {
    local output_folder="$1"
    local repo="$2"
    local pattern="$3"

    local asset_info=$(curl -s "https://api.github.com/repos/$repo/releases" | \
        jq -r --arg pat "$pattern" '[.[0].assets[] | select(.name | test($pat))] | last | {name: .name, url: .browser_download_url}')

    local name=$(echo "$asset_info" | jq -r '.name')
    local url=$(echo "$asset_info" | jq -r '.url')

    if [ "$name" == "null" ] || [ -z "$name" ]; then
        echo "ERROR: No asset found matching pattern: $pattern in $repo"
        return 1
    fi

    echo "Downloading $name..."
    curl -L -o "$output_folder/$name" "$url"
}

# Function to download a file
get_file() {
    local output_folder="$1"
    local url="$2"
    local filename=$(basename "$url" | cut -d'?' -f1)

    echo "Downloading $filename..."
    curl -L -o "$output_folder/$filename" "$url"
}

echo "Download folder: $DOWNLOAD_FOLDER"
echo ""

echo "-- download latest velociraptor exe and msi --"
get_latest_github_release "$DOWNLOAD_FOLDER" "Velocidex/velociraptor" ".*windows-amd64\\.exe$"
get_latest_github_release "$DOWNLOAD_FOLDER" "Velocidex/velociraptor" ".*windows-amd64\\.msi$"
get_latest_github_release "$DOWNLOAD_FOLDER" "Velocidex/velociraptor" "velociraptor-collector"
get_latest_github_release "$DOWNLOAD_FOLDER" "Velocidex/velociraptor" ".*linux-amd64$"

echo "-- download latest EVTXHussar --"
get_latest_github_release "$DOWNLOAD_FOLDER" "yarox24/EvtxHussar" ".*windows_amd64\\.zip$"

echo "-- download latest PersistenceSniper --"
get_latest_github_release "$DOWNLOAD_FOLDER" "last-byte/PersistenceSniper" "PersistenceSniper\\.zip$"
get_file "$DOWNLOAD_FOLDER" "https://raw.githubusercontent.com/ablescia/Windows.PersistenceSniper/main/false_positives.csv"

echo "-- download latest WinPmem --"
get_latest_github_release "$DOWNLOAD_FOLDER" "Velocidex/WinPmem" "winpmem64\\.exe$"

echo "-- download latest DetectRaptor --"
get_latest_github_release "$DOWNLOAD_FOLDER" "mgreen27/DetectRaptor" "DetectRaptorVQL\\.zip$"

echo "-- download latest Nirsoft LastActivityView --"
get_file "$DOWNLOAD_FOLDER" "https://www.nirsoft.net/utils/lastactivityview.zip"

echo "-- download latest artifactExchange --"
get_file "$DOWNLOAD_FOLDER" "https://github.com/Velocidex/velociraptor-docs/raw/gh-pages/exchange/artifact_exchange_v2.zip"

echo "-- download latest Nirsoft BrowserHistory --"
get_file "$DOWNLOAD_FOLDER" "https://www.nirsoft.net/utils/browsinghistoryview-x64.zip"

echo "-- download latest Hayabusa --"
get_latest_github_release "$DOWNLOAD_FOLDER" "Yamato-Security/hayabusa" "hayabusa-.*-win-x64\\.zip$"
get_latest_github_release "$DOWNLOAD_FOLDER" "Yamato-Security/hayabusa" "hayabusa-.*-win-x64-live-response\\.zip$"

echo "-- download latest Loki --"
get_latest_github_release "$DOWNLOAD_FOLDER" "Neo23x0/Loki" "loki.*\\.zip$"

echo "-- download Thor --"
curl -L -o "$DOWNLOAD_FOLDER/thor.zip" "https://update1.nextron-systems.com/getupdate.php?product=thor10lite-win"

echo "-- download Velociraptor Sigma Artifacts --"
get_file "$DOWNLOAD_FOLDER" "https://sigma.velocidex.com/Velociraptor.Sigma.Artifacts.zip"

echo "-- download Rapid7Labs VQL --"
get_file "$DOWNLOAD_FOLDER" "https://github.com/rapid7/Rapid7-Labs/raw/main/Vql/release/Rapid7LabsVQL.zip"

echo "-- download Registry Hunter --"
get_file "$DOWNLOAD_FOLDER" "https://registry-hunter.velocidex.com/Windows.Registry.Hunter.zip"

echo "-- download SQLiteHunter --"
get_file "$DOWNLOAD_FOLDER" "https://sqlitehunter.velocidex.com/SQLiteHunter.zip"

echo "-- download Triage Artifacts --"
get_file "$DOWNLOAD_FOLDER" "https://triage.velocidex.com/artifacts/Velociraptor_Triage_v0.1.zip"

echo "-- download 10Root Artifacts --"
curl -L -o "$DOWNLOAD_FOLDER/10root_artifacts.zip" "https://github.com/10RootOrg/Velociraptor-Artifacts/archive/refs/heads/main.zip"

echo "-- download DetectRaptor YARA rules --"
get_file "$DOWNLOAD_FOLDER" "https://github.com/mgreen27/DetectRaptor/raw/master/yara/full_windows_file.yar.gz"
get_file "$DOWNLOAD_FOLDER" "https://github.com/mgreen27/DetectRaptor/raw/master/yara/full_linux_file.yar.gz"
get_file "$DOWNLOAD_FOLDER" "https://github.com/mgreen27/DetectRaptor/raw/master/yara/yara-rules-full.yar"

echo "-- download latest YaraForge --"
get_latest_github_release "$DOWNLOAD_FOLDER" "YARAHQ/yara-forge" ".*core\\.zip$"
get_latest_github_release "$DOWNLOAD_FOLDER" "YARAHQ/yara-forge" ".*extended\\.zip$"
get_latest_github_release "$DOWNLOAD_FOLDER" "YARAHQ/yara-forge" ".*full\\.zip$"

echo "-- download latest Yara --"
get_latest_github_release "$DOWNLOAD_FOLDER" "VirusTotal/yara" "yara.*-win32\\.zip$"
get_latest_github_release "$DOWNLOAD_FOLDER" "VirusTotal/yara" "yara.*-win64\\.zip$"

echo "-- download latest Takajo --"
get_latest_github_release "$DOWNLOAD_FOLDER" "Yamato-Security/takajo" "takajo.*-win-x64\\.zip$"

echo "-- download DetectRaptor LOLRMM CSV --"
get_file "$DOWNLOAD_FOLDER" "https://github.com/mgreen27/DetectRaptor/raw/master/csv/lolrmm.csv"

echo "-- download Linforce script --"
get_file "$DOWNLOAD_FOLDER" "https://raw.githubusercontent.com/RCarras/linforce/main/linforce.sh"

echo "-- download Volatility --"
curl -L -o "$DOWNLOAD_FOLDER/volatility.zip" "https://github.com/volatilityfoundation/volatility/archive/master.zip"

echo "-- download Sigma profiles --"
get_file "$DOWNLOAD_FOLDER" "https://sigma.velocidex.com/profiles.json"

echo "-- download Eric Zimmerman Tools (.NET 4) --"
get_file "$DOWNLOAD_FOLDER" "https://download.ericzimmermanstools.com/AmcacheParser.zip"
get_file "$DOWNLOAD_FOLDER" "https://download.ericzimmermanstools.com/AppCompatCacheParser.zip"
get_file "$DOWNLOAD_FOLDER" "https://download.ericzimmermanstools.com/bstrings.zip"
get_file "$DOWNLOAD_FOLDER" "https://download.ericzimmermanstools.com/EvtxECmd.zip"
get_file "$DOWNLOAD_FOLDER" "https://download.ericzimmermanstools.com/hasher.zip"
get_file "$DOWNLOAD_FOLDER" "https://download.ericzimmermanstools.com/JLECmd.zip"
get_file "$DOWNLOAD_FOLDER" "https://download.ericzimmermanstools.com/LECmd.zip"
get_file "$DOWNLOAD_FOLDER" "https://download.ericzimmermanstools.com/MFTECmd.zip"
get_file "$DOWNLOAD_FOLDER" "https://download.ericzimmermanstools.com/PECmd.zip"
get_file "$DOWNLOAD_FOLDER" "https://download.ericzimmermanstools.com/RBCmd.zip"
get_file "$DOWNLOAD_FOLDER" "https://download.ericzimmermanstools.com/RecentFileCacheParser.zip"
get_file "$DOWNLOAD_FOLDER" "https://download.ericzimmermanstools.com/RECmd.zip"
get_file "$DOWNLOAD_FOLDER" "https://download.ericzimmermanstools.com/rla.zip"
get_file "$DOWNLOAD_FOLDER" "https://download.ericzimmermanstools.com/SBECmd.zip"
get_file "$DOWNLOAD_FOLDER" "https://download.ericzimmermanstools.com/SrumECmd.zip"
get_file "$DOWNLOAD_FOLDER" "https://download.ericzimmermanstools.com/SumECmd.zip"
get_file "$DOWNLOAD_FOLDER" "https://download.ericzimmermanstools.com/iisGeolocate.zip"

echo "-- download Sysinternals Tools --"
get_file "$DOWNLOAD_FOLDER" "https://live.sysinternals.com/tools/autorunsc64.exe"
get_file "$DOWNLOAD_FOLDER" "https://live.sysinternals.com/tools/disk2vhd64.exe"
get_file "$DOWNLOAD_FOLDER" "https://live.sysinternals.com/tools/procexp64.exe"
get_file "$DOWNLOAD_FOLDER" "https://live.sysinternals.com/tools/sigcheck64.exe"
get_file "$DOWNLOAD_FOLDER" "https://live.sysinternals.com/tools/strings64.exe"
get_file "$DOWNLOAD_FOLDER" "https://live.sysinternals.com/tools/Sysmon64.exe"

echo "-- download PingCastle --"
get_latest_github_release "$DOWNLOAD_FOLDER" "netwrix/pingcastle" "ping.*\\.zip$"

echo "-- download HardeningKitty --"
curl -L -o "$DOWNLOAD_FOLDER/HardeningKitty.zip" "https://github.com/0x6d69636b/windows_hardening/archive/refs/heads/master.zip"

echo "-- download Microsoft Malicious Software Removal Tool (KB890830) --"
curl -L -o "$DOWNLOAD_FOLDER/Windows-KB890830-x64-MRT.exe" "https://go.microsoft.com/fwlink/?LinkId=212732"

echo "-- download FTK Imager Command Line --"
curl -L -o "$DOWNLOAD_FOLDER/FTKImager-commandline.zip" "https://www.dropbox.com/scl/fi/juz70umd0clt2np4hf0d6/FTKImager-commandline.zip?rlkey=0320go01k20eyh3qutwb0pwg0&dl=1"

echo "-- download latest Chainsaw --"
get_latest_github_release "$DOWNLOAD_FOLDER" "WithSecureLabs/chainsaw" "chainsaw_all_platforms\\+rules.*\\.zip$"

echo ""
echo "Download finished, Please add Thor license manually"
