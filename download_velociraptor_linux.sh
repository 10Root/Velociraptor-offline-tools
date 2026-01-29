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

# Function to download a file matching a pattern from a web page
get_file_from_page() {
    local output_folder="$1"
    local page_url="$2"
    local pattern="$3"

    local file_url=$(curl -s "$page_url" | grep -oP 'href="\K[^"]*' | grep -E "$pattern" | head -1)

    if [ -z "$file_url" ]; then
        echo "ERROR: No link found matching pattern: $pattern on $page_url"
        return 1
    fi

    # Handle relative URLs
    if [[ ! "$file_url" =~ ^https?:// ]]; then
        local base_url=$(echo "$page_url" | grep -oP '^https?://[^/]+')
        file_url="${base_url}${file_url}"
    fi

    local filename=$(basename "$file_url" | cut -d'?' -f1)
    echo "Downloading $filename..."
    curl -L -o "$output_folder/$filename" "$file_url"
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

# Ask user about optional large downloads
DO_DOWNLOAD_BENTO=false
DO_DOWNLOAD_FORENSICTOOLS=false

read -p "Download Bento Toolkit? (y/n): " ANSWER_BENTO
if [ "$ANSWER_BENTO" = "y" ]; then
    existing_bento=$(ls -1 "$DOWNLOAD_FOLDER"/bento_* 2>/dev/null | sort -V | tail -1)
    if [ -n "$existing_bento" ]; then
        echo "  On disk: $(basename "$existing_bento")"
    else
        echo "  On disk: not found"
    fi
    latest_bento=$(curl -s "https://tsurugi-linux.org/mirrors/mirror1.php" | grep -oP 'href="\K[^"]*' | grep -E "bento_.*\.7z" | head -1)
    if [ -n "$latest_bento" ]; then
        echo "  Latest:  $(basename "$latest_bento")"
    else
        echo "  Latest:  could not determine"
    fi
    read -p "  Proceed with download? (y/n): " CONFIRM_BENTO
    if [ "$CONFIRM_BENTO" = "y" ]; then DO_DOWNLOAD_BENTO=true; fi
fi

read -p "Download ForensicTools Kit? (y/n): " ANSWER_FORENSICTOOLS
if [ "$ANSWER_FORENSICTOOLS" = "y" ]; then
    existing_ft=$(ls -1 "$DOWNLOAD_FOLDER"/forensictools_* 2>/dev/null | sort -V | tail -1)
    if [ -n "$existing_ft" ]; then
        echo "  On disk: $(basename "$existing_ft")"
    else
        echo "  On disk: not found"
    fi
    latest_ft=$(curl -s "https://api.github.com/repos/cristianzsh/forensictools/releases" | jq -r '.[0].assets[] | select(.name | test("forensictools.*setup\\.exe$")) | .name' | head -1)
    if [ -n "$latest_ft" ]; then
        echo "  Latest:  $latest_ft"
    else
        echo "  Latest:  could not determine"
    fi
    read -p "  Proceed with download? (y/n): " CONFIRM_FT
    if [ "$CONFIRM_FT" = "y" ]; then DO_DOWNLOAD_FORENSICTOOLS=true; fi
fi

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

echo "-- download latest Loki-RS --"
get_latest_github_release "$DOWNLOAD_FOLDER" "Neo23x0/Loki-RS" "loki-linux-x86_64.*\\.tar\\.gz$"

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
get_file "$DOWNLOAD_FOLDER" "https://download.ericzimmermanstools.com/net6/TimelineExplorer.zip"

echo "-- download Sysinternals Tools --"
get_file "$DOWNLOAD_FOLDER" "https://live.sysinternals.com/tools/autorunsc64.exe"
get_file "$DOWNLOAD_FOLDER" "https://live.sysinternals.com/tools/disk2vhd64.exe"
get_file "$DOWNLOAD_FOLDER" "https://live.sysinternals.com/tools/procexp64.exe"
get_file "$DOWNLOAD_FOLDER" "https://live.sysinternals.com/tools/sigcheck64.exe"
get_file "$DOWNLOAD_FOLDER" "https://live.sysinternals.com/tools/strings64.exe"
get_file "$DOWNLOAD_FOLDER" "https://live.sysinternals.com/tools/Sysmon64.exe"

if $DO_DOWNLOAD_BENTO; then
    echo "-- download Bento Toolkit --"
    get_file_from_page "$DOWNLOAD_FOLDER" "https://tsurugi-linux.org/mirrors/mirror1.php" "bento_.*\.7z"
fi

if $DO_DOWNLOAD_FORENSICTOOLS; then
    echo "-- download ForensicTools Kit --"
    get_latest_github_release "$DOWNLOAD_FOLDER" "cristianzsh/forensictools" "forensictools.*setup\\.exe$"
fi

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
