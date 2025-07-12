#!/bin/bash

VERTICAL_PIPE="│"
THREE_WAY_PIPE="├──"
L_PIPE="└──"
INDENT="    "
LINE_NUMBERS=false

get_name(){
    NAME="$(./retrieve_information.sh -n)"
    echo "$NAME" | figlet -t -f future # or smbraille font, i still don't know
}

build_a_tree(){
    get_name
    # Get JSON and turn into indexed array
    jsonstuff="$(./retrieve_information.sh -j)"
    mapfile -t elements < <(echo "$jsonstuff" | jq -c ".[]")

    current_indent=""

    for ((i = 0; i < ${#elements[@]}; i++)); do
        # set -x  
        
        element="${elements[i]}"
        type=$(jq -r ".objects_type" <<< "$element")
        text=$(jq -r ".plain_text" <<< "$element") 

        next_type=""
        if (( i + 1 < ${#elements[@]} )); then
            next_type=$(jq -r ".objects_type" <<< "${elements[i + 1]}")
        fi

        # calculation of the spacing of indexes, for numbers not to disrupt the 
        # look of the tree
        ARRLEN=${#elements[@]}

        # Last index
        LAST_INDEX=$(( ARRLEN - 1 ))

        # Get number of digits in the highest index
        DIGITS=${#LAST_INDEX}
        
        COUNT=$(( DIGITS - ${#i} ))
        NUM_SPACING=""
        for _ in $(seq 1 $COUNT); do
            NUM_SPACING+=" "
        done

        if [[ "$type" != "null" && $LINE_NUMBERS = true ]]; then

            if (( i <= 9)); then
                echo -n "${i}${NUM_SPACING}"
            else
                echo -n "${i}${NUM_SPACING}"
            fi

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
        # set +x
    done

    FINAL_INDEX=$(( ${#elements[@]} - 1 ))
    COUNT=$(( ${#FINAL_INDEX} ))
    NUM_SPACING=""
    for _ in $(seq 1 $COUNT); do
        NUM_SPACING+=" "
    done

    # Print the final tree end line with correct indent
    echo "${NUM_SPACING}${L_PIPE}End of the note."
}

prepare_for_toggle(){
    local index=$1
    jsonstuff="$(./retrieve_information.sh -j)"
    mapfile -t elements < <(echo "$jsonstuff" | jq -c ".[]")

    type=$(jq -r ".objects_type" <<< "${elements[$index]}")

    
    if [[ $type == "to_do" ]]; then
        jq -r ".id, .checked" <<< "${elements[$index]}"
    else
        exit 1
    fi
    
}

while getopts "bt:n" flag; do
    case $flag in 

    b)
        build_a_tree
    ;;

    t)
        if ! result=$(prepare_for_toggle "$2"); then
            echo "Toggle aborted: not a to-do block" >&2
            exit 1
        fi

        ./retrieve_information.sh -t "$result"
    ;;
    n)
        LINE_NUMBERS=true
        build_a_tree
    ;;
    ?/)
        echo "no valid option found"
    ;;
    esac
done
