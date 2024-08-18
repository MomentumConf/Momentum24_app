#!/usr/bin/env bash

SETTINGS_FILE="settings.json"
COLORS_FILE="lib/colors.dart"
CLIENT_FILE="lib/client.dart"
MAIN_FILE="lib/main.dart"
INDEX_FILE="web/index.html"
MANIFEST_FILE="web/manifest.json"
ASSETS_DIR="assets/images"
ICONS_DIR="web/icons"
FAVICON_FILE="web/favicon.png"


create_colors_file() {
    echo "Creating $COLORS_FILE"
  cat <<EOL > $COLORS_FILE
import 'dart:ui';

const Color primaryColor = Color(0xFF${MAIN_COLOR:1});
const Color secondaryColor = Color(0xFF${SECONDARY_COLOR:1});
const Color highlightColor = Color(0xFF${HIGHLIGHT_COLOR:1});
const Color textColor = Color(0xFF${TEXT_COLOR:1});
EOL

    cat $COLORS_FILE
}

update_titles() {
  echo "Updating titles in $INDEX_FILE and $MAIN_FILE"
  sed -i "s/%TITLE%/${APP_NAME}/g" $INDEX_FILE
  sed -i "s/%DESCRIPTION%/${APP_DESCRIPTION}/" $INDEX_FILE
  sed -i "s/%TITLE%/${APP_NAME}/" $MAIN_FILE
}

update_manifest_json() {
  echo "Updating manifest.json"
  SHORT_NAME=$(echo $APP_NAME | awk '{print $NF}')
  jq --arg appName "$APP_NAME" --arg description "$APP_DESCRIPTION" --arg shortName "$SHORT_NAME" --arg themeColor "$MAIN_COLOR" \
    '.name = $appName | .description = $description | .short_name = $shortName | .theme_color = $themeColor | .background_color = $themeColor' \
    $MANIFEST_FILE > $MANIFEST_FILE.tmp && mv $MANIFEST_FILE.tmp $MANIFEST_FILE
}

download_images() {
    echo "Downloading images"
    wget -q -O $ASSETS_DIR/logo.svg $LOGO
    wget -q -O $ASSETS_DIR/mowcy.jpg $SPEAKERS_TILE_IMAGE
    wget -q -O $ASSETS_DIR/regulamin.jpg $REGULATIONS_TILE_IMAGE
    wget -q -O $ASSETS_DIR/teksty.jpg $SONGS_TILE_IMAGE
}

download_and_resize_icons() {
  mkdir -p $ICONS_DIR
  local BASE_URL="${APP_ICON}?w="
  declare -A SIZES=( ["57"]="57" ["60"]="60" ["72"]="72" ["76"]="76" ["96"]="96" ["114"]="114" ["120"]="120" ["128"]="128" ["144"]="144" ["152"]="152" ["180"]="180" ["192"]="192" ["256"]="256" ["384"]="384" ["512"]="512" )

  for size in "${!SIZES[@]}"; do
    echo "Downloading ${size}x${size} icon"
    wget -q -O $ICONS_DIR/Icon-${size}.png "${BASE_URL}${size}&h=${size}" || echo "Failed to download ${size}x${size} icon"
  done
}

copy_icon_to_assets() {
  cp $ICONS_DIR/Icon-512.png $ASSETS_DIR/icon.png
}

create_favicon() {
  local BASE_URL="${APP_ICON}?w=32&h=32"
  wget -O $FAVICON_FILE $BASE_URL
}

parse_settings() {
  MAIN_COLOR=$(jq -r '.mainColor' $SETTINGS_FILE)
  SECONDARY_COLOR=$(jq -r '.secondaryColor' $SETTINGS_FILE)
  HIGHLIGHT_COLOR=$(jq -r '.highlightColor' $SETTINGS_FILE)
  TEXT_COLOR=$(jq -r '.textColor' $SETTINGS_FILE)
  APP_NAME=$(jq -r '.appName' $SETTINGS_FILE)
  APP_DESCRIPTION=$(jq -r '.description' $SETTINGS_FILE)
  LOGO=$(jq -r '.logo' $SETTINGS_FILE)
  SPEAKERS_TILE_IMAGE=$(jq -r '.speakersTileImage' $SETTINGS_FILE)
  REGULATIONS_TILE_IMAGE=$(jq -r '.regulationsTileImage' $SETTINGS_FILE)
  SONGS_TILE_IMAGE=$(jq -r '.songsTileImage' $SETTINGS_FILE)
  APP_ICON=$(jq -r '.appIcon' $SETTINGS_FILE)
  ANALYTICS_ID=$(jq -r '.analyticsId' $SETTINGS_FILE)
}

update_project_id() {
  sed -i "s/_paq.push(\[\"setSiteId\", \"[0-9]*\"\])/_paq.push(\[\"setSiteId\", \"${ANALYTICS_ID}\"\])/" $INDEX_FILE
  sed -i "s/appId: .*,$/appId: '${ONESIGNAL_APPID}',/g" $INDEX_FILE
}

main() {
  parse_settings
  create_colors_file
  update_titles
  update_manifest_json
  download_and_resize_icons
  download_images
  copy_icon_to_assets
  create_favicon
  update_project_id
}

main