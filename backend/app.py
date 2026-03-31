from flask import Flask, jsonify
from flask_cors import CORS
from routes.schemes import schemes_bp
import os
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
CORS(app)  # Enable CORS for React frontend

# Register blueprints
app.register_blueprint(schemes_bp, url_prefix='/api/schemes')

# Create necessary directories
os.makedirs('data', exist_ok=True)
os.makedirs('uploads', exist_ok=True)

@app.route('/')
def health_check():
    return {'status': 'Main API is running', 'version': '1.0.0'}

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
