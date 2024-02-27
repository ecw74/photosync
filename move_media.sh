#!/bin/bash

# move_media.sh - Creates a temporary folder, copies and renames media files,
# then moves only new files to the destination folder, deletes the temporary folder,
# and adds an exit trap for cleanup.

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 SOURCE_PATH DESTINATION_PATH"
    exit 1
fi

SOURCE_PATH=$1
DESTINATION_PATH=$2

if ! command -v exiftool &> /dev/null; then
    echo "exiftool could not be found. Please install it to use this script."
    exit 1
fi

# Erstellt einen temporären Ordner und setzt eine Bereinigungsfunktion
TEMP_DIR=$(mktemp -d)

# Definiert eine Bereinigungsfunktion
cleanup() {
    echo "Cleaning up..."
    rm -rf "/tmp/file_exists_*"
    rm -rf "$TEMP_DIR"
}

# Registriert die Bereinigungsfunktion, die beim Script-Exit aufgerufen wird
trap cleanup EXIT

move_and_rename() {
    local file="$1"
    local temp_base_path="$2"
    local datetime
    datetime=$(exiftool -DateTimeOriginal -d "%Y_%m_%d_%H_%M_%S" -S -s "$file" | awk '{print $NF}')

    if [[ -z $datetime ]]; then
        datetime=$(exiftool -MediaCreateDate -d "%Y_%m_%d_%H_%M_%S" -S -s "$file" | awk '{print $NF}')
    fi

    if [[ -z $datetime ]]; then
        datetime=$(exiftool -CreationDate -d "%Y_%m_%d_%H_%M_%S" -S -s "$file" | awk '{print $NF}')
    fi

    if [[ $datetime ]]; then
        local year=${datetime:0:4}
        local month=${datetime:5:2}
        local dest_path="$temp_base_path/Bilder $year/${month}_${year}"
        mkdir -p "$dest_path"
        local base_name=${datetime}
        local extension="${file##*.}"
        local new_file_path="$dest_path/${base_name,,}.${extension,,}"
        local counter=1
        while [ -e "$new_file_path" ]; do
            new_file_path="$dest_path/${base_name,,}_${counter}.${extension,,}"
            ((counter++))
        done
        cp "$file" "$new_file_path"
        echo "Copied $file to $new_file_path"
    else
        echo "DateTimeOriginal, CreationDate, or MediaCreateDate not found for $file. Skipping..."
    fi
}

check_and_move() {
    local src_file="$1"
    local temp_base_path="$2"
    local dest_base_path="$3"
    local dest_file="${src_file/$temp_base_path/$dest_base_path}"
    local dest_dir
    local dest_filename
    local dest_filename_lower
    local file_exists_flag="/tmp/file_exists_$$"

    dest_dir=$(dirname "$dest_file")
    dest_filename=$(basename -- "$dest_file")
    dest_filename_lower=$(echo "$dest_filename" | tr '[:upper:]' '[:lower:]')

    mkdir -p "$dest_dir"

    echo "false" > "$file_exists_flag"
    find "$dest_dir" -type f | while IFS= read -r existing_file; do
        existing_filename_lower=$(basename -- "$existing_file" | tr '[:upper:]' '[:lower:]')
        if [ "$existing_filename_lower" == "$dest_filename_lower" ]; then
            echo "true" > "$file_exists_flag"
            break
        fi
    done

    if [ ! "$(cat "$file_exists_flag")" == "true" ]; then
        mv "$src_file" "$dest_file"
        echo "Moved $src_file to $dest_file"
    else
        echo "File $dest_file already exists or a similar file was found. Skipping..."
    fi

    rm -f "$file_exists_flag"
}

export -f move_and_rename check_and_move

find "$SOURCE_PATH" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.mp4" -o -iname "*.mov" \) \
     -mtime +90 -exec bash -c 'move_and_rename "$0" "'"$TEMP_DIR"'"' {} \;

find "$TEMP_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.mp4" -o -iname "*.mov" \) \
      -exec bash -c 'check_and_move "$0" "'"$TEMP_DIR"'" "'"$DESTINATION_PATH"'"' {} \;
