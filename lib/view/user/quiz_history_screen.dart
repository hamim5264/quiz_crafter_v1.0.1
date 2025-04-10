import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quiz_crafter/theme/theme.dart';
import 'package:quiz_crafter/widgets/body_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuizHistoryScreen extends StatefulWidget {
  const QuizHistoryScreen({super.key});

  @override
  State<QuizHistoryScreen> createState() => _QuizHistoryScreenState();
}

class _QuizHistoryScreenState extends State<QuizHistoryScreen> {
  String userEmail = "";

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString("userEmail") ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppTheme.backgroundColors,
        appBar: AppBar(
          title: Text(
            "Quiz History",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: AppTheme.secondaryColor,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: BodyBackground(
          child: userEmail.isEmpty
              ? Center(child: CircularProgressIndicator())
              : StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('leaderboard')
                      .where('userEmail', isEqualTo: userEmail)
                      .orderBy('attemptedAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.secondaryColor,
                        ),
                      );
                    }

                    final attempts = snapshot.data!.docs;

                    if (attempts.isEmpty) {
                      return Center(
                        child: Text(
                          "No quiz history found.",
                          style: TextStyle(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: attempts.length,
                      itemBuilder: (context, index) {
                        final data =
                            attempts[index].data() as Map<String, dynamic>;

                        final quizTitle = data['quizTitle'] ?? "Untitled";
                        final score = data['score'] ?? 0;
                        final total = data['totalQuestions'] ?? 0;
                        final percentage = (data['percentage'] ?? 0)
                            .toDouble()
                            .toStringAsFixed(1);
                        final attemptedAt = (data['attemptedAt'] as Timestamp)
                            .toDate()
                            .toLocal();
                        final formattedDate =
                            DateFormat('MMM d, yyyy – hh:mm a')
                                .format(attemptedAt);

                        return Card(
                          elevation: 3,
                          margin: EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Icon(Icons.assignment_turned_in,
                                color: AppTheme.secondaryColor),
                            title: Text(
                              quizTitle,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Score: $score / $total"),
                                Text("Percentage: $percentage%"),
                                Text("Date: $formattedDate"),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ));
  }
}
