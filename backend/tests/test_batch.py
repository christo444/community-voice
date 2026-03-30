import os
from dotenv import load_dotenv

load_dotenv()
from services.scheme_matcher import match_with_gemini_batch

profile = "Name: John, Age: 25, Occupation: Farmer"
schemes = [
    {
        "id": "1",
        "scheme_name": "Farmer Support Scheme",
        "description": "Supports farmers",
        "eligibility": ["Must be a farmer"]
    },
    {
        "id": "2",
        "scheme_name": "Student Allowance",
        "description": "For students",
        "eligibility": ["Must be a student"]
    }
]

res = match_with_gemini_batch(profile, schemes)
print("BATCH MATCH RESULT:")
print(res)
