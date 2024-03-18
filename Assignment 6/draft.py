import base64
import json
import urllib.parse
import boto3
import bcrypt

def lambda_handler(event, context):
    
    # decode body from base64 to ASCII string and then to JSON
    base64_body = event['body']
    body_bytes = base64.b64decode(base64_body)
    body_str = body_bytes.decode("ascii")
    data = json.loads(body_str)

    # s3 bucket
    bucket = "alice-in-wonderland-cloud2023"

    if data["command"] == "put":
        s3 = boto3.client("s3")
        folder = f'{data["user"]}/'

        # create a folder if not exists
        try:
            s3.head_object(Bucket= bucket, Key=folder)
        except:
            s3.put_object(Bucket= bucket, Key=folder)

        # put a file to s3
        file = data["file"]  
        file_key = f'{folder}{data["filename"]}'
        s3.put_object(Bucket= bucket, Key=file_key, Body=base64.decodebytes(file.encode("UTF-8")))
        return {
            "statusCode": 200,
            "body": json.dumps({"success": True,
                                "message": "PUT successful"}),
        }
        
    elif data["command"] == "get":
        s3 = boto3.client("s3")
        folder = f'{data["shareuser"]}/'
        file_key = f'{folder}{data["filename"]}'

        # get a file from s3 and encode to base64
        try:
            s3.head_object(Bucket= bucket, Key=file_key)
            response = s3.get_object(Bucket=bucket, Key=file_key)
            dataResponse = response["Body"].read()
            content = base64.b64encode(dataResponse).decode("UTF-8")
            return {
                "statusCode": 200,
                "body": json.dumps({"success": True,
                                    "message": "GET successful",
                                    "content": content}),
            }
        except:
            return {
                "statusCode": 400,
                "body": json.dumps({"success": False,
                                    "message": "File is not exists"})
            }
        
    elif data["command"] == "view":
        s3 = boto3.client("s3")
        folder = f'{data["user"]}/'

        # list all files in folder
        response = s3.list_objects(Bucket=bucket, Prefix=folder)

        # create a list of files in folder with filename, size, last modified and owner
        contents = []
        for content in response["Contents"]:
            [owner, file] = content["Key"].split("/")
            if file: 
                contents.append({"content":file,
                            "size":content["Size"],
                            "last_modified":str(content["LastModified"]),
                            "owner_user":owner})
        return {
            "statusCode": 200,
            "body": json.dumps({"success": True,
                                "message": "VIEW successful",
                                "contents": contents}),
        }
    elif data["command"] == "newuser":
        dynamodb = boto3.resource("dynamodb")
        table = dynamodb.Table("myDropboxUsers")

        usernameexist = table.get_item(Key={'username': data["username"]})
        if 'Item' in usernameexist: 
            return {
                "statusCode": 400,
                "body": json.dumps({"success": False,
                                    "message": "Username already exists"})
            }
        salt = bcrypt.gensalt()
        hashed_password = bcrypt.hashpw(data["password"].encode('utf-8'), salt)

        # Store username, salt, and hashed password in DynamoDB
        table.put_item(Item={
            'username': data["username"],
            'salt': salt.decode('utf-8'),
            'password': hashed_password.decode('utf-8')
        })

        return {
            "statusCode": 201,
            "body": json.dumps({"success": True,
                                "message": "New user created successfully"})
        }
    elif data["command"] == "login":
        dynamodb = boto3.resource("dynamodb")
        table = dynamodb.Table("myDropboxUsers")

        user = table.get_item(Key={'username': data["username"]})
        if 'Item' not in user:
            return {
                "statusCode": 400,
                "body": json.dumps({"success": False,
                                    "message": "Invalid username"})
            }

        user_data = user['Item']
        stored_hashed_password = user_data.get('hashed_password', '')
        salt = user_data.get('salt', '')

        if bcrypt.checkpw(data["password"].encode('utf-8'), stored_hashed_password.encode('utf-8')):
            return {
                "statusCode": 200,
                "body": json.dumps({"success": True,
                                    "message": "Login successful"})
            }
        else:
            return {
                "statusCode": 400,
                "body": json.dumps({"success": False,
                                    "message": "Invalid password"})
            }
    else :
        return {
            "statusCode": 400,
            "body": json.dumps({"success": False,
                                "message": "Invalid command"})
        }
