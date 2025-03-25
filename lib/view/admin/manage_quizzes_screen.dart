import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quiz_crafter/model/category.dart';
import 'package:quiz_crafter/model/quiz.dart';
import 'package:quiz_crafter/theme/theme.dart';
import 'package:quiz_crafter/view/admin/add_quiz_screen.dart';
import 'package:quiz_crafter/view/admin/edit_quiz_screen.dart';

class ManageQuizzesScreen extends StatefulWidget {
  const ManageQuizzesScreen({super.key, this.categoryId, this.categoryName});

  final String? categoryId;
  final String? categoryName;

  @override
  State<ManageQuizzesScreen> createState() => _ManageQuizzesScreenState();
}

class _ManageQuizzesScreenState extends State<ManageQuizzesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String? _selectedCategoryId;
  List<Category> _categories = [];
  Category? _initialCategory;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final QuerySnapshot = await _firestore.collection("categories").get();
      final categories = QuerySnapshot.docs
          .map((doc) => Category.fromMap(doc.id, doc.data()))
          .toList();
      setState(() {
        _categories = categories;
        if (widget.categoryId != null) {
          _selectedCategoryId = widget.categoryId;
          _initialCategory = _categories.firstWhere(
            (category) => category.id == widget.categoryId,
            orElse: () => Category(
              id: widget.categoryId!,
              name: "Unknown",
              description: "",
            ),
          );
          _selectedCategoryId = _initialCategory!.id;
        }
      });
    } catch (e) {
      //print("Error Fetching Categories: $e");
    }
  }

  Stream<QuerySnapshot> _getQuizzesStream() {
    Query query = _firestore.collection("quizzes");
    String? filterCategoryId = _selectedCategoryId ?? widget.categoryId;

    if (filterCategoryId != null) {
      query = query.where("categoryId", isEqualTo: filterCategoryId);
    }
    return query.snapshots();
  }

  Widget _buildTitle() {
    String? categoryId = _selectedCategoryId ?? widget.categoryId;
    if (categoryId == null) {
      return Text(
        "All Quizzes",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppTheme.backgroundColors,
        ),
      );
    }
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection("categories").doc(categoryId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Text(
            "Loading...",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          );
        }
        final category = Category.fromMap(
          categoryId,
          snapshot.data!.data() as Map<String, dynamic>,
        );
        return Text(
          category.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.secondaryColor,
        title: _buildTitle(),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddQuizScreen(
                            categoryId: widget.categoryId,
                            categoryName: widget.categoryName,
                          )));
            },
            icon: Icon(
              Icons.add_circle_outline,
              color: AppTheme.backgroundColors,
            ),
          ),
        ],
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              cursorColor: AppTheme.primaryColor,
              controller: _searchController,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                hintText: "Search Quizzes",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 18,
                  ),
                  border: OutlineInputBorder(),
                ),
                hint: Text("Category"),
                value: _selectedCategoryId,
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(
                      "All Categories",
                    ),
                  ),
                  if (_initialCategory != null &&
                      _categories.every((c) => c.id != _initialCategory!.id))
                    DropdownMenuItem(
                      value: _initialCategory!.id,
                      child: Text(_initialCategory!.name),
                    ),
                  ..._categories.map((category) => DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      )),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                }),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getQuizzesStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text("Error: ${snapshot.error}"),
                  );
                }
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.secondaryColor,
                    ),
                  );
                }

                final quizzes = snapshot.data!.docs
                    .map((doc) => Quiz.fromMap(
                        doc.id, doc.data() as Map<String, dynamic>))
                    .where((quiz) =>
                        _searchQuery.isEmpty ||
                        quiz.title.toLowerCase().contains(_searchQuery))
                    .toList();
                if (quizzes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.quiz_outlined,
                          size: 64,
                          color: AppTheme.textSecondaryColor,
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Text(
                          "No quizzes ye",
                          style: TextStyle(
                            fontSize: 18,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddQuizScreen(
                                          categoryId: widget.categoryId,
                                          categoryName: widget.categoryName,
                                        )));
                          },
                          child: Text(
                            "Add Quiz",
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: quizzes.length,
                  itemBuilder: (context, index) {
                    final Quiz quiz = quizzes[index];
                    return Card(
                      margin: EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.quiz_rounded,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        contentPadding: EdgeInsets.all(8),
                        title: Text(
                          quiz.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          children: [
                            SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.question_answer_outlined,
                                  size: 14,
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  "${quiz.questions.length} Questions",
                                ),
                                SizedBox(
                                  width: 14,
                                ),
                                Icon(
                                  Icons.timer_outlined,
                                  size: 14,
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  "${quiz.timeLimit} mints",
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: "edit",
                              child: ListTile(
                                leading: Icon(
                                  Icons.edit,
                                  color: AppTheme.primaryColor,
                                ),
                                title: Text(
                                  "Edit",
                                ),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            PopupMenuItem(
                              value: "delete",
                              child: ListTile(
                                leading: Icon(
                                  Icons.delete,
                                  color: AppTheme.secondaryColor,
                                ),
                                title: Text(
                                  "Delete",
                                ),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                          onSelected: (value) =>
                              _handleQuizAction(context, value, quiz),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleQuizAction(
      BuildContext context, String value, Quiz quiz) async {
    if (value == "edit") {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditQuizScreen(quiz: quiz),
          ));
    } else if (value == "delete") {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            "Delete Quiz",
          ),
          content: Text("Are you sure you want to delete this quiz?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text(
                "Delete",
                style: TextStyle(
                  color: Colors.redAccent,
                ),
              ),
            ),
          ],
        ),
      );
      if (confirm == true) {
        await _firestore.collection("quizzes").doc(quiz.id).delete();
      }
    }
  }
}
