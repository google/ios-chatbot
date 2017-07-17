#!/usr/bin/env python

from __future__ import print_function
from future.standard_library import install_aliases
install_aliases()

from urllib.parse import urlparse, urlencode
from urllib.request import urlopen, Request
from urllib.error import HTTPError

import json
import os

from flask import Flask
from flask import request
from flask import make_response

# Flask app should start in global layout
app = Flask(__name__)


@app.route('/webhook', methods=['POST'])
def webhook():
    req = request.get_json(silent=True, force=True)

    print("Request:")
    print(json.dumps(req, indent=4))
    
    result = req.get("result")
    
    parameters = result.get("parameters")
    
    print("Parameters:")
    print(parameters)
    
    action = result.get("action")
    
    print("action:")
    print(action)
    
    res = {}
    
    if (action == 'inquiry.parades'):
        res = processParadesQuery(parameters)

    res = json.dumps(res, indent=4)
    print(res)
    r = make_response(res)
    r.headers['Content-Type'] = 'application/json'
    return r
    
def processParadesQuery(parameters):
    # Simulate a database query result
    speech = "Chinese New Year Parade in Chinatown from 5pm to 8pm." 
    
    res = {
        "speech": speech,
        "displayText": speech,
        "data":"https://upload.wikimedia.org/wikipedia/commons/f/f1/Year_of_Ox_Chinese_New_Year_Parade_San_Francisco_2009.jpg",
        "contextOut": [],
        "source": "demo-tour-guide"
    }
    
    return res

if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))

    print("Starting app on port %d" % port)

    app.run(debug=False, port=port, host='0.0.0.0')
