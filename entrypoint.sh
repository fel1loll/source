#!/bin/bash

# Wait for the container to fully initialize
sleep 1

# hora chile
TZ=America/Santiago
export TZ

cd /home/container || exit 1

# Terminal Colors variables are not used, but only here for easier reference.
BOLD_WHITE='\033[1;37m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
RESET_COLOR='\033[0m'

# Set environment variable that holds the Internal Docker IP
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# Available Egg Variables

###################################################################################################################
# SRCDS_APPID - Steam App ID of the game server (required) (ex: 740)                                              #
# SRCDS_BETAID - Steam App Beta ID of the game server (optional) (ex: 123456)                                     #
# SRCDS_BETAPASS - Steam App Beta Password of the game server (optional) (ex: password)                           #
# SOURCEMOD - Whether to install and update sourcemod/metamod on each startup (optional) (ex: 1, true, false, 0)  #
# SM_VERSION - Sourcemod version to install (optional) (ex: 1.11) (default: latest)                               #
# MM_VERSION - Metamod version to install (optional) (ex: 1.11) (default: latest)                                 #
# INSTALL_PATH - Path to install sourcemod/metamod to (optional) (ex: csgo) (default: csgo)                       #
###################################################################################################################

# Auto detect the game install path by looking for the most common game folders. Default to csgo if none are found or provided by the user.
INSTALL_PATH="${INSTALL_PATH:-csgo}"

detect_install_path() {
    SUPPORTED_GAMES=("csgo" "tf" "css" "dod" "cstrike" "left4dead" "left4dead2" "contagion" "alienswarm" "orangebox" "orangebox_valve" "sdk2013" "original" "darkmessiah" "bloodygoodtime" "eye" "blade" "insurgency" "pvkii" "mcv" "hl2mp" "ship")

    for i in "${SUPPORTED_GAMES[@]}"; do
        if [[ -d /home/container/"${i}" ]]; then
            INSTALL_PATH="${i}"
        fi
    done
    print_bold_white "Current detected game install folder is: ${INSTALL_PATH}"
}

# Update Server
if [[ -n ${SRCDS_APPID} ]]; then
    if [[ -n ${SRCDS_BETAID} ]]; then
        if [[ -n ${SRCDS_BETAPASS} ]]; then
            ./steamcmd/steamcmd.sh +force_install_dir /home/container +login anonymous +app_update "${SRCDS_APPID}" -beta "${SRCDS_BETAID}" -betapassword "${SRCDS_BETAPASS}" +quit
        else
            ./steamcmd/steamcmd.sh +force_install_dir /home/container +login anonymous +app_update "${SRCDS_APPID}" -beta "${SRCDS_BETAID}" +quit
        fi
    else
        ./steamcmd/steamcmd.sh +force_install_dir /home/container +login anonymous +app_update "${SRCDS_APPID}" +quit
    fi
fi

cd /home/container || exit 1

# Replace Startup Variables
# shellcheck disable=SC2086
MODIFIED_STARTUP=$(eval echo "$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')")

# Display the parsed startup string we're going to execute.
print_yellow "[Startup Command]: ${BOLD_WHITE} ${MODIFIED_STARTUP}\n"

# Run the Server
# shellcheck disable=SC2086
eval ${MODIFIED_STARTUP}
