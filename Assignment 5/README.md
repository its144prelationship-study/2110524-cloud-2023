# **myDropbox Application**

## **When running myDropboxClient file, you will see the result as following**

**Welcome to myDropbox Apllication**
**============================================**
**Please input command (newuser username password password, login**
**username password, put filename, get filename, view, or logout).**
**If you want to quit the program just type quit.**
**============================================**

## *After that, you can use the myDropbox Application, which supports the following commands:*

*PUT*

• The 'put' command is used to upload a file from local to S3:

> \> put tmp1.txt

*GET*

• The 'get' command is used to download user's file from S3 to local:

> \> get tmp1.txt bob@mail.com

*VIEW*

• The 'view' command is used to display all files of the user, including filename, file size, last modified date, and the owner:

> \> view

*QUIT*

• The 'quit' command is used to exit the application:

> \> quit

# **HOW TO for API**

**PUT**

• HTTP method: POST
• headers: {"Content-Type": "application/json"}
• body: body = {"command": "put",
                "user": user,
                "filename": filename,
                "file": data}
• successful response: {"statusCode": 200,
                        "body": {"success": True,
                                "message": "PUT successful"}}

**GET**

• HTTP method: GET
• headers: {"Content-Type": "application/json"}
• body: body = {"command": "get",
                "user": user,
                "filename": filename,
                "shareuser": shareuser}
• successful response: {"statusCode": 200,
                        "body": {"success": True,
                                "message": "GET successful",
                                "content": content}}

**VIEW**

• HTTP method: GET
• headers: {"Content-Type": "application/json"}
• body: body = {"command": "view",
                "user": user}
• successful response: {"statusCode": 200,
                        "body": {"success": True,
                                "message": "VIEW successful",
                                "contents": contents}}

