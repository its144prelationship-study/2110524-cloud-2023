import base64
import json
import requests

api_gateway = "https://0jbvtj6p79.execute-api.us-west-2.amazonaws.com/default/activity5-myDropbox"
user = "bob@mail.com"

def putMethod(filename):
    # encode file to base64
    with open(filename, "rb") as file:
        data = base64.b64encode(file.read()).decode("UTF-8")

    # create JSON body
    body = {
        "command": "put",
        "user": user,
        "filename": filename,
        "file": data
    }
    # encode to ASCII string and then to base64 string
    body_str = json.dumps(body)
    body_bytes = body_str.encode("ascii")
    base64_bytes = base64.b64encode(body_bytes)
    base64_body = base64_bytes.decode("ascii")

    # post request to api gateway to put file to s3
    response = requests.post(api_gateway,
                            json = base64_body,
                            headers = {"Content-Type": "application/json"})
    
    if response.status_code == 200:
        print("OK")
    else:
        print("Unsuccessful: "+response.json()["message"])

def getMethod(filename, shareuser):  
    # create JSON body
    body = {"command": "get",
            "user": user,
            "filename": filename,
            "shareuser": shareuser}
    # encode to ASCII string and then to base64 string
    body_str = json.dumps(body)
    body_bytes = body_str.encode("ascii")
    base64_bytes = base64.b64encode(body_bytes)
    base64_body = base64_bytes.decode("ascii")

    # get request to api gateway to get file from s3
    response = requests.get(api_gateway,
                        json = base64_body,
                        headers = {"Content-Type": "application/json"})
    
    # decode base64 and write to file
    decoded_data = base64.b64decode(response.json()["content"])
    with open(filename, "wb") as file:
        file.write(decoded_data)
        
    if response.status_code == 200:
        print("OK")
    else:
        print("Unsuccessful: "+response.json()["message"])

def viewMethod():
    # create JSON body
    body = {"command": "view",
            "user": user}
    # encode to ASCII string and then to base64 string
    body_str = json.dumps(body)
    body_bytes = body_str.encode("ascii")
    base64_bytes = base64.b64encode(body_bytes)
    base64_body = base64_bytes.decode("ascii")
    
    # view request to api gateway
    response = requests.get(api_gateway,
                            json = base64_body,
                            headers={"Content-Type":"application/json"})
        
    if response.status_code == 200:
        print("OK")
        for data in response.json()["contents"]:
            print(data["content"], data["size"], data["last_modified"], data["owner_user"])
    else:
        print("Unsuccessful: "+response.json()["message"])

print("Welcome to myDropbox Apllication")
print("============================================")
print("Please input command (newuser username password password, login")
print("username password, put filename, get filename, view, or logout).")
print("If you want to quit the program just type quit.")
print("============================================")

while(True):
    command = input("myDropbox>> ")
    command = command.split(" ")
    
    if(command[0].lower() == "quit"):
        print("============================================")
        break
    elif (command[0].lower() == "put" and len(command) == 2):
        putMethod(command[1])
    elif (command[0].lower() == "get" and len(command) == 3):
        getMethod(command[1],command[2])
    elif (command[0].lower() == "view" and len(command) == 1):
        viewMethod()
    else:
        print("Command is not valid")

