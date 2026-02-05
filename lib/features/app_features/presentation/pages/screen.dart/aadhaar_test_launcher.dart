import 'package:flutter/material.dart';
import 'aadhaar_scan_screen.dart';

class AadhaarTestLauncher extends StatelessWidget {
  const AadhaarTestLauncher({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Aadhaar Scan Test")),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AadhaarScanScreen(),
              ),
            );

            debugPrint("Aadhaar Scan Result: $result");
          },
          child: const Text("Start Aadhaar Scan"),
        ),
      ),
    );
  }
}
