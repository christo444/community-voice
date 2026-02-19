import 'package:community_voice/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// =================================================================
/// CUSTOM APP BAR WIDGET - UI DESIGNER'S FILE
/// =================================================================
/// 
/// UI DESIGNER: You can customize the look and feel of the app bar
/// - Change colors, gradients, shadows
/// - Modify title text style, font, size
/// - Add custom decorations, borders
/// - Change height, shape, elevation
/// - Add background images or patterns
/// 
/// DEVELOPER: Only modify the parameters
/// - Do NOT change the widget parameters
/// - Pass your data through constructor
/// =================================================================

/// Custom app bar for the application
/// Used in all pages
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final String? logoPath;
  final double logoSize;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.logoPath,
    this.logoSize = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    // ===== UI DESIGNER: CUSTOMIZE BELOW =====
    return AppBar(
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading,
      actions: actions,
      centerTitle: false,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.maroon,
              Color(0xFF4A0E1A), // darker maroon
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: Row(
        children: [
          // Circular Logo
          if (logoPath != null)
            Container(
              width: logoSize,
              height: logoSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color.fromARGB(255, 253, 240, 213),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  logoPath!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          // Spacing between logo and title
          if (logoPath != null)
            const SizedBox(width: 12),
          // Title Text
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.3,
                color: const Color.fromARGB(255, 253, 240, 213),
                fontStyle: FontStyle.italic
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
    // ===== END CUSTOMIZATION ZONE =====
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
