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
        if ! sed -i "s/\"$url\":\s*\"[^\"]*\"/\"$url\": \"$new_etag\"/" Etag.json; then
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
)

# Create an empty Etag.json file if it doesn't exist
if [[ ! -f "Etag.json" ]]; then
    echo "{}" > Etag.json
fi

# Iterate through the URLs
for url in "${urls[@]}"; do
    etag=$(curl -sI $url | grep -i "etag" | awk -F'"' '{print $2}')
    compare_etag $url $etag
done