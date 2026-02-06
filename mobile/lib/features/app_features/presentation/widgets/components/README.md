# UI Components - Designer's Guide

## Overview
This folder contains reusable UI widgets that can be styled independently from business logic.

---

## File Structure

```
components/
├── voice_button.dart    # Voice/audio control buttons
├── scheme_tile.dart     # List tile for schemes
└── README.md           # This file
```

---

## Guidelines for UI Designer

### ✅ What You CAN Do:
- Change colors, fonts, sizes
- Add animations and transitions
- Modify shapes and borders
- Add shadows, gradients, decorations
- Change icon styles
- Adjust spacing and padding
- Add custom widgets inside the build method

### ❌ What You CANNOT Do:
- Change widget parameters (constructor)
- Remove required parameters
- Change callback function signatures
- Modify the widget class names

---

## Widget Specifications

### 1. VoiceButton
**File:** `voice_button.dart`
**Used In:** Homepage scheme list
**Purpose:** Toggle voice reading for individual schemes

**Parameters:**
- `isSpeaking` (bool) - Shows stop/volume icon
- `onPressed` (callback) - Developer's toggle logic
- `size` (double) - Icon size (default: 30)
- `iconColor` (Color?) - Icon color (default: maroon)

**Customization Zone:** Inside `build()` method

---

### 2. FloatingVoiceButton
**File:** `voice_button.dart`
**Used In:** Scheme detail page
**Purpose:** Floating button to read entire page

**Parameters:**
- `isSpeaking` (bool) - Shows stop/volume icon
- `onPressed` (callback) - Developer's toggle logic
- `backgroundColor` (Color?) - Button background
- `iconColor` (Color?) - Icon color
- `size` (double) - Icon size (default: 28)

**Customization Zone:** Inside `build()` method

---

### 3. SchemeTile
**File:** `scheme_tile.dart`
**Used In:** Homepage scheme list
**Purpose:** Display scheme information in a list

**Parameters:**
- `name` (String) - Scheme name
- `description` (String) - Short description
- `trailing` (Widget?) - Right side widget (voice button)
- `onTap` (callback?) - Tap handler for navigation
- `contentPadding` (EdgeInsets?) - Internal spacing
- `tileColor` (Color?) - Background color

**Customization Zone:** Inside `build()` method

---

## Example Customizations

### Adding Animation to VoiceButton
```dart
return AnimatedSwitcher(
  duration: const Duration(milliseconds: 300),
  child: IconButton(
    key: ValueKey(isSpeaking),
    icon: Icon(
      isSpeaking ? Icons.stop : Icons.volume_up,
      color: iconColor ?? AppColors.maroon,
      size: size,
    ),
    onPressed: onPressed,
  ),
);
```

### Adding Gradient to FloatingVoiceButton
```dart
return Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [AppColors.maroon, Colors.red.shade900],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    shape: BoxShape.circle,
    // ... rest of code
  ),
  // ...
);
```

### Card-style SchemeTile
```dart
return Card(
  elevation: 4,
  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  child: ListTile(
    // ... rest of code
  ),
);
```

---

## Testing Your Changes

1. Save your changes
2. Hot reload the app (press `r` in terminal)
3. Check both homepage and detail page
4. Test tap interactions

---

## Communication Protocol

### Before Starting:
- Check the current widget parameters
- Understand what each parameter does
- Plan your design changes

### While Working:
- Only modify inside "CUSTOMIZATION ZONE"
- Test frequently with hot reload
- Keep the same parameter structure

### Before Committing:
- Ensure app compiles without errors
- Test all interactions work
- Document any new customization options

---

## Questions?
Contact the developer if you need:
- New parameters added
- Different callback functions
- Structural changes to widgets

---

**Happy Designing! ���**

---

### 4. CustomAppBar
**File:** `custom_app_bar.dart`
**Used In:** All pages (homepage, detail page, etc.)
**Purpose:** Consistent app bar design across the app

**Parameters:**
- `title` (String) - Page title text
- `actions` (List<Widget>?) - Right side actions (buttons)
- `leading` (Widget?) - Left side widget (back button, menu)
- `automaticallyImplyLeading` (bool) - Auto add back button

**Customization Zone:** Inside `build()` method

**Example Customizations:**
- Add gradient backgrounds
- Custom shaped app bars
- Animated title
- Transparent or glass-morphism effect
- Custom shadows and elevations

---

### 5. PageHeading
**File:** `page_heading.dart`
**Used In:** Homepage and section headers
**Purpose:** Display section titles

**Parameters:**
- `text` (String) - Heading text
- `padding` (EdgeInsets?) - Space around heading

**Customization Zone:** Inside `build()` method

**Example Customizations:**
- Add underlines or borders
- Background containers
- Icon before/after text
- Animated appearance
- Different alignment options

---

## Updated Widget List

All UI components now available for customization:
1. ✅ **VoiceButton** - List item voice control
2. ✅ **FloatingVoiceButton** - Floating voice control
3. ✅ **SchemeTile** - Scheme list items
4. ✅ **CustomAppBar** - App bar for all pages
5. ✅ **PageHeading** - Section headings

---

### 6. DetailTitle
**File:** `detail_section.dart`
**Used In:** Scheme detail page (main title)
**Purpose:** Display main heading/scheme name

**Parameters:**
- `text` (String) - Title text
- `color` (Color?) - Text color (default: maroon)
- `fontSize` (double?) - Font size (default: 24)

**Customization Zone:** Inside `build()` method

---

### 7. SectionHeading
**File:** `detail_section.dart`
**Used In:** Scheme detail page (section headers)
**Purpose:** Display section headings like "Details:", "How to Apply:"

**Parameters:**
- `text` (String) - Heading text

**Customization Zone:** Inside `build()` method

---

### 8. SectionContent
**File:** `detail_section.dart`
**Used In:** Scheme detail page (content text)
**Purpose:** Display description, instructions, and other content

**Parameters:**
- `text` (String) - Content text

**Customization Zone:** Inside `build()` method

---

### 9. SectionSpacer
**File:** `detail_section.dart`
**Used In:** All pages (spacing between sections)
**Purpose:** Consistent vertical spacing

**Parameters:**
- `height` (double) - Space height (default: 20)

**Customization Zone:** Inside `build()` method

---

## Complete Widget List

All UI components now available for customization:
1. ✅ **VoiceButton** - List item voice control
2. ✅ **FloatingVoiceButton** - Floating voice control
3. ✅ **SchemeTile** - Scheme list items
4. ✅ **CustomAppBar** - App bar for all pages
5. ✅ **PageHeading** - Section headings (homepage)
6. ✅ **DetailTitle** - Main title (detail page)
7. ✅ **SectionHeading** - Section headers (detail page)
8. ✅ **SectionContent** - Content text (detail page)
9. ✅ **SectionSpacer** - Consistent spacing

**Every visible UI element is now customizable!** ���

---
