#!/bin/bash

# Downloads the latest Slack DMG to /private/tmp
slackDownloadUrl=$(curl "https://slack.com/ssb/download-osx-universal" -s -L -I -o /dev/null -w '%{url_effective}')
dmgName=$(basename "$slackDownloadUrl")
slackDmgPath="/private/tmp/$dmgName"
echo "Downloading latest Slack (${dmgName})..."
curl -L -o "$slackDmgPath" "$slackDownloadUrl"

#error checking
if [ $? -ne 0 ]; then
    echo "ERROR: Unable to download Slack. Exiting."
    exit 1
fi

# Eject any existing Slack volumes
if ls /Volumes | grep -q "^Slack"; then
    echo "Ejecting existing Slack volumes..."
    for disk in $(hdiutil info | grep /dev/disk | grep partition | cut -f1); do
        hdiutil detach "$disk"
    done
fi

echo "Mounting Slack DMG..."
hdiutil attach -nobrowse "$slackDmgPath"

###############################################
# VERSION CHECK
###############################################

DMG_APP=$(echo /Volumes/Slack*/Slack.app)
INSTALLED_APP="/Applications/Slack.app"

# Get the version number of the downloaded Slack DMG
DMG_VERSION=$(/usr/bin/defaults read "$DMG_APP/Contents/Info" CFBundleShortVersionString 2>/dev/null)

# Get the version number of the installed Slack DMG
if [ -d "$INSTALLED_APP" ]; then
    INSTALLED_VERSION=$(/usr/bin/defaults read "$INSTALLED_APP/Contents/Info" CFBundleShortVersionString 2>/dev/null)
else
    INSTALLED_VERSION="0"
fi

echo "Slack version in DMG: $DMG_VERSION"
echo "Slack installed version: $INSTALLED_VERSION"

# Version compare function
version_compare() {
    if [[ "$1" == "$2" ]]; then return 0; fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # pad shorter array
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++)); do ver1[i]=0; done
    for ((i=${#ver2[@]}; i<${#ver1[@]}; i++)); do ver2[i]=0; done
    for ((i=0; i<${#ver1[@]}; i++)); do
        if ((10#${ver1[i]} > 10#${ver2[i]})); then return 1; fi
        if ((10#${ver1[i]} < 10#${ver2[i]})); then return 2; fi
    done
    return 0
}

version_compare "$DMG_VERSION" "$INSTALLED_VERSION"
COMPARE_RESULT=$?

# Only install if DMG version is newer (COMPARE_RESULT = 1)
if [ $COMPARE_RESULT -ne 1 ]; then
    echo "Installed version is newer or equal. Skipping install."
    echo "Cleaning up..."
    hdiutil detach /Volumes/Slack*
    rm -f "$slackDmgPath"
    exit 0
fi

###############################################
# END VERSION CHECK
###############################################

# Install/update Slack in /Applications
echo "Installing or updating Slack..."
ditto -rsrc /Volumes/Slack*/Slack.app /Applications/Slack.app
echo "Slack installed/updated successfully."

# Eject DMG
echo "Ejecting Slack DMG..."
hdiutil detach /Volumes/Slack.app

# Cleanup
echo "Cleaning up..."
rm -f "$slackDmgPath"
echo "Done."
