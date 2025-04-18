# This script was created to convert a directory full
# of markdown files into rst equivalents. It uses
# pandoc to do the conversion.
#
# 1. Install pandoc from http://johnmacfarlane.net/pandoc/
# 2. Copy this script into the directory containing the .md files
# 3. Ensure that the script has execute permissions
# 4. Run the script
#
# By default this will keep the original .md file

FILES=*.epub
for f in $FILES; do
  # extension="${f##*.}"
  filename="${f%.*}"
  echo "Converting $f to $filename.pdf"
  ebook-convert "$f" "$filename.pdf" \
    --pdf-serif-family "LXGW WenKai GB Screen" \
    --pdf-sans-family "LXGW WenKai GB Screen" \
    --pdf-mono-family "LXGW WenKai GB Screen" \
    --pretty-print
  #ebook-convert "$f" "$filename.pdf" --pdf-serif-family "Reddit Mono"
  # --pdf-serif-family "EB Garamond" \
  # --pdf-sans-family "EB Garamond" \
  # --pdf-mono-family "EB Garamond" \

done

# uncomment this line to delete the source file.
# rm $f
