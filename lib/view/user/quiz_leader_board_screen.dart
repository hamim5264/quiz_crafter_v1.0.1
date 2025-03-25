import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:quiz_crafter/theme/theme.dart';
import 'package:quiz_crafter/widgets/body_background.dart';

class QuizLeaderboardScreen extends StatelessWidget {
  final String quizId;
  final String quizTitle;

  const QuizLeaderboardScreen(
      {super.key, required this.quizId, required this.quizTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColors,
      appBar: AppBar(
        title: Text(
          "Leaderboard - $quizTitle",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppTheme.secondaryColor,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: BodyBackground(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('leaderboard')
              .where('quizId', isEqualTo: quizId)
              .orderBy('percentage', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  color: AppTheme.secondaryColor,
                ),
              );
            }
            final docs = snapshot.data!.docs;
            if (docs.isEmpty) {
              return Center(
                child: Text(
                  "No leaderboard data available",
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final user = docs[index].data();
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.only(bottom: 12),
                  color: AppTheme.primaryColor,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.secondaryColor,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      user["userName"] ?? "Unknown",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${user["score"]}/${user["totalQuestions"]} Correct",
                          style: TextStyle(color: Colors.grey[300]),
                        ),
                        Text(
                          "${user["percentage"].toStringAsFixed(1)}%",
                          style: TextStyle(
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (index == 0)
                          Icon(
                            Icons.emoji_events,
                            color: Colors.amber,
                          )
                        else if (index == 1)
                          Icon(
                            Icons.emoji_events,
                            color: Colors.grey,
                          )
                        else if (index == 2)
                          Icon(Icons.emoji_events, color: Color(0xFFCD7F32))
                        else
                          SizedBox.shrink(),
                        SizedBox(width: 6),
                        Text(
                          "#${index + 1}",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn().slideY(
                    begin: 0.2 * index, duration: Duration(milliseconds: 300));
              },
            );
          },
        ),
      ),
    );
  }
}
