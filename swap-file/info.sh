#!/bin/sh

SWAP_PATH=${1:-"/alis-swap"}

ALREADY_ALLOCATED=$(swapon --show --bytes | grep "$SWAP_PATH" | awk '{ print $3 }') 
ALREADY_ALLOCATED=$((${ALREADY_ALLOCATED:-0} / 1024))

printf "{ \"size\": \"%s\"}" "$ALREADY_ALLOCATED"