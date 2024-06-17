find . -name "*.md" -exec sh -c '
    for file do
        # Get file extension and name without extension
        extension="${file##*.}"
        filename="${file%.*}"
        # Convert file to traditional Chinese version and overwrite original file
        opencc -i "$file" -o "$filename-new.$extension" -c s2hk.json 
        # Delete original file
        rm "$file"
    done
' sh {} \;
# for only current folder *md
# for file in ./*.md; do
#     # Get file extension and name without extension
#     extension="${file##*.}"
#     filename="${file%.*}"
#     # Convert file to traditional Chinese version and overwrite original file
#     opencc -i "$file" -o "$filename-translated.$extension" -c s2hk.json
#     rm "$file"
# done

# find . -type f -exec sh -c 'newname=$(echo "$1" | opencc -c s2hk.json); mv "$1" "$newname"' sh {} \;

