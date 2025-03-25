import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:quiz_crafter/firebase_options.dart';
import 'package:quiz_crafter/theme/theme.dart';
import 'package:quiz_crafter/view/auth/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    QuizCrafter(),
  );
}

class QuizCrafter extends StatelessWidget {
  const QuizCrafter({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      title: "QuizCrafter v1.0.1",
      home: SplashScreen(),
      theme: AppTheme.theme,
    );
  }
}
