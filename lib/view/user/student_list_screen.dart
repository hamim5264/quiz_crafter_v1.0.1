import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:quiz_crafter/theme/theme.dart';
import 'package:quiz_crafter/widgets/body_background.dart';

class StudentListScreen extends StatelessWidget {
  const StudentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColors,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColors,
        title: Text(
          "Student List",
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        elevation: 0,
      ),
      body: BodyBackground(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("users")
              .where("role", isEqualTo: "student")
              .orderBy("createdAt", descending: true)
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
                  "No students found.",
                ),
              );
            }

            final students = snapshot.data!.docs;

            return ListView.builder(
              itemCount: students.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final student = students[index].data() as Map<String, dynamic>;

                return Card(
                  color: AppTheme.primaryColor,
                  child: ListTile(
                    leading: Icon(Icons.person, color: Colors.white),
                    title: Text(
                        "${student['firstName']} ${student['lastName']}",
                        style: TextStyle(color: Colors.white)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student['email'],
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          student['phone'] ?? '',
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ],
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
