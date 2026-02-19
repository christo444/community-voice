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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.maroon.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          isSpeaking ? Icons.stop_rounded : Icons.volume_up_rounded,
          color: iconColor ?? AppColors.maroon,
          size: size,
        ),
        onPressed: onPressed,
        splashRadius: 22,
        tooltip: isSpeaking ? 'Stop' : 'Listen',
      ),
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
        gradient: const LinearGradient(
          colors: [
            AppColors.maroon,
            Color(0xFF4A0E1A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          isSpeaking ? Icons.stop_rounded : Icons.volume_up_rounded,
          color: iconColor ?? Colors.white,
          size: size,
        ),
        onPressed: onPressed,
        tooltip: isSpeaking ? 'Stop Reading' : 'Read Page',
      ),
    );
    // ===== END CUSTOMIZATION ZONE =====
  }
}
