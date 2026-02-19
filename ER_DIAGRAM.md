# Database Structure (ER Diagram)

## Tables in Database

### 1. users
Stores user login information

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| phone_number | text | PRIMARY KEY | User's 10-digit phone number |
| pin | text | NOT NULL | 4-digit login PIN |
| created_at | timestamptz | NOT NULL | When account was created |
| last_login_at | timestamptz | | Last login time |

### 2. profile_details
Stores user profile information

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| phone_number | text | PRIMARY KEY, FOREIGN KEY → users(phone_number) | Links to user account |
| name | text | | Full name |
| date_of_birth | text | | Date of birth |
| age | int4 | | Age in years |
| gender | text | | Gender (Male/Female/male/Female) |
| address | text | | Full address |
| created_at | timestamptz | NOT NULL | When profile was created |
| updated_at | timestamptz | NOT NULL | Last profile update |

## Relationships
- One user can have one profile (1:1 relationship)
- phone_number connects both tables
- When user registers with phone + PIN in `users` table, their profile goes to `profile_details` table

## Simple Diagram
```
┌─────────────────┐         ┌──────────────────────┐
│     users       │         │  profile_details     │
├─────────────────┤         ├──────────────────────┤
│ phone_number PK │────────>│ phone_number PK, FK  │
│ pin             │         │ name                 │
│ created_at      │         │ date_of_birth        │
│ last_login_at   │         │ age                  │
└─────────────────┘         │ gender               │
                            │ address              │
                            │ created_at           │
                            │ updated_at           │
                            └──────────────────────┘
```

## How It Works
1. User enters phone number in app
2. If new user → creates entry in `users` table with PIN
3. User fills profile form → data saved in `profile_details` table
4. Login → checks phone_number + PIN in `users` table
5. After login → fetches user details from `profile_details` table
