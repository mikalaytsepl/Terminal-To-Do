#!/bin/bash

VERTICAL_PIPE="│"
THREE_WAY_PIPE="├──"
L_PIPE="└──"
INDENT="    "

get_name(){
    NAME="$(./retrieve_information.sh -n)"
    echo "$NAME" | figlet -t -f smbraille # or future font, i still don't know
}
get_name
# wideterm for headings 

build_a_tree(){
    jsonstuff="$(./retrieve_information.sh -j)"
    current_indent=""

    echo "$jsonstuff" | jq -c ".[]" | while read -r element; do
        if [[ "$element" != null ]]; then
            type="$(jq -r ".objects_type" <<< "$element")"
            text="$(jq -r ".plain_text" <<< "$element")"

            case "$type" in
                heading_1 | heading_2 | heading_3)
                    current_indent=""  # reset indent
                    echo -n "$THREE_WAY_PIPE "
                    figlet -t -f wideterm "$text"
                    current_indent="$INDENT"  # set indent for next level
                    ;;
                to_do)
                    echo "${VERTICAL_PIPE}${current_indent}${THREE_WAY_PIPE} $text"
                    ;;
                paragraph)
                    echo "${THREE_WAY_PIPE} $text"
                    ;;
                *)
                    echo "Unhandled object_type: $type"
                    ;;
            esac
        fi
    done
}
build_a_tree