import 'package:flutter/material.dart';
import 'package:quiz_crafter/theme/theme.dart';
import 'package:quiz_crafter/view/auth/splash_screen.dart';
import 'package:quiz_crafter/widgets/body_background.dart';

class NoConnectionScreen extends StatelessWidget {
  const NoConnectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColors,
      body: BodyBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.wifi_off,
                  size: 60,
                  color: AppTheme.secondaryColor,
                ),
                SizedBox(
                  height: 24,
                ),
                Text(
                  "No Internet Connection",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 24,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SplashScreen(),
                      ),
                    );
                  },
                  child: Text(
                    "Try Again",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
