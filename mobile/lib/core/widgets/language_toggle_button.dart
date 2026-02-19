import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localization/language_provider.dart';

class LanguageToggleButton extends StatelessWidget {
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? fontSize;

  const LanguageToggleButton({
    super.key,
    this.backgroundColor,
    this.foregroundColor,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return PopupMenuButton<String>(
          onSelected: (String value) {
            languageProvider.setLanguage(value);
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'en',
              child: Row(
                children: [
                  Radio<String>(
                    value: 'en',
                    groupValue: languageProvider.languageCode,
                    onChanged: (String? value) {
                      if (value != null) {
                        languageProvider.setLanguage(value);
                        Navigator.pop(context);
                      }
                    },
                  ),
                  const Text('E - English'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'ml',
              child: Row(
                children: [
                  Radio<String>(
                    value: 'ml',
                    groupValue: languageProvider.languageCode,
                    onChanged: (String? value) {
                      if (value != null) {
                        languageProvider.setLanguage(value);
                        Navigator.pop(context);
                      }
                    },
                  ),
                  const Text('M - മലയാളം'),
                ],
              ),
            ),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: backgroundColor ?? const Color(0xFF800000),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.language,
                  color: foregroundColor ?? Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  languageProvider.languageCode.toUpperCase(),
                  style: TextStyle(
                    color: foregroundColor ?? Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize ?? 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
