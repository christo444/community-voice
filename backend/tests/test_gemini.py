from google import genai
import os
from dotenv import load_dotenv

load_dotenv()

api_key = os.getenv('GEMINI_API_KEY')
print(f"Using API key: {api_key[:10]}...")

client = genai.Client(api_key=api_key)

print("\nListing available models:")
print("-" * 50)

try:
    models = client.models.list()
    for model in models:
        # Check if model supports vision/content generation
        if hasattr(model, 'name'):
            print(f"\nModel: {model.name}")
            if hasattr(model, 'display_name'):
                print(f"  Display Name: {model.display_name}")
            if hasattr(model, 'supported_generation_methods'):
                print(f"  Methods: {model.supported_generation_methods}")
except Exception as e:
    print(f"Error listing models: {e}")
