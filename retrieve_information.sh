#!/bin/bash

if [ -z "$API_TOKEN" ]; then
    # echo -e "environment is not ready, looking for .env file \n
            # to import"
    if [ -f "$HOME/TerminalToDo/.env" ]; then
        # echo "found, importing"

	    # shellcheck disable=SC1091
        source "$HOME/TerminalToDo/.env"

        # echo "imported, proceding with the checks"
    fi
fi 

check_if_reacheable(){
    GET_PAGES_ENDPOINT="$(curl --silent -I "https://api.notion.com/v1/pages/$PAGE_ID"\
                            -H 'Authorization: Bearer '"$API_TOKEN"''\
                            -H "Notion-Version: 2022-06-28")"

    

    if [[ "$( echo "$GET_PAGES_ENDPOINT" | grep -Po  "(?<=HTTP/2 )[0-9]{3}")" = "200" ]]; then
        return
    else
        echo "couldn't reach the endpoint"
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

toggle_todo(){
    
    mapfile -t idstate < <(echo "$1")

    echo "toggling the state of ${idstate[0]}"

    if [[ ${idstate[1]} == true ]]; then
        idstate[1]=false
    else
        idstate[1]=true
    fi

    echo "parsing with ${idstate[1]}"

    curl --silent --output /dev/null \
    -X PATCH "https://api.notion.com/v1/blocks/${idstate[0]}" \
    -H "Authorization: Bearer $API_TOKEN" \
    -H "Notion-Version: 2022-06-28" \
    -H "Content-Type: application/json" \
    --data "{\"to_do\": {\"checked\": ${idstate[1]}}}" 
}

check_if_reacheable
while getopts "pjhnt:" flag; do
    case $flag in

    p)
        get_page_contents "--plain"
    ;;
    
    j)
        get_page_contents "--json" 
    ;;

    n)
        get_page_name
    ;;

    t)
        toggle_todo "$2"
    ;;

    ?/)
        echo "no valid option found"
    ;;
    esac
done