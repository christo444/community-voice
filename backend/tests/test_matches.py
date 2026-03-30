import os
from dotenv import load_dotenv
from services.scheme_matcher import match_user_with_schemes

load_dotenv()

users = ["1111111111", "2222222222", "3333333333"]

for phone in users:
    print(f"\n======================================")
    print(f"Testing matches for phone: {phone}")
    results = match_user_with_schemes(phone)
    print(f"MATCHED SCHEMES:")
    for r in results:
        print(f" - {r['scheme_name']} ({r['match_percentage']}%)")
    print(f"======================================\n")
