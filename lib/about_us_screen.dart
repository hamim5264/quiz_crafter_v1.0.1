import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:quiz_crafter/theme/theme.dart';
import 'package:quiz_crafter/utilities/assets_path.dart';
import 'package:quiz_crafter/widgets/body_background.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _simulateLoading();
  }

  Future<void> _simulateLoading() async {
    await Future.delayed(Duration(seconds: 1)); // simulate loading time
    setState(() => _loading = false);
  }

  Widget _buildCard({
    required String name,
    required String role,
    required String email,
    required String imagePath,
    bool isLeader = false,
    int index = 0,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: AppTheme.primaryColor,
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage(imagePath),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                role,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.secondaryColor,
                ),
              ),
              Text(
                email,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[300],
                ),
              ),
            ],
          ),
          trailing: isLeader
              ? Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                )
              : null,
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 150))
        .slideX(begin: 0.5)
        .fadeIn();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColors,
      appBar: AppBar(
        title: Text('About Us',
            style: TextStyle(fontSize: 24, color: Colors.black)),
        backgroundColor: AppTheme.backgroundColors,
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(
                color: AppTheme.secondaryColor,
              ),
            )
          : BodyBackground(
              child: Column(
                children: [
                  SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Emphasizing Creativity and Interactive Quizzes",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildCard(
                    name: "Hamim Leon",
                    role: "Team Leader",
                    email: "hamim15-5264@diu.edu.bd",
                    imagePath: AssetsPath.masterDeveloper,
                    isLeader: true,
                    index: 0,
                  ),
                  _buildCard(
                    name: "Tasnim Jui",
                    role: "Member",
                    email: "jui15-5541@diu.edu.bd",
                    imagePath: AssetsPath.developer3,
                    index: 1,
                  ),
                  _buildCard(
                    name: "Musfiqur",
                    role: "Member",
                    email: "musfiqur15-4641@diu.edu.bd",
                    imagePath: AssetsPath.developer2,
                    index: 2,
                  ),
                  _buildCard(
                    name: "Masrafi",
                    role: "Member",
                    email: "amin15-5226@diu.edu.bd",
                    imagePath: AssetsPath.developer5,
                    index: 3,
                  ),
                  _buildCard(
                    name: "Avinandan",
                    role: "Member",
                    email: "roy15-4899@diu.edu.bd",
                    imagePath: AssetsPath.developer4,
                    index: 4,
                  ),
                ],
              ),
            ),
    );
  }
}
