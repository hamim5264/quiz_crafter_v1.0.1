import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:quiz_crafter/no_connection_screen.dart';
import 'package:quiz_crafter/theme/theme.dart';
import 'package:quiz_crafter/utilities/assets_path.dart';
import 'package:quiz_crafter/view/admin/admin_home_screen.dart';
import 'package:quiz_crafter/view/user/user_home_screen.dart';
import 'package:quiz_crafter/view/auth/app_login_screen.dart';
import 'package:quiz_crafter/widgets/body_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const NoConnectionScreen(),
        ),
      );
    } else {
      Future.delayed(const Duration(seconds: 3), () {
        _checkLogin();
      });
    }
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
    final role = prefs.getString("userRole");

    if (isLoggedIn && role == "admin") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const AdminHomeScreen(),
        ),
      );
    } else if (isLoggedIn && role == "student") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const UserHomeScreen(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const AppLogInScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColors,
      body: BodyBackground(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(
                  height: 300,
                ),
                Image.asset(
                  AssetsPath.appLogo,
                  width: 180,
                ),
                const SizedBox(
                  height: 140,
                ),
                CircularProgressIndicator(color: AppTheme.secondaryColor),
                const SizedBox(
                  height: 16,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      "Developed By - Team App Architect",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Version 1.0.1",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
