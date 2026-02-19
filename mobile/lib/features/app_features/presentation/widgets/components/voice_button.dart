import 'package:community_voice/core/theme/colors.dart';
import 'package:flutter/material.dart';

/// =================================================================
/// VOICE BUTTON WIDGETS - UI DESIGNER'S FILE
/// =================================================================

/// GLOBAL GRADIENT (same everywhere)
const LinearGradient mainGradient = LinearGradient(
  colors: [
    AppColors.maroon,
    Color(0xFF4A0E1A),
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);


/// Simple voice button for list items
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
    return Container(
      decoration: BoxDecoration(
        gradient: mainGradient, // ✅ same gradient
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 6,
            offset: const Offset(0, 3),
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
        splashRadius: 22,
        tooltip: isSpeaking ? 'Stop' : 'Listen',
      ),
    );
  }
}


/// Floating circular voice button for detail pages
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
    return Container(
      decoration: BoxDecoration(
        gradient: mainGradient, // ✅ same gradient
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
  }
}
