#!/bin/bash

# Define base paths
ASSETS_DIR="/Users/regisgimenis/Downloads/MyLife_App/MyLife-/MyLife!/Assets.xcassets"
ARTIFACTS_DIR="/Users/regisgimenis/.gemini/antigravity/brain/89161bb8-d71b-44e4-8871-ff0367eb7434"

echo "Installing assets to $ASSETS_DIR..."

# Function to install theme
install_theme() {
    NAME=$1
    FILE=$2
    IMAGESET="$ASSETS_DIR/Theme_$NAME.imageset"
    
    echo "Installing $NAME from $FILE to $IMAGESET..."
    
    mkdir -p "$IMAGESET"
    if [ -f "$ARTIFACTS_DIR/$FILE" ]; then
        cp "$ARTIFACTS_DIR/$FILE" "$IMAGESET/image.png"
        echo "Copied image."
    else
        echo "ERROR: Source file $ARTIFACTS_DIR/$FILE not found!"
        return 1
    fi
    
    # Write Contents.json
    cat <<EOF > "$IMAGESET/Contents.json"
{
  "images" : [
    {
      "filename" : "image.png",
      "idiom" : "universal",
      "scale" : "1x"
    },
    {
      "idiom" : "universal",
      "scale" : "2x"
    },
    {
      "idiom" : "universal",
      "scale" : "3x"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF
    echo "Created Contents.json."
}

install_theme "Forest" "theme_forest_1764305399751.png"
install_theme "Floral" "theme_floral_1764305411992.png"
install_theme "Urban" "theme_urban_1764305425538.png"
install_theme "Travel" "theme_travel_1764305444372.png"
install_theme "Car" "theme_car_1764305458011.png"
install_theme "Art" "theme_art_1764305473484.png"
install_theme "Family" "theme_family_1764305486047.png"

echo "Installation complete."
