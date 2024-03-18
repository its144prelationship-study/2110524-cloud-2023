# **myDropbox Application**

Definition:
- 'the user' refers to the current user, who has been logged in to the application.
- 'the owner' refers to the user, who owns the file(s).

### **When running myDropboxClient file, you will see the result as following**

Welcome to myDropbox Apllication
**============================================**
Please input command (newuser username password password, login
username password, put filename, get filename, view, or logout).
If you want to quit the program just type quit.
**============================================**

#### **First, you have to create an account, using the command:**

*NEWUSER*

• The 'newuser' command is used to create a new user account:

> \> newuser mewmew@mail.com mewmew1234 mewmew1234

Note: If you already have an account, you may skip to the next step.

### **Then, log in to your account, using this command:**

*LOGIN*

• The 'login' command is used to log in to the user's account:

> \> login mewmew@mail.com mewmew1234

#### **After that, you can use the myDropbox Application, which supports the following commands:**

*PUT*

• The 'put' command is used to upload a file from local to S3:

> \> put tmp1.txt

*GET*

• The 'get' command is used to download the user's file or a file that has been shared with the user from S3 to the local system:

> \> get tmp1.txt bob@mail.com

*VIEW*

• The 'view' command is used to display all files of the user and files that have been shared with the user, including filename, file size, last modified date, and the owner:

> \> view

*SHARE*

• The 'share' command is used to share the user's file with another user:

> \> share tmp1.txt alice@mail.com

*LOGOUT*

• The 'logout' command is used to log out from the user's account:

> \> logout

*QUIT*

• The 'quit' command is used to exit the application:

> \> quit


## **HOW TO for API**

**PUT**

• HTTP method: POST
• headers: 
```json
{"Content-Type": "application/json"}
```
• request body: 
```json
body = {"command": "put",
        "user": user,
        "filename": filename,
        "file": data}
```
• successful response body: 
```json
{"statusCode": 200,
 "body": {"success": True,
          "message": "PUT successful"}}
```
**GET**

• HTTP method: GET
• headers: 
```json
{"Content-Type": "application/json"}
```
• request body:  
```json
body = {"command": "get",
        "user": user,
        "filename": filename,
        "owner": owner}
```
• successful response body: 
```json
{"statusCode": 200,
 "body": {"success": True,
          "message": "GET successful",
          "content": content}}
```

**VIEW**

• HTTP method: GET
• headers: 
```json
{"Content-Type": "application/json"}
```
• request body:  
```json
body = {"command": "view",
        "user": user}
```
• successful response body: 
```json
{"statusCode": 200,
 "body": {"success": True,
          "message": "VIEW successful",
          "contents": contents}}
```
**NEWUSER**

• HTTP method: POST
• headers: 
```json
{"Content-Type": "application/json"}
```
• request body:  
```json
body = {"command": "newuser",
        "user": user,
        "password": password}
```
• successful response body: 
```json
{"statusCode": 200,
 "body": {"success": True,
          "message": "New user created successfully"}}
```
**LOGIN**

• HTTP method: GET
• headers: 
```json
{"Content-Type": "application/json"}
```
• request body:  
```json
body = {"command": "login",
        "user": user,
        "password": password}
```
• successful response body: 
```json
{"statusCode": 200,
 "body": {"success": True,
          "message": "Login successful"}}
```
**SHARE**

• HTTP method: GET
• headers: 
```json
{"Content-Type": "application/json"}
```
• request body:  
```json
body = {"command": "share",
        "user": user,
        "filename": filename,
        "shareuser": shareuser}
```
• successful response body: 
```json
{"statusCode": 200,
 "body": {"success": True,
          "message": "SHARE successful"}}
```