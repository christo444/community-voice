import 'package:community_voice/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// =================================================================
/// DETAIL SECTION WIDGETS - UI DESIGNER'S FILE
/// =================================================================
/// 
/// UI DESIGNER: You can customize the look and feel of detail sections
/// - Change text styles, colors, fonts
/// - Modify spacing, alignment, backgrounds
/// - Add decorations, borders, cards
/// - Customize layout structure
/// 
/// DEVELOPER: Only modify the parameters
/// - Do NOT change the widget parameters
/// - Pass your text through constructor
/// =================================================================

/// Main title for detail pages
/// Used for scheme name or main heading
class DetailTitle extends StatelessWidget {
  final String text;
  final Color? color;
  final double? fontSize;

  const DetailTitle({
    super.key,
    required this.text,
    this.color,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    // ===== UI DESIGNER: CUSTOMIZE BELOW =====
    return Text(
      text,
      style: GoogleFonts.merriweather(
        fontSize: fontSize ?? 24,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.maroon,
        letterSpacing: 0.3,
      ),
    );
    // ===== END CUSTOMIZATION ZONE =====
  }
}

/// Section heading for detail pages
/// Used for "Details:", "How to Apply:" etc.
class SectionHeading extends StatelessWidget {
  final String text;

  const SectionHeading({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    // ===== UI DESIGNER: CUSTOMIZE BELOW =====
    return Text(
      text,
      style: GoogleFonts.lato(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
    // ===== END CUSTOMIZATION ZONE =====
  }
}

/// Section content for detail pages
/// Used for description text, instructions, etc.
class SectionContent extends StatelessWidget {
  final String text;

  const SectionContent({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    // ===== UI DESIGNER: CUSTOMIZE BELOW =====
    return Text(
      text,
      style: GoogleFonts.openSans(
        fontSize: 15.5,
        height: 1.5,
        color: Colors.black54,
      ),
    );
    // ===== END CUSTOMIZATION ZONE =====
  }
}

/// Vertical spacing widget for consistent gaps
/// Used between sections
class SectionSpacer extends StatelessWidget {
  final double height;

  const SectionSpacer({
    super.key,
    this.height = 20,
  });

  @override
  Widget build(BuildContext context) {
    // ===== UI DESIGNER: CUSTOMIZE BELOW =====
    return SizedBox(height: height);
    // ===== END CUSTOMIZATION ZONE =====
  }
}
