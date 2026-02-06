import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// =================================================================
/// PAGE HEADING WIDGET - UI DESIGNER'S FILE
/// =================================================================
/// 
/// UI DESIGNER: You can customize the look and feel of page headings
/// - Change text style, color, size, font
/// - Modify spacing, alignment
/// - Add backgrounds, borders, decorations
/// - Add icons or other visual elements
/// 
/// DEVELOPER: Only modify the parameters
/// - Do NOT change the widget parameters
/// - Pass your text through constructor
/// =================================================================

/// Page heading widget for section titles
/// Used in homepage and other pages
class PageHeading extends StatelessWidget {
  final String text;
  final EdgeInsets? padding;

  const PageHeading({
    super.key,
    required this.text,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    // ===== UI DESIGNER: CUSTOMIZE BELOW =====
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Text(
        text,
        style: GoogleFonts.raleway(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
    // ===== END CUSTOMIZATION ZONE =====
  }
}
