import 'package:community_voice/features/app_features/presentation/pages/homepage/home_page.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(const CommunityVoice());
}

class CommunityVoice extends StatelessWidget {
  const CommunityVoice({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
      );
  }
}
