#!/bin/bash

if [ -n "$API_TOKEN" ]; then
    echo "environment is ready"
else
    echo -e "environment is not ready, looking for .env file \n
            to to import"
    if [ -f "$HOME/TerminalToDo/.env" ]; then
        echo "found, importing"

	    # shellcheck disable=SC1091
        source "$HOME/TerminalToDo/.env"

        echo "imported, proceding with the checks"
    fi
fi 

check_if_reacheable(){
    GET_PAGES_ENDPOINT="$(curl --silent -I "https://api.notion.com/v1/pages/$PAGE_ID"\
                            -H 'Authorization: Bearer '"$API_TOKEN"''\
                            -H "Notion-Version: 2022-06-28")"

    

    if [[ "$( echo "$GET_PAGES_ENDPOINT" | grep -Po  "(?<=HTTP/2 )[0-9]{3}")" = "200" ]]; then
        echo -e "the endpoint is reacheable \n"
    fi
}

get_page_name(){
    curl --silent "https://api.notion.com/v1/pages/$PAGE_ID"\
                            -H 'Authorization: Bearer '"$API_TOKEN"''\
                            -H "Notion-Version: 2022-06-28" | python3.11 test_parser.py
}

get_page_contents(){
    test="$(curl --silent "https://api.notion.com/v1/blocks/$PAGE_ID/children?page_size=100"\
                            -H 'Authorization: Bearer '"$API_TOKEN"''\
                            -H "Notion-Version: 2022-06-28" | python3.11 content_parser.py "$1")"
    echo "$test"
}

build_a_tree(){
    jsonstuff=$1
    echo "$jsonstuff" | jq -c ".[]" | while read -r element; do
        if [[ "$element" != null ]]; then
            jq ".id, .objects_type" <<< "$element"
        fi
    done
    
}

check_if_reacheable
while getopts "pjh" flag; do
    case $flag in

    p)
        get_page_contents "--plain"
    ;;
    
    j)
        build_a_tree "$(get_page_contents "--json")" 
    ;;

    ?/)
        echo "no valid option found"
    ;;
    esac
done