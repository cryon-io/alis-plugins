#!/bin/sh

SWAP_SIZE="$1"
if [ -z "$SWAP_SIZE" ]; then 
    printf "Swap size not specified!\n" 
    exit 1
fi
# here we count k,m,g bytes as by multiplyin 1000 (not 1024) to accept slight difference in swap value
SWAP_SIZE_MIN=$((SWAP_SIZE * 1000))
SWAP_SIZE_MAX=$((SWAP_SIZE * 1048))
SWAP_PATH=${2:-"/alis-swap"}

ALREADY_ALOCATED=$(swapon --show --bytes | grep "$SWAP_PATH" | awk '{ print $3 }') 
ALREADY_ALOCATED=$((${ALREADY_ALOCATED:-0} / 1024))

if [ "$ALREADY_ALOCATED" -ge "$SWAP_SIZE_MIN" ] && [ "$ALREADY_ALOCATED" -le "$SWAP_SIZE_MAX" ]; then 
    # swap already configured exit
    printf "Swap already configured in required size.\n"
    exit 0
elif [ ! "$ALREADY_ALOCATED" = "0" ]; then 
    printf "Found smaller or bigger swap file. Reconfiguring ... \n"
    swapoff "$SWAP_PATH"
fi

TARGET_SWAP_SPACE=$SWAP_SIZE_MAX
AVAILABLE_SPACE=$(($(df / | tail -n 1 | awk '{ print $4 }') + ALREADY_ALOCATED))
if [ "$AVAILABLE_SPACE" -lt "$TARGET_SWAP_SPACE" ]; then 
    printf "Not enough free space. Available swapspace: %s\n" "$AVAILABLE_SPACE"
    exit 2
fi
printf "Creating swap file of required size...\n"
dd if=/dev/zero of="$SWAP_PATH" bs=1024 count=$TARGET_SWAP_SPACE || exit 3
printf "Configuring swap...\n"
chmod 600 "$SWAP_PATH" || exit 4
mkswap "$SWAP_PATH" && swapon "$SWAP_PATH" || exit 5

ALREADY_ALOCATED=$(swapon --show --bytes | grep "$SWAP_PATH" | awk '{ print $3 }') 
ALREADY_ALOCATED=$((${ALREADY_ALOCATED:-0} / 1024))

if [ "$ALREADY_ALOCATED" -lt "$SWAP_SIZE_MIN" ]; then 
    # swap configuration failed
    exit 6
fi