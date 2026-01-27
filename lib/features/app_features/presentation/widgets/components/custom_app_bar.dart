import 'package:community_voice/core/theme/colors.dart';
import 'package:flutter/material.dart';

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

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    // ===== UI DESIGNER: CUSTOMIZE BELOW =====
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: AppColors.maroon,
      foregroundColor: AppColors.white,
      elevation: 4,
      centerTitle: false,
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
    );
    // ===== END CUSTOMIZATION ZONE =====
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
