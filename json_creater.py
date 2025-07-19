import sys
import json
import subprocess as sub

path_to_retrieval = "./retrieve_information.sh"

result = sub.run([path_to_retrieval, "-j"], capture_output=True, text=True)


parsed_output = json.loads(result.stdout)


with open("writetest.json", "w") as file:
    json.dump(parsed_output, file, indent=4)

print("STDOUT:")
print(result.stdout)
