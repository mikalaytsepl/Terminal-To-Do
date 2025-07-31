import sys, os
import json
import subprocess as sub

API_INTEGRATION = f"{os.getenv('HOME')}/TerminalToDo/retrieve_information.sh"

def get_name()->dict:
    raw_name = sub.run([API_INTEGRATION, "-n"], capture_output=True, text=True)
    dict_pair = {"page_name": raw_name.stdout.strip()}
    return dict_pair

def has_chidlren(main_page_element:dict)->bool:
    return main_page_element['has_children'] 


def get_page_json():
    retr_result = sub.run([API_INTEGRATION, "-j"], capture_output=True, text=True)
    parsed_output = json.loads(retr_result.stdout)
    for element in parsed_output:
        if has_chidlren(element):
            got_children = sub.run([API_INTEGRATION, "-c", element['id']], capture_output=True, text=True)
            parsed_children = json.loads(got_children.stdout)
            element['children_contents']=parsed_children

    name = get_name()
    parsed_output.insert(0, name)

    return parsed_output

def create_json_file():
    contents = get_page_json()

    with open("last_known_state.json","w+") as file:
        file.write(json.dumps(contents,indent=6))


create_json_file()
