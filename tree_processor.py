import sys, os
import json
import subprocess as sub
import pyfiglet
import termcolor

VERTICAL_PIPE = "│"
THREE_WAY_PIPE = "├──"
L_PIPE = "└──"
INDENT = "    "
PATH_TO_JSON = f"{os.getenv('HOME')}/TerminalToDo/last_known_state.json"

# get access check fuction and if there's access, get new state automatically b4 proceiding
with open(PATH_TO_JSON,"r") as jsonfile:
    page_data = json.load(jsonfile)


def display_name():
    print(pyfiglet.figlet_format(page_data[0].get('page_name'), font = "future"))
    
    

#display_name()

lotsoffonts = sub.run(["pyfiglet","-l"], capture_output=True, text=True)
parsed = lotsoffonts.stdout.split('\n')
for fontt in range(0,20):
    print(parsed[fontt])
    print(pyfiglet.figlet_format("Test", font=parsed[fontt]))