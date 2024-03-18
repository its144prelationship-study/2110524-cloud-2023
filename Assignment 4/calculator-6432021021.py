import json

def lambda_handler(event, context):
    data = json.loads(event["body"])
    if "a" not in data or "b" not in data or "op" not in data:
        if data["op"] not in ["+", "-", "*", "/"] or not data["a"].isnumeric() or not data["b"].isnumeric():
            return {
                'statusCode': 400,
                'body': json.dumps("Invalid request")
            }
    if data["op"] == "+":
        result = int(data["a"]) + int(data["b"])
    elif data["op"] == "-":
        result = int(data["a"]) - int(data["b"])
    elif data["op"] == "*":
        result = int(data["a"]) * int(data["b"])
    elif data["op"] == "/":
        result = int(data["a"]) / int(data["b"])
        if result % 1 == 0:
            result = int(result)
    return {
        'statusCode': 200,
        'body': json.dumps({"result": str(result)}),
    }