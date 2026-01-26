// ignore_for_file: prefer_const_constructors

import 'package:community_voice/core/theme/colors.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Welcome To Community Voice"),
          backgroundColor: AppColors.maroon,
        ),
        body: Text("SChemes"),
      );
  }
}