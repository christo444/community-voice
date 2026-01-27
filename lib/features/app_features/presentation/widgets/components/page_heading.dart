import 'package:community_voice/core/theme/colors.dart';
import 'package:flutter/material.dart';

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
      padding: padding ?? const EdgeInsets.all(16.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.maroon,
        ),
      ),
    );
    // ===== END CUSTOMIZATION ZONE =====
  }
}
