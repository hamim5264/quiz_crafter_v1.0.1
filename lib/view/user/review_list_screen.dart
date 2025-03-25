import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:quiz_crafter/theme/theme.dart';
import 'package:quiz_crafter/widgets/body_background.dart';

class ReviewListScreen extends StatefulWidget {
  const ReviewListScreen({super.key});

  @override
  State<ReviewListScreen> createState() => _ReviewListScreenState();
}

class _ReviewListScreenState extends State<ReviewListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColors,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColors,
        title: Text(
          "Review List",
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
          ),
        ),
      ),
      body: BodyBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("reviews")
                  .orderBy("createdAt", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.secondaryColor));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No reviews yet."));
                }

                final reviews = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final review = reviews[index].data();
                    return Card(
                      color: AppTheme.primaryColor,
                      child: ListTile(
                        title: Text(
                          review["userName"] ?? "",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        subtitle: Text(
                          review["description"] ?? "",
                          style:
                              TextStyle(color: Colors.grey[300], fontSize: 12),
                        ),
                        trailing: Text(
                          "⭐ ${review["rating"].toString()}",
                          style: TextStyle(color: Colors.white),
                        ),
                        leading: Icon(Icons.person, color: Colors.white),
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
        ),
      ),
    );
  }
}
