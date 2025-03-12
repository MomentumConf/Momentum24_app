#!/usr/bin/env bash

SETTINGS_FILE="settings.json"
COLORS_FILE="lib/colors.dart"
INDEX_FILE="web/index.html"
MANIFEST_FILE="web/manifest.json"
ASSETS_DIR="assets/images"
ICONS_DIR="web/icons"
FAVICON_FILE="web/favicon.png"


update_indexhtml() {
  echo "Updating titles in $INDEX_FILE"
  awk -i inplace -v app_name="$APP_NAME" -v app_desc="$APP_DESCRIPTION" -v main_color="$MAIN_COLOR" -v version="$VERSION" '{
    gsub(/%TITLE%/, app_name);
    gsub(/%DESCRIPTION%/, app_desc);
    gsub(/%MAIN_COLOR%/, main_color);
    gsub(/%VERSION%/, version);
    print;
  }' $INDEX_FILE
  awk -i inplace -v version="$VERSION" '{
    gsub(/version: .*/, "version: " version);
    print;
  }' pubspec.yaml
}

update_manifest_json() {
  echo "Updating manifest.json"
  SHORT_NAME=$(echo $APP_NAME | awk '{print $NF}')
  jq --arg appName "$APP_NAME" --arg description "$APP_DESCRIPTION" --arg shortName "$SHORT_NAME" --arg themeColor "$MAIN_COLOR" --arg version "$VERSION" \
    '.name = $appName | .description = $description | .short_name = $shortName | .theme_color = $themeColor | .background_color = $themeColor | .version = $version' \
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

create_theme_file() {
  echo "Creating $THEME_FILE"
  python3 -c "
import json
from string import Template

with open('${SETTINGS_FILE}', 'r') as f:
    settings = json.load(f)
    colors = {name: color.replace('#', '0xFF') for name, color in settings.items() if type(color) == str and color.startswith('#')}

with open('${COLORS_FILE}', 'r+') as f:
    file_content = f.read()
    template = Template(file_content)
    f.seek(0)
    f.truncate()
    try:
        content = template.substitute(**colors)
        f.write(content)
    except Exception as e:
        print(f'Error: {e}')
        f.write(file_content)
        raise e
"

  if [ $? -eq 0 ]; then
    echo "Theme file created"
  else
    echo "Error: Failed to create theme file" >&2
    exit 1
  fi
}

parse_settings() {
  MAIN_COLOR=$(jq -r '.mainColor' $SETTINGS_FILE)
  APP_NAME=$(jq -r '.appName' $SETTINGS_FILE)
  APP_DESCRIPTION=$(jq -r '.description' $SETTINGS_FILE)
  LOGO=$(jq -r '.logo' $SETTINGS_FILE)
  SPEAKERS_TILE_IMAGE=$(jq -r '.speakersTileImage' $SETTINGS_FILE)
  REGULATIONS_TILE_IMAGE=$(jq -r '.regulationsTileImage' $SETTINGS_FILE)
  SONGS_TILE_IMAGE=$(jq -r '.songsTileImage' $SETTINGS_FILE)
  APP_ICON=$(jq -r '.appIcon' $SETTINGS_FILE)
  ANALYTICS_ID=$(jq -r '.analyticsId' $SETTINGS_FILE)
  ENABLED_MODULES=$(jq -c '.enabledModules' $SETTINGS_FILE)
}

prepare_dotenv_file() {
  echo "SENTRY_DSN=$SENTRY_DSN" > .env
  echo "SANITY_PROJECT_ID=$SANITY_PROJECT_ID" >> .env
  echo "ONESIGNAL_APPID=$ONESIGNAL_APPID" >> .env
  echo "TITLE=$APP_NAME" >> .env
  echo "ENABLED_MODULES=$(echo $ENABLED_MODULES | jq -r 'join(";")')" >> .env

  cat .env >> $GITHUB_ENV
}

update_project_id() {
  awk -i inplace -v analytics_id="$ANALYTICS_ID" '{gsub(/_paq.push\(\["setSiteId", "[0-9]*"\]\)/, "_paq.push([\"setSiteId\", \"" analytics_id "\"])"); print}' $INDEX_FILE
  awk -i inplace -v appid="$ONESIGNAL_APPID" '{gsub(/appId: .*,$/, "appId: \"" appid "\","); print}' $INDEX_FILE
}

show_help() {
  echo "Usage: $0 [command]"
  echo ""
  echo "If no command is specified, all commands will be executed."
  echo ""
  echo "Available commands:"
  echo "  parse_settings            - Parse settings from JSON file"
  echo "  prepare_dotenv_file       - Prepare .env file"
  echo "  create_theme_file         - Create theme file with colors"
  echo "  update_indexhtml          - Update titles in index.html"
  echo "  update_manifest_json      - Update manifest.json"
  echo "  download_and_resize_icons - Download and resize app icons"
  echo "  download_images           - Download images"
  echo "  copy_icon_to_assets       - Copy icon to assets directory"
  echo "  create_favicon            - Create favicon"
  echo "  update_project_id         - Update project ID in files"
  echo "  help                      - Show this help message"
}

run_all() {
  parse_settings
  prepare_dotenv_file
  create_theme_file
  update_indexhtml
  update_manifest_json
  download_and_resize_icons
  download_images
  copy_icon_to_assets
  create_favicon
  update_project_id
}

main() {
  if [ $# -eq 0 ]; then
    # No arguments provided, run all commands
    run_all
  else
    # Run specific command
    command="$1"
    case "$command" in
      parse_settings|prepare_dotenv_file|create_theme_file|update_indexhtml|update_manifest_json|download_and_resize_icons|download_images|copy_icon_to_assets|create_favicon|update_project_id)
        parse_settings  # Always parse settings first
        $command
        ;;
      help|--help|-h)
        show_help
        ;;
      *)
        echo "Error: Unknown command '$command'"
        show_help
        exit 1
        ;;
    esac
  fi
}

main "$@"