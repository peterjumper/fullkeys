# calibre-debug --run-plugin "Chinese Text Conversion" -- -ol hk -il cn -d s2t -od out -a translated *.epub *.azw3
mkdir out
mkdir outt
for filename in *.epub *.azw3; do
    if calibre-debug --run-plugin "Chinese Text Conversion" -- -ol hk -il cn -d s2t -od out -a translated "$filename" ; then
    # if calibre-debug --run-plugin "Chinese Text Conversion" -- -ol hk -il cn -d s2t -od out -a translated "$filename" >> output.log 2>&1; then
        echo "Processed $filename"
    else
        cp "$filename" outt/
        # cat error.log | xargs -I{} cp {} extracted_files/
    fi
    rm "$filename"
    find out/* -type f -exec sh -c 'newname=$(echo "$1" | opencc -c s2hk.json); mv "$1" "$newname"' sh {} \;
done

# for file in *; do mv "$file" "${file//translated/}"; done
# Here are some other examples of parameter substitution:

# ${file%.txt} removes the ".txt" extension from the value of the $file variable.
# ${filename##*/} extracts the base filename from a full path by removing any leading directory path.
# ${variable:-default} returns the value of $variable if it's set, or the string "default" if it's not set.
