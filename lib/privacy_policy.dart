import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:quiz_crafter/theme/theme.dart';
import 'package:quiz_crafter/utilities/assets_path.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColors,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColors,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Privacy Policy',
          style: TextStyle(
            fontSize: 24,
            color: Colors.black,
          ),
        ).animate().fadeIn().slideY(begin: -0.5, duration: 500.ms),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Emphasizing Creativity and Interactive Quizzes",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ).animate().fadeIn(duration: 600.ms),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage(
                      AssetsPath.masterDeveloper,
                    ),
                    radius: 24,
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Hamim Leon",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      Text(
                        "Team Leader & Developer",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        "hamim15-5264@diu.edu.bd",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn().slideX(begin: -0.5, duration: 500.ms),
            SizedBox(height: 20),
            _buildSection("Effective Date:", "15 March 2025"),
            SizedBox(height: 12),
            _buildBodyText(
                "At QuizCrafter, we value your privacy. This policy explains how we collect, use, and protect your data."),
            SizedBox(height: 16),
            _buildSectionTitle("1. Data Collection & Usage"),
            _buildBodyText(
                "We collect: \n• Personal Info: Name, email, profile details.\n• Usage Data: Quizzes, scores, and reviews.\n• Device Info: Analytics and performance logs."),
            _buildBodyText(
                "We use this data to improve user experience, security, and support."),
            SizedBox(height: 12),
            _buildSectionTitle("2. Data Security"),
            _buildBodyText(
                "Your data is protected using industry-standard security measures. We do not sell or misuse your information."),
            SizedBox(height: 12),
            _buildSectionTitle("3. Review Guidelines"),
            _buildBodyText(
                "We encourage respectful and constructive reviews.\nPlease:"),
            _buildChecklist("Be relevant & professional."),
            _buildChecklist("Avoid offensive language."),
            SizedBox(height: 12),
            _buildSectionTitle("4. Acknowledgment"),
            _buildBodyText(
                "Special thanks to our App Architect for their invaluable contribution to this project!"),
            SizedBox(height: 12),
            _buildSectionTitle("5. Updates & Contact"),
            _buildBodyText(
                "This policy may change. By using QuizCrafter, you agree to our terms."),
            _buildBodyText("\u{1F4E7} Contact: +880 1724 - 879284",
                color: Colors.redAccent),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String label, String value) {
    return RichText(
      text: TextSpan(
        text: '$label ',
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
        children: [
          TextSpan(
            text: value,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
    ).animate().fadeIn().slideX(begin: -0.2, duration: 300.ms);
  }

  Widget _buildBodyText(
    String text, {
    Color color = Colors.black87,
  }) {
    return Text(
      text,
      style: TextStyle(fontSize: 14, color: color),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildChecklist(String item) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_box,
            color: Colors.green,
            size: 18,
          ),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              item,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ).animate().fadeIn(delay: 100.ms),
    );
  }
}
