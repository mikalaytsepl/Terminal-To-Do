import sys
import json


# get contents of the json file, this one maybe will be actually used that way cause we would haveto store the last known state '''
def get_json_contents(path: str) -> dict:
    with open(path, "r") as pagecontent:
        return json.load(pagecontent)


def get_properties_by_id(id: str, content: dict) -> dict:
    for objects in content["results"]:
        if objects["id"] == id:
            result = {}
            try:
                result["id"] = objects["id"]
                result["objects_type"] = objects["type"]
                result["plain_text"] = objects[objects["type"]]["rich_text"][0][
                    "plain_text"
                ].replace("\u2019", "'")
                if result["objects_type"] == "to_do":
                    result["checked"] = objects[objects["type"]]["checked"]
                return result
            except IndexError:
                return None


def parser(path: str) -> dict:
    content = json.loads(path)
    block_ids = [block["id"] for block in content["results"]]
    parsed = [get_properties_by_id(id, content) for id in block_ids]
    return parsed


def get_plain(reply) -> list:
    data = []
    for parsed_block in parser(reply):
        try:
            data.append(parsed_block["plain_text"].replace("\u2019", "'"))
        except TypeError:
            pass
    print(json.dumps(data))


def get_json(reply):
    return json.dumps(parser(reply))


if __name__ == "__main__":
    json_reply = sys.stdin.read()
    match sys.argv[1]:
        case "--plain":
            print(get_plain(json_reply))
        case "--json":
            print(get_json(json_reply))
        case _:
            print("cos sie zjebalo")
