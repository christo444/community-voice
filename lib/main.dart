import 'package:community_voice/features/app_features/presentation/pages/auth/phone_input_page.dart';
import 'package:community_voice/features/app_features/presentation/pages/ocr_screens/aadhaar_test_launcher.dart';
import 'package:community_voice/domain/repository/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://wzpfhmngcfwrbgzcdymv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind6cGZobW5nY2Z3cmJnemNkeW12Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAyNjA5NjgsImV4cCI6MjA4NTgzNjk2OH0.x_ivRdyK1HPT43vJq8B0p0D2jcZXO0dunnipMAPcP7E',
  );

  runApp(const CommunityVoice());
}

class CommunityVoice extends StatelessWidget {
  const CommunityVoice({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Community Voice',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF800000), // Maroon
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF800000),
          primary: const Color(0xFF800000),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthRepository _authRepository = AuthRepository();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Show splash for at least 1 second
    await Future.delayed(const Duration(seconds: 1));

    try {
      final user = await _authRepository.autoLogin();

      if (!mounted) return;

      if (user != null) {
        // User is logged in - go to Aadhaar verification
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AadhaarTestLauncher(),
          ),
        );
      } else {
        // User not logged in - go to phone input
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const PhoneInputPage(),
          ),
        );
      }
    } catch (e) {
      // On error, go to phone input
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const PhoneInputPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF800000),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.voice_chat,
                size: 50,
                color: Color(0xFF800000),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Community Voice',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Inclusive Welfare Access',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}