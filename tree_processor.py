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

    def build_tree(self, elements=None, current_indent="", depth=0) -> None:
        if elements is None:
            self._check_and_refresh()
            sys.stdout.write(
                f'\n{pyfiglet.figlet_format(self._get_name(), "calvin_s")}'
            )
            elements = self.page_data[1:]

        for idx, element in enumerate(elements):
            obj_type = element.get("objects_type")
            text = element.get("plain_text", "")
            has_children = element.get("has_children", False)

            # Look ahead
            next_type = (
                elements[idx + 1].get("objects_type")
                if idx + 1 < len(elements)
                else None
            )

            if obj_type in ("heading_1", "heading_2", "heading_3"):
                sys.stdout.write(f"{self._THREE_WAY_PIPE} ")
                sys.stdout.write(pyfiglet.figlet_format(text, font="mini", width=100))
                current_indent = self._INDENT

            elif obj_type == "to_do":
                pipe = self._THREE_WAY_PIPE if next_type == "to_do" else self._L_PIPE
                line = f"{self._VERTICAL_PIPE}{current_indent}{pipe} "
                if element.get("checked", False):
                    # strikethrough
                    line += f"\033[9m{text}\033[0m"
                else:
                    line += text
                sys.stdout.write(line + "\n")

                if has_children:
                    try:
                        child_elements = element.get("children_contents", None)
                        self.build_tree(
                            child_elements, current_indent + self._INDENT, depth + 1
                        )
                    except json.JSONDecodeError:
                        sys.stdout.write("Failed to parse children\n")

            elif obj_type == "paragraph":
                sys.stdout.write(f"{self._THREE_WAY_PIPE} {text}\n")

            elif obj_type is None:
                sys.stdout.write(f"{self._VERTICAL_PIPE}{current_indent}\n")

            else:
                sys.stdout.write(f"Unhandled object_type: {obj_type}\n")


# big for the smaller text sizes perhaps?  broadway_kb calvin_s cyberlarge


if __name__ == "__main__":
    TreeBuilder(API_INTEGRATION, PATH_TO_JSON).build_tree()
