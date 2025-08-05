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
    print(pyfiglet.figlet_format(page_data[0].get('page_name'), font = "ansi_shadow"))
    
    

#display_name()

lotsoffonts = sub.run(["pyfiglet","-l"], capture_output=True, text=True)
parsed = lotsoffonts.stdout.split('\n')
for fontt in range(100,150):
    if 'small' in parsed[fontt]:
        print(parsed[fontt])
        print(pyfiglet.figlet_format("Test", font=parsed[fontt]))
# big for the smaller text sizes perhaps?  broadway_kb calvin_s cyberlarge