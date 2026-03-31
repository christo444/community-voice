from services.scheme_matcher import match_user_with_schemes

print("Testing Profile 1:")
match1 = match_user_with_schemes('1111111111')
for s in match1:
    print(f"Scheme: {s['scheme_name']}, Match: {s['match_percentage']}%")

print("\nTesting Profile 2:")
match2 = match_user_with_schemes('2222222222')
for s in match2:
    print(f"Scheme: {s['scheme_name']}, Match: {s['match_percentage']}%")
