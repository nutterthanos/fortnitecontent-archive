#!/bin/bash

# Function to compare Etag values
compare_etag() {
    local url=$1
    local etag=$2
    local stored_etag=$(grep -Po "\"$url\":\s*\"\K[^\"]+" Etag.json)

    if [[ "$etag" != "$stored_etag" ]]; then
        echo "Downloading $url..."
        new_etag=$(curl -sI "$url" | grep -i "etag" | awk -F'"' '{print $2}')

        # Update the Etag value in the JSON file
        if ! sed -i "s|\"$url\":\s*\"[^\"]*\"|\"$url\": \"$new_etag\"|" Etag.json; then
            echo "Failed to update Etag value in Etag.json"
            return 1
        fi

        # Download the file
        if ! curl -s -O "$url"; then
            echo "Failed to download $url"
            return 1
        fi
    else
        echo "No update available for $url"
    fi
}

# List of URLs to download
urls=(
    "https://fortnitecontent-website-prod07.ol.epicgames.com/content/api/pages/fortnite-game"
    "https://fortnitecontent-website-prod07.ol.epicgames.com/content/api/pages/fortnite-game/athenamessage"
    "https://fortnitecontent-website-prod07.ol.epicgames.com/content/api/pages/fortnite-game/battlepassaboutmessages"
    "https://fortnitecontent-website-prod07.ol.epicgames.com/content/api/pages/fortnite-game/battlepasspurchase"
    "https://fortnitecontent-website-prod07.ol.epicgames.com/content/api/pages/fortnite-game/battleroyalenews"
    "https://fortnitecontent-website-prod07.ol.epicgames.com/content/api/pages/fortnite-game/battleroyalenewsv2"
    "https://fortnitecontent-website-prod07.ol.epicgames.com/content/api/pages/fortnite-game/comics"
    "https://fortnitecontent-website-prod07.ol.epicgames.com/content/api/pages/fortnite-game/creative-ads"
    "https://fortnitecontent-website-prod07.ol.epicgames.com/content/api/pages/fortnite-game/creative-features"
    "https://fortnitecontent-website-prod07.ol.epicgames.com/content/api/pages/fortnite-game/creativenews"
    "https://fortnitecontent-website-prod07.ol.epicgames.com/content/api/pages/fortnite-game/creativenewsv2"
    "https://fortnitecontent-website-prod07.ol.epicgames.com/content/api/pages/fortnite-game/crewscreendata"
    "https://fortnitecontent-website-prod07.ol.epicgames.com/content/api/pages/fortnite-game/dynamicbackgrounds"
    "https://fortnitecontent-website-prod07.ol.epicgames.com/content/api/pages/fortnite-game/emergencynotice"
    "https://fortnitecontent-website-prod07.ol.epicgames.com/content/api/pages/fortnite-game/emergencynoticev2"
    "https://fortnitecontent-website-prod07.ol.epicgames.com/content/api/pages/fortnite-game/eventscreens"
    "https://fortnitecontent-website-prod07.ol.epicgames.com/content/api/pages/fortnite-game/koreancafe"
    "https://fortnitecontent-website-prod07.ol.epicgames.com/content/api/pages/fortnite-game/leaderboardinformation"
    "https://fortnitecontent-website-prod07.ol.epicgames.com/content/api/pages/fortnite-game/lobby"
    "https://fortnitecontent-website-prod07.ol.epicgames.com/content/api/pages/fortnite-game/loginmessage"
    "https://fortnitecontent-website-prod07.ol.epicgames.com/content/api/pages/fortnite-game/media-events"
    "https://fortnitecontent-website-prod07.ol.epicgames.com/content/api/pages/fortnite-game/media-events-v2"
    "https://fortnitecontent-website-prod07.ol.epicgames.com/content/api/pages/fortnite-game/platformpurchasemessaging"
    "https://fortnitecontent-website-prod07.ol.epicgames.com/content/api/pages/fortnite-game/playersurvey"
    "https://fortnitecontent-website-prod07.ol.epicgames.com/content/api/pages/fortnite-game/playersurveyv2"
    "https://fortnitecontent-website-prod07.ol.epicgames.com/content/api/pages/fortnite-game/playlistinformation"
    "https://fortnitecontent-website-prod07.ol.epicgames.com/content/api/pages/fortnite-game/radio-stations"
    "https://fortnitecontent-website-prod07.ol.epicgames.com/content/api/pages/fortnite-game/savetheworldnews"
    "https://fortnitecontent-website-prod07.ol.epicgames.com/content/api/pages/fortnite-game/scoringrulesinformation"
    "https://fortnitecontent-website-prod07.ol.epicgames.com/content/api/pages/fortnite-game/shop-carousel"
    "https://fortnitecontent-website-prod07.ol.epicgames.com/content/api/pages/fortnite-game/shop-sections"
    "https://fortnitecontent-website-prod07.ol.epicgames.com/content/api/pages/fortnite-game/socialevents"
    "https://fortnitecontent-website-prod07.ol.epicgames.com/content/api/pages/fortnite-game/specialoffervideo"
    "https://fortnitecontent-website-prod07.ol.epicgames.com/content/api/pages/fortnite-game/subgameinfo"
    "https://fortnitecontent-website-prod07.ol.epicgames.com/content/api/pages/fortnite-game/subgameselectdata"
    "https://fortnitecontent-website-prod07.ol.epicgames.com/content/api/pages/fortnite-game/subscription"
    "https://fortnitecontent-website-prod07.ol.epicgames.com/content/api/pages/fortnite-game/survivalmessage"
    "https://fortnitecontent-website-prod07.ol.epicgames.com/content/api/pages/fortnite-game/tournamentinformation"
    "https://fortnitecontent-website-prod07.ol.epicgames.com/content/api/pages/fortnite-game/mp-item-shop"
)

# Function to calculate SHA-1 hash of a file in the latest commit
calculate_sha1() {
    local file=$1
    local sha1_hash=$(git log -n 1 --pretty=format:"%H" -- "$file" | xargs -I{} git cat-file -p {}:"$file" | sha1sum | awk '{ print $1 }')
    echo "$sha1_hash"
}

# List of files/directories to exclude
excluded_files=("Etag.json" "README.md" ".git" ".github" ".github/workflows" ".github/workflows/etags.yml" "Archive.sh")

# Create an empty Etag.json file if it doesn't exist
if [[ ! -f "Etag.json" ]]; then
    echo "{}" > Etag.json
fi

# Clear the existing content of README.md and add header information to README.md
echo "Fortnite-Content Archive" > README.md
echo "" >> README.md
echo "Archiving https://fortnitecontent-website-prod07.ol.epicgames.com/content/api/pages/fortnite-game and all respective pages" >> README.md
echo "" >> README.md
echo "Fortnite-Content Files and SHA1 Hashes:" >> README.md
echo "" >> README.md

# Iterate through the URLs
for url in "${urls[@]}"; do
    etag=$(curl -sI $url | grep -i "etag" | awk -F'"' '{print $2}')
    compare_etag $url $etag
done

# Iterate through the files in the repository and append to README.md
for file in $(git ls-files); do
    # Check if the file is not in the excluded list
    if ! [[ " ${excluded_files[@]} " =~ " $file " ]]; then
        sha1=$(calculate_sha1 "$file")
        echo "$file | $sha1" >> README.md
        echo "" >> README.md  # Add a newline character after each entry
    fi
done
