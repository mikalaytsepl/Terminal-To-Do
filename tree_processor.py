# import sys
import os
import json

# import subprocess as sub
import pyfiglet

# import termcolor

VERTICAL_PIPE = "│"
THREE_WAY_PIPE = "├──"
L_PIPE = "└──"
INDENT = "    "
PATH_TO_JSON = f"{os.getenv('HOME')}/TerminalToDo/last_known_state.json"

# get access check fuction and if there's access,
#  get new state automatically b4 proceiding
# doing some strange long ass comentaries and some
#  formatiing mistakes to check if linters are working,
#  ofc should delete that one in the future
with open(PATH_TO_JSON, "r") as jsonfile:
    page_data = json.load(jsonfile)


def display_name():
    # fmt: off
    print(pyfiglet.figlet_format
          (page_data[0].get("page_name"), font="ansi_shadow"))
    # fmt: on


display_name()

# big for the smaller text sizes perhaps?  broadway_kb calvin_s cyberlarge
