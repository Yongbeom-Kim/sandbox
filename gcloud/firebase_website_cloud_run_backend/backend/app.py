import json
from flask import Flask, request
# from flask_cors import CORS
# For some reason, just doing CORS(app) means the CORS headers are not showing in Cloud Run invocations.
import os
from dotenv import load_dotenv

load_dotenv()
app = Flask(__name__)



@app.route('/hello', methods=['GET', 'OPTIONS'])
def hello():
    if request.method == 'OPTIONS':
        response = app.make_default_options_response()
    elif request.method == 'GET':
        response = app.response_class(
            response=json.dumps({'message': 'hello world'}),
            status=200,
            mimetype='application/json'
        )
    else:
        raise Exception('Invalid request method')
    
    return response

@app.after_request
def add_cors_headers(response):
    response.headers.add('Access-Control-Allow-Origin', '*')
    response.headers.add('Access-Control-Allow-Methods', '*')
    response.headers.add('Access-Control-Allow-Headers', 'Content-Type')
    return response

if __name__ == '__main__':
    port = int(os.environ.get('BACKEND_PORT', 8080))
    app.run(host='0.0.0.0', port=port)
