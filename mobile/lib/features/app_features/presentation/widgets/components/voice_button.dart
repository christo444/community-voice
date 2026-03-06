import 'package:community_voice/core/theme/colors.dart';
import 'package:flutter/material.dart';

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
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 139, 58, 58),
            Color.fromARGB(255, 74, 14, 26),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
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
/// Used in scheme detail page (top right corner)
class FloatingVoiceButton extends StatelessWidget {
  final bool isSpeaking;
  final VoidCallback onPressed;
  final Color? iconColor;
  final double size;

  const FloatingVoiceButton({
    super.key,
    required this.isSpeaking,
    required this.onPressed,
    this.iconColor,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 139, 58, 58),
            Color.fromARGB(255, 74, 14, 26),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
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