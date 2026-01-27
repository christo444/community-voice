import 'package:community_voice/core/theme/colors.dart';
import 'package:flutter/material.dart';

/// =================================================================
/// VOICE BUTTON WIDGETS - UI DESIGNER'S FILE
/// =================================================================
/// 
/// UI DESIGNER: You can customize the look and feel of these buttons
/// - Change colors, sizes, shapes, animations
/// - Add gradients, shadows, borders
/// - Modify icons and transitions
/// 
/// DEVELOPER: Only modify the parameters and callback functions
/// - Do NOT change the widget structure
/// - Pass your logic through onPressed callback
/// =================================================================

/// Simple voice button for list items
/// Used in homepage scheme tiles
class VoiceButton extends StatelessWidget {
  final bool isSpeaking;
  final VoidCallback onPressed;
  final double size;
  final Color? iconColor;

  const VoiceButton({
    super.key,
    required this.isSpeaking,
    required this.onPressed,
    this.size = 30,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    // ===== UI DESIGNER: CUSTOMIZE BELOW =====
    return IconButton(
      icon: Icon(
        isSpeaking ? Icons.stop : Icons.volume_up,
        color: iconColor ?? AppColors.maroon,
        size: size,
      ),
      onPressed: onPressed,
      splashRadius: 24,
      tooltip: isSpeaking ? 'Stop' : 'Listen',
    );
    // ===== END CUSTOMIZATION ZONE =====
  }
}

/// Floating circular voice button for detail pages
/// Used in scheme detail page (top right corner)
class FloatingVoiceButton extends StatelessWidget {
  final bool isSpeaking;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;

  const FloatingVoiceButton({
    super.key,
    required this.isSpeaking,
    required this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    // ===== UI DESIGNER: CUSTOMIZE BELOW =====
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.maroon,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          isSpeaking ? Icons.stop : Icons.volume_up,
          color: iconColor ?? AppColors.white,
          size: size,
        ),
        onPressed: onPressed,
        tooltip: isSpeaking ? 'Stop Reading' : 'Read Page',
      ),
    );
    // ===== END CUSTOMIZATION ZONE =====
  }
}
