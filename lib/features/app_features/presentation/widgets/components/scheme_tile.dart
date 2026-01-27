import 'package:flutter/material.dart';

/// =================================================================
/// SCHEME TILE WIDGET - UI DESIGNER'S FILE
/// =================================================================
/// 
/// UI DESIGNER: You can customize the look and feel of scheme tiles
/// - Change tile design, spacing, borders
/// - Modify text styles, colors, fonts
/// - Add shadows, gradients, decorations
/// - Customize the layout structure
/// 
/// DEVELOPER: Only modify the parameters and callback functions
/// - Do NOT change the widget parameters
/// - Pass your data and logic through constructor
/// =================================================================

/// Scheme tile widget for displaying government schemes
/// Used in homepage list
class SchemeTile extends StatelessWidget {
  final String name;
  final String description;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsets? contentPadding;
  final Color? tileColor;

  const SchemeTile({
    super.key,
    required this.name,
    required this.description,
    this.trailing,
    this.onTap,
    this.contentPadding,
    this.tileColor,
  });

  @override
  Widget build(BuildContext context) {
    // ===== UI DESIGNER: CUSTOMIZE BELOW =====
    return ListTile(
      onTap: onTap,
      title: Text(
        name,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        description,
        style: const TextStyle(
          fontSize: 14,
        ),
      ),
      trailing: trailing,
      tileColor: tileColor ?? Colors.white,
      contentPadding: contentPadding ?? const EdgeInsets.all(16),
    );
    // ===== END CUSTOMIZATION ZONE =====
  }
}
