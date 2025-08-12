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
    # set -x 
    # Get JSON and turn into indexed array
    # "$(./retrieve_information.sh -j)"

    local depth=${4:-0} 

    jsonstuff=$1
    
    mapfile -t elements < <(echo "$jsonstuff" | jq -c ".[]")

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

        if [[ $LINE_NUMBERS = true ]]; then
            echo -n "${i}${NUM_SPACING}"
        fi

        case "$type" in
            heading_1 | heading_2 | heading_3)
                current_indent=""
                echo -n "$THREE_WAY_PIPE "
                figlet -t -f wideterm "$text"
                current_indent="$INDENT"
                ;;
            to_do)
                # Determine if this is the last element
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
                
                #checking whether the element has children 
                if [[ "$(jq -r ".has_children"  <<< "$element")" == "true" ]]; then 
                    build_a_tree "$(./retrieve_information.sh -c "$(jq -r ".id" <<< "$element")")" "$current_indent " "true" $((depth + 1)) #manually adding a spacing to the indent
                fi
                ;;
            paragraph)
                echo "${THREE_WAY_PIPE} $text"
            ;;
            null)
                echo "${VERTICAL_PIPE}${current_indent}"
            ;;
            *)
                echo "Unhandled object_type: $type"
                ;;
        esac
        # set +x
    done


    if [[ "$3" == "false"  ]]; then
        # correct indent for the end of the tree thingy
        NUM_SPACING=""
        if [[ $LINE_NUMBERS = true ]]; then
                FINAL_INDEX=$(( ${#elements[@]} - 1 ))
                COUNT=$(( ${#FINAL_INDEX} ))
                for _ in $(seq 1 $COUNT); do
                    NUM_SPACING+=" "
                done
        fi

        echo "${NUM_SPACING}${L_PIPE}End of the note."
        return
    fi
    return
    
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

prepare_for_deletion(){
    local index=$1

    #avoid deleting 0 element if index was not set
    if [[ $index == "" ]]; then
        echo "error: the index was not explicitly specified"
        exit 1
    fi

    jsonstuff="$(./retrieve_information.sh -j)"
    mapfile -t elements < <(echo "$jsonstuff" | jq -c ".[]")
    jq -r ".id" <<< "${elements[$index]}"

}

while getopts "bt:nd" flag; do
    case $flag in 

    b)
        get_name
        build_a_tree "$(./retrieve_information.sh -j)" "" "false" 0
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
        get_name
        build_a_tree "$(./retrieve_information.sh -j)" "" "false" 0
    ;;
    d)
        prepare_for_deletion "$2"
        if ! result=$(prepare_for_deletion "$2"); then
            echo "Deletion failed: on index specified"
            exit 1
        fi
        ./retrieve_information.sh -d "$result"
    ;;
    *)
        echo "no valid option found"
    ;;
    esac
done
