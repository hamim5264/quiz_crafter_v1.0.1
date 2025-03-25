import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quiz_crafter/theme/theme.dart';
import 'package:quiz_crafter/widgets/body_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateReviewScreen extends StatefulWidget {
  const CreateReviewScreen({super.key});

  @override
  State<CreateReviewScreen> createState() => _CreateReviewScreenState();
}

class _CreateReviewScreenState extends State<CreateReviewScreen> {
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColors,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColors,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        title: Text(
          "Create Review",
          style: TextStyle(
            fontSize: 24,
            color: Colors.black,
          ),
        ),
      ),
      body: BodyBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                  TextFormField(
                    controller: _descController,
                    maxLines: 4,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: "Description",
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppTheme.secondaryColor,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _ratingController,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Rating(out of 5)",
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppTheme.secondaryColor,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_descController.text.trim().isEmpty ||
                            _ratingController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Please fill in all fields",
                              ),
                            ),
                          );
                          return;
                        }

                        final rating =
                            double.tryParse(_ratingController.text.trim());
                        if (rating == null || rating < 0 || rating > 5) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Rating must be between 0 and 5")));
                          return;
                        }

                        setState(() => _isLoading = true);

                        final prefs = await SharedPreferences.getInstance();
                        final userName =
                            prefs.getString("userName") ?? "Unknown";
                        await FirebaseFirestore.instance
                            .collection("reviews")
                            .add({
                          "userName": userName,
                          "description": _descController.text.trim(),
                          "rating": rating,
                          "createdAt": Timestamp.now(),
                        });

                        setState(() => _isLoading = false);

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                            "Review submitted successfully!",
                          ),
                        ));
                      },
                      child: const Text(
                        "SUBMIT",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
