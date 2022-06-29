#! /bin/bash

USAGE_TXT="
Usage : $(basename "$0") -i <input_file(EPUB)> -o <output> --code-lang <language>

             -i  input filename (epub)
             -o  output filename (.md)
    --code-lang  language for code blocks highlights
    "



PROGRAMS="perl awk pandoc"

for program in $PROGRAMS
do
    which $program &> /dev/null || echo "$program not found"
done



while [[ $# -ne 0 ]]
do
    case $1 in
        -h|--help)
            echo "$USAGE_TXT"
            exit
            ;;
        -i|--input)
            INPUT="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT="$2"
            shift 2
            ;;
        --code-lang)
            CODE_LANG="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

[[ (-f "$INPUT") && (-n $(grep -i '.*.epub' <<< "$INPUT")) ]] || { echo "$USAGE_TXT"; exit; }

[[ (-n "$OUTPUT") || (! -f "$OUTPUT") ]] || { echo "$USAGE_TXT"; exit; }

INPUT="$(cd $(dirname "$INPUT"); pwd -P)/$(basename "$INPUT")"

[[ -n "$CODE_LANG" ]] || CODE_LANG=""

cd $(dirname "$OUTPUT") || exit



TEMP="$OUTPUT.temp"

MEDIA_DIR_NAME=${OUTPUT%.md}
MEDIA_DIR_NAME=${MEDIA_DIR_NAME##/*/}
MEDIA_DIR="media/images/$MEDIA_DIR_NAME"

pandoc --from=epub --to=gfm --wrap=preserve --output="$TEMP" --extract-media="$MEDIA_DIR" "$INPUT" 

function format () {
    GFM_OBS_CODE_LANG="$2"
    export GFM_OBS_CODE_LANG
    cat "$1" \
    | perl -pe 's/(?m)(.*<span .*?>\s*)|(.*<\/span>\s*)|(.*<svg .*?>\s*)|(.*<\/svg>\s*)|(.*<div.*?>\s*)|(.*<\/div>\s*)//g' \
    | perl -pe 's/(<a href=")(.*?)(" class=".*?">)(.*?)(<\/a>)/\[\4\]\(\2\)/g' \
    | perl -pe 's/(<img src=")(.*)(" class=".*" \/>)/\!\[\[\2\]\]/g' \
    | perl -pe 's/(<image.*href=")(.*?)("><\/image>)/\!\[\[\2\]\]/g' \
    | perl -pe 's/(?<=```) ?\w+/$ENV{GFM_OBS_CODE_LANG}/g' \
    | perl -pe 's/^###(?=\s*$)/---/g' \
    | awk '{ if ((prev!=$0)||($0=="")) { print $0 } if ($0~/# \w+/) { prev=$0 }  }'
}

format "$TEMP" "$CODE_LANG" > "$OUTPUT"

rm "$TEMP"