import sys, os
import json
import subprocess as sub

VERTICAL_PIPE = "│"
THREE_WAY_PIPE = "├──"
L_PIPE = "└──"
INDENT = "    "



def get_name():
    return sub.run([API_INTEGRATION, "-n"], capture_output=True, text=True)

print(get_name())