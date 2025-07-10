#!/bin/bash

VERTICAL_PIPE="│"
THREE_WAY_PIPE="├──"
L_PIPE="└──"
INDENT="    "

get_name(){
    NAME="$(./retrieve_information.sh -n)"
    echo "$NAME" | figlet -t -f future # or smbraille font, i still don't know
}
get_name
# wideterm for headings 

build_a_tree(){
    # Get JSON and turn into indexed array
    jsonstuff="$(./retrieve_information.sh -j)"
    mapfile -t elements < <(echo "$jsonstuff" | jq -c ".[]")

    current_indent=""

    for ((i = 0; i < ${#elements[@]}; i++)); do
        element="${elements[i]}"
        type=$(jq -r ".objects_type" <<< "$element")
        text=$(jq -r ".plain_text" <<< "$element") 

        next_type=""
        if (( i + 1 < ${#elements[@]} )); then
            next_type=$(jq -r ".objects_type" <<< "${elements[i + 1]}")
        fi

        case "$type" in
            heading_1 | heading_2 | heading_3)
                current_indent=""
                echo -n "$THREE_WAY_PIPE "
                figlet -t -f wideterm "$text"
                current_indent="$INDENT"
                ;;
            to_do)
                # Determine if this is the last child
                if [[ "$next_type" == "to_do" ]]; then
                    local pipe="$THREE_WAY_PIPE"
                else
                    local pipe="$L_PIPE"
                fi

                if [[ "$(jq -r ".checked"  <<< "$element")" != "true" ]]; then
                    echo "${VERTICAL_PIPE}${current_indent}${pipe} $text"
                else
                     echo -e "${VERTICAL_PIPE}${current_indent}${pipe} \e[9m$text\e[0m"
                fi
                ;;
            paragraph)
                echo "${THREE_WAY_PIPE} $text"
            ;;
            null)
                continue
            ;;
            *)
                echo "Unhandled object_type: $type"
                ;;
        esac
    done
    echo "${L_PIPE}End of the note."
}
build_a_tree