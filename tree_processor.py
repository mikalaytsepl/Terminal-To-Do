import os
import sys
import json
import json_creator

import pyfiglet

# import termcolor


API_INTEGRATION = f"{os.getenv('HOME')}/TerminalToDo/retrieve_information.sh"
PATH_TO_JSON = f"{os.getenv('HOME')}/TerminalToDo/last_known_state.json"


class TreeBuilder:
    _VERTICAL_PIPE = "│"
    _THREE_WAY_PIPE = "├──"
    _L_PIPE = "└──"
    _INDENT = "    "

    def __init__(self, API_INT, JSONPATH):
        self._API_INTEGRATION = API_INT
        self._PATH_TO_JSON = JSONPATH

        with open(PATH_TO_JSON, "r") as jsonfile:
            self.page_data = json.load(jsonfile)

    # this method will check if API is reacheable and
    # will try to refresh the last known state if possible
    def _check_and_refresh(self):
        if json_creator.JSONCreator().check_connection():
            json_creator.JSONCreator().update_json()  # refresh the json by prompting the API
        else:
            sys.stdout.write("somethng went wrong")

    def _get_name(self) -> str:
        return self.page_data[0].get("page_name")

    def build_tree(self):
        self._check_and_refresh()
        print(
            pyfiglet.figlet_format(self._get_name(), "calvin_s")
        )  # something is wrong with that filget so figure that out later


# big for the smaller text sizes perhaps?  broadway_kb calvin_s cyberlarge


if __name__ == "__main__":
    TreeBuilder(API_INTEGRATION, PATH_TO_JSON).build_tree()
