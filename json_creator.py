import os
import sys
import json
import subprocess as sub


class JSONCreator:
    def __init__(self):
        home = os.getenv("HOME")
        self.api_script = f"{home}/TerminalToDo/retrieve_information.sh"
        self.json_path = f"{home}/TerminalToDo/last_known_state.json"

    def _get_name(self) -> dict:
        try:
            raw_name = sub.run(
                [self.api_script, "-n"], capture_output=True, text=True, check=True
            )
            dict_pair = {"page_name": raw_name.stdout.strip()}
            return dict_pair
        except sub.CalledProcessError:
            sys.stdout.write("Failed: can not get name.")

    @staticmethod
    def _has_children(main_page_element: dict) -> bool:
        try:
            return main_page_element["has_children"]
        except TypeError:
            return False

    def check_connection(self) -> bool:
        try:
            sub.run([self.api_script, "-n"], check=True, text=True, capture_output=True)
            return True
        except sub.CalledProcessError:
            return False

    def _get_page_json(self):
        retr_result = sub.run(
            [self.api_script, "-j"], capture_output=True, text=True, check=True
        )
        parsed_output = json.loads(retr_result.stdout)
        for idx, element in enumerate(parsed_output):
            if element is None:
                parsed_output.pop(idx)
            if self._has_children(element):
                got_children = sub.run(
                    [self.api_script, "-c", element["id"]],
                    capture_output=True,
                    text=True,
                )
                parsed_children = json.loads(got_children.stdout)
                element["children_contents"] = parsed_children

        name = self._get_name()
        parsed_output.insert(0, name)

        return parsed_output

    def update_json(self):
        if self.check_connection():

            sys.stdout.write("Connection established, updating.")
            updated_data = self._get_page_json()

            with open("last_known_state.json", "w+") as file:
                file.write(json.dumps(updated_data, indent=6))
        else:
            sys.stdout.write(
                "No connection to the API.\n"
                "Update failed.\n"
                "Last known state will be displayed."
            )


if __name__ == "__main__":
    JSONCreator().update_json()
