#!/bin/sh

# This script is used in the SDK CIs to fetch the latest MeiliSearch RC name (ex: v0.16.0).
# The MeiliSearch RC is needed when maintainers are developing features during the pre-release week because the final MeiliSearch release is not out yet.
# Verifier que c'est PAS rc

temp_file='temp_file' # temp_file needed because `grep` would start before the download is over
curl -s 'https://api.github.com/repos/meilisearch/MeiliSearch/releases' > "$temp_file" -i
cat temp_file
latest_ms_release=$(cat "$temp_file" \
    | grep -E 'tag_name' | grep 'v0' | head -1 \
    | tr -d ',"' | cut -d ':' -f2 | tr -d ' ')
rm -rf "$temp_file"
echo "$latest_ms_release"
exit 0
