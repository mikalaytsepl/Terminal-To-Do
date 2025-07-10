#!/bin/bash

get_info(){
    NAME="$(./retrieve_information.sh -n)"
    echo "$NAME"
}
get_info