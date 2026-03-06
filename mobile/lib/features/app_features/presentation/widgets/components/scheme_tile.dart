import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  final int? matchPercentage;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsets? contentPadding;
  final Color? tileColor;

  const SchemeTile({
    super.key,
    required this.name,
    required this.description,
    this.matchPercentage,
    this.trailing,
    this.onTap,
    this.contentPadding,
    this.tileColor,
  });

  @override
  Widget build(BuildContext context) {
    // ===== UI DESIGNER: CUSTOMIZE BELOW =====
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        padding: contentPadding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: tileColor ?? Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  if (matchPercentage != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: matchPercentage! >= 75
                            ? Colors.green.shade50
                            : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: matchPercentage! >= 75
                              ? Colors.green
                              : Colors.orange,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '$matchPercentage% Match',
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: matchPercentage! >= 75
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
    // ===== END CUSTOMIZATION ZONE =====
  }
}
