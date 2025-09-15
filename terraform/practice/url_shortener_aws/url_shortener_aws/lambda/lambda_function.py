import os
import re
import json
import boto3
import string
import secrets
from urllib.parse import urlparse

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["TABLE_NAME"])
BASE_HOST = os.environ.get("BASE_HOST", "").strip()

# simple URL validation
URL_RE = re.compile(r"^https?://[^\s/$.?#].[^\s]*$", re.IGNORECASE)

ALPHABET = string.ascii_letters + string.digits  # 62
CODE_LEN = 7

def _is_valid_url(u: str) -> bool:
    if not isinstance(u, str) or len(u) > 2048:
        return False
    if not URL_RE.match(u):
        return False
    # safety: ensure scheme/host present
    try:
        p = urlparse(u)
        return p.scheme in ("http", "https") and bool(p.netloc)
    except Exception:
        return False

def _gen_code(n=CODE_LEN) -> str:
    return "".join(secrets.choice(ALPHABET) for _ in range(n))

def _make_response(status, body=None, headers=None):
    resp = {"statusCode": status}
    if headers:
        resp["headers"] = headers
    if body is not None:
        if not isinstance(body, str):
            body = json.dumps(body)
        resp["body"] = body
    return resp

def lambda_handler(event, context):
    # HTTP API v2 request format
    reqctx = event.get("requestContext", {})
    http = reqctx.get("http", {})
    method = http.get("method", "")
    path_params = event.get("pathParameters") or {}
    domain = reqctx.get("domainName", "")

    if method == "POST" and http.get("path", "").endswith("/shorten"):
        try:
            body = event.get("body") or "{}"
            if event.get("isBase64Encoded"):
                body = base64.b64decode(body).decode("utf-8")
            data = json.loads(body)
        except Exception:
            return _make_response(400, {"error": "Invalid JSON body"})

        original_url = data.get("url")
        custom_code = data.get("code")  # optional custom alias

        if not original_url or not _is_valid_url(original_url):
            return _make_response(400, {"error": "Invalid or missing 'url'"})

        # use custom code if provided & valid
        if custom_code:
            if not re.fullmatch(r"[A-Za-z0-9_-]{3,32}", custom_code):
                return _make_response(400, {"error": "Invalid 'code' format"})
            code = custom_code
            # Upsert with conditional check to avoid accidental overwrite
            try:
                table.put_item(
                    Item={"short": code, "original": original_url},
                    ConditionExpression="attribute_not_exists(short)"
                )
            except table.meta.client.exceptions.ConditionalCheckFailedException:
                return _make_response(409, {"error": "Code already exists"})
        else:
            # generate collision-free code
            for _ in range(5):  # very unlikely to loop
                code = _gen_code()
                resp = table.get_item(Key={"short": code})
                if "Item" not in resp:
                    table.put_item(Item={"short": code, "original": original_url})
                    break
            else:
                return _make_response(500, {"error": "Could not generate code"})

        host = BASE_HOST if BASE_HOST else domain
        short_url = f"https://{host}/{code}"
        return _make_response(200, {"short_url": short_url, "code": code})

    if method == "GET" and "short" in path_params:
        code = path_params.get("short")
        resp = table.get_item(Key={"short": code})
        item = resp.get("Item")
        if not item:
            return _make_response(404, "Not found")
        # 301 redirect
        return {
            "statusCode": 301,
            "headers": {"Location": item["original"]}
        }

    # OPTIONS (CORS preflight) or others
    if method == "OPTIONS":
      return _make_response(204, None, headers={
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Headers": "content-type",
          "Access-Control-Allow-Methods": "GET,POST,OPTIONS"
      })

    return _make_response(405, {"error": "Method not allowed"})
