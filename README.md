# Community Voice - Voice-Driven Welfare Access App

## Overview

Community Voice is a production-ready MVP Flutter application designed for low-literacy users to check welfare scheme eligibility using voice prompts. The app follows clean architecture principles and is offline-first.

## Architecture

### Clean Architecture Layers

```
lib/
├── core/                    # Cross-cutting concerns
│   ├── constants/          # App constants, enums, theme
│   ├── services/           # Core services (DB, rule engine, voice)
│   └── utils/              # Utility functions
│
├── data/                    # Data layer
│   ├── models/             # Data models (JSON/DB serialization)
│   ├── datasources/        # Local (SQLite) & Remote (HTTP) data sources
│   └── repositories/       # Repository implementations
│
├── domain/                  # Business logic layer
│   ├── entities/           # Business entities
│   ├── repositories/       # Repository interfaces
│   └── usecases/           # Business use cases
│
├── features/                # Feature modules (organized by feature)
│   ├── onboarding/
│   ├── voice_intake/
│   ├── eligibility/
│   └── schemes/
│
├── presentation/            # UI layer
│   ├── screens/            # Screen widgets
│   ├── widgets/            # Reusable widgets
│   └── viewmodels/         # State management (Provider)
│
└── main.dart               # App entry point
```

## Key Features

### ✅ Implemented

1. **Clean Architecture** - Separation of concerns with clear layer boundaries
2. **Offline-First** - SQLite for local storage, syncs from remote
3. **Voice Interaction** - Option-based prompts (not free text)
4. **Rule Engine** - Deterministic eligibility logic (NO AI)
5. **State Management** - Provider for reactive UI
6. **Scheme Sync** - Manual sync from backend (with mock data fallback)
7. **User Sessions** - Local storage of voice intake data
8. **Eligibility Check** - Real-time matching against scheme criteria

### 🔄 Stubbed for Future Implementation

1. **Aadhaar OCR** - Interface ready, stub returns mock data
2. **Voice Recognition** - Using stub service (easy to swap with real speech_to_text)
3. **Backend API** - Mock data provided, API integration ready

## Core Components

### Domain Entities

- **Scheme** - Welfare scheme with eligibility criteria
- **Criteria** - Age, income, category, gender, disability, BPL requirements
- **UserSession** - User data collected through voice

### Data Models

All models match the `scheme_data.json` structure exactly:

```json
{
  "metadata": {
    "version": "1.0",
    "last_updated": "2026-01-15"
  },
  "schemes": [
    {
      "scheme_id": "OLD_AGE_PENSION",
      "scheme_name": "Old Age Pension",
      "criteria": {
        "min_age": 60,
        "income_max": 10000,
        "categories": ["SC", "ST", "OBC"]
      },
      "active": true
    }
  ]
}
```

### Services

1. **DatabaseHelper** - SQLite database management (Singleton)
2. **EligibilityEngine** - Rule-based eligibility checking
3. **VoiceService** - Interface for speech recognition (with stub implementation)
4. **AadhaarOcrService** - Stub interface for OCR (NO actual Aadhaar validation)

### Rule Engine Logic

The eligibility engine uses deterministic rules:

```dart
IF user.age >= scheme.min_age 
AND user.age <= scheme.max_age
AND user.income <= scheme.income_max
AND user.category IN scheme.categories
AND user.gender == scheme.gender (if specified)
AND user.isDisabled == scheme.is_disabled (if specified)
AND user.isBpl == scheme.is_bpl (if specified)
THEN eligible = true
```

## Voice Interaction Flow

Voice prompts are **option-based**, not free text:

1. **Age**: "What is your age? Say the number."
2. **Gender**: "Say Male, Female, or Other."
3. **Income**: "Say Below 10,000 / 10,000 to 20,000 / 20,000 to 50,000 / Above 50,000."
4. **Category**: "Say General, SC, ST, OBC, or EWS."
5. **Disability**: "Do you have any disability? Say Yes or No."
6. **BPL**: "Do you have a BPL card? Say Yes or No."

Voice input is mapped to structured values (enums/ints) - **NO voice data is stored**.

## Getting Started

### Prerequisites

- Flutter SDK: 3.9.2 or higher
- Dart: 3.9.2 or higher

### Installation

1. Clone the repository
2. Get dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### First Time Setup

1. On first launch, tap "Sync Schemes" to load mock data into local database
2. Tap "Start Voice Check" to begin eligibility assessment
3. Follow voice prompts (or use "Type Instead" for manual input)
4. View eligible schemes

## Dependencies

- **provider** (6.1.2) - State management
- **sqflite** (2.4.1) - Local database
- **path_provider** (2.1.5) - File paths
- **speech_to_text** (7.0.0) - Voice recognition
- **audioplayers** (6.1.0) - Audio prompts
- **http** (1.2.2) - API calls
- **intl** (0.19.0) - Internationalization
- **equatable** (2.0.7) - Value comparison

## Configuration

### Using Real Speech Recognition

In `lib/core/services/stub_voice_service.dart`:

```dart
static VoiceService create({bool useStub = false}) {
  if (useStub) {
    return StubVoiceService();
  }
  return SpeechToTextService(); // Real implementation
}
```

Change `useStub: false` in `voice_intake_screen.dart`.

### Backend Integration

Update `lib/core/constants/app_constants.dart`:

```dart
static const String baseUrl = 'https://your-backend-api.com';
static const String schemesEndpoint = '/api/schemes';
```

## Database Schema

### schemes table
```sql
scheme_id TEXT PRIMARY KEY
scheme_name TEXT NOT NULL
active INTEGER NOT NULL
description TEXT
benefits TEXT
min_age INTEGER
max_age INTEGER
income_max INTEGER
categories TEXT (comma-separated)
gender TEXT
is_disabled INTEGER
is_bpl INTEGER
created_at TEXT
```

### user_sessions table
```sql
session_id TEXT PRIMARY KEY
age INTEGER NOT NULL
gender TEXT NOT NULL
income INTEGER NOT NULL
category TEXT NOT NULL
is_disabled INTEGER NOT NULL
is_bpl INTEGER NOT NULL
created_at TEXT NOT NULL
```

## Testing

The app includes mock data for 5 schemes:
1. Old Age Pension
2. Widow Pension
3. Disability Allowance
4. BPL Ration Card
5. SC/ST Scholarship

## TODO / Future Enhancements

- [ ] Integrate real backend API
- [ ] Add multi-language support (Hindi, regional languages)
- [ ] Implement audio prompts for each question
- [ ] Add Aadhaar OCR integration (non-UIDAI)
- [ ] Add offline analytics
- [ ] Implement scheme application tracking
- [ ] Add push notifications for new schemes
- [ ] Create admin dashboard for scheme management

## What This App Does NOT Do

❌ No Aadhaar authentication/validation  
❌ No Aadhaar image storage  
❌ No chatbot/AI decision making  
❌ No Firebase/authentication  
❌ No legal advice generation  
❌ No free-text voice chat  

## Production Readiness Checklist

- [x] Clean architecture implementation
- [x] Offline-first with SQLite
- [x] Error handling
- [x] State management with Provider
- [x] Repository pattern
- [x] Use case separation
- [x] Stub implementations for easy testing
- [ ] Unit tests (TODO)
- [ ] Integration tests (TODO)
- [ ] API integration (TODO)
- [ ] Performance optimization (TODO)

## License

This is a social impact project. License TBD.

## Contact

For questions about implementation or integration, please refer to the architecture documentation above.

