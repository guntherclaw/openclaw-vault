#!/usr/bin/env bash
set -euo pipefail

GOG=/home/linuxbrew/.linuxbrew/bin/gog

# Load environment (GOG_ACCOUNT, GOG_KEYRING_PASSWORD)
if [ -f ~/.openclaw/.env ]; then
    set -a
    # shellcheck disable=SC1090
    source ~/.openclaw/.env
    set +a
fi

ACCOUNT="${GOG_ACCOUNT:-guntherclawliver@gmail.com}"

echo "Re-authenticating gog for: $ACCOUNT"
echo "A browser window will open — complete the Google sign-in, then return here."
echo ""

exec "$GOG" auth add "$ACCOUNT" \
    --services gmail,calendar,drive,contacts,docs,sheets,tasks
