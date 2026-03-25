
import requests
import json

url = 'http://127.0.0.1:5001/api/user/request-help'
data = {
    'name': 'Test User',
    'phone_number': '1234567890',
    'location': 'Test Place',
    'scheme_name': 'Test Scheme'
}

try:
    response = requests.post(url, json=data)
    print(f"Status: {response.status_code}")
    print(f"Response: {response.text}")
except Exception as e:
    print(f"Error: {e}")
