import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:quiz_crafter/theme/theme.dart';
import 'package:quiz_crafter/widgets/body_background.dart';

class AllLeaderboardsScreen extends StatelessWidget {
  const AllLeaderboardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColors,
      appBar: AppBar(
        backgroundColor: AppTheme.secondaryColor,
        title: Text(
          "All Quiz Leaderboards",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: BodyBackground(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("leaderboard")
              .orderBy("percentage", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: AppTheme.secondaryColor,
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  "No leaderboard data found.",
                ),
              );
            }

            final entries = snapshot.data!.docs;

            return ListView.builder(
              itemCount: entries.length,
              padding: EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final data = entries[index].data();

                return Card(
                  color: AppTheme.primaryColor,
                  margin: EdgeInsets.only(
                    bottom: 12,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.secondaryColor,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(
                      "${data["userName"]} - ${data["quizTitle"]}",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "${data["score"]}/${data["totalQuestions"]} Correct",
                            style: TextStyle(color: Colors.grey[300])),
                        Text(
                          "${data["percentage"].toStringAsFixed(1)}%",
                          style: TextStyle(
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                      ],
                    ),
                    trailing: Text(
                      "${index + 1}",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  )
                      .animate(delay: Duration(milliseconds: 100 * index))
                      .slideY(begin: 0.3)
                      .fadeIn(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
