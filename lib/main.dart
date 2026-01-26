import 'package:flutter/material.dart';

void main() {
  runApp(const CommunityVoice());
}

class CommunityVoice extends StatelessWidget {
  const CommunityVoice({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.blue,
        appBar: AppBar(
          title: Text("Community Voice"),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Text("Community Voice"),
        ),
      ),
    );
  }
}