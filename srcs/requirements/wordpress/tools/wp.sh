#!/bin/bash
if [ -f /run/secrets/credentials ]; then
    while IFS='=' read -r key value; do
        if [[ ! $key =~ ^# && -n $key ]]; then
            export "$key=$(echo "$value" | sed 's/^"\(.*\)"$/\1/')"
		else
			export "$key=$(echo "$value" | sed 's/^"\(.*\)"$/\1/')"
        fi
    done < /run/secrets/credentials
else
    echo "Error: /run/secrets/credentials file not found."
    exit 1
fi

env > /credentials