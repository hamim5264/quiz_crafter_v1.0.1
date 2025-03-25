import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quiz_crafter/model/category.dart';
import 'package:quiz_crafter/theme/theme.dart';
import 'package:quiz_crafter/view/admin/add_category_screen.dart';
import 'package:quiz_crafter/view/admin/manage_quizzes_screen.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.secondaryColor,
        title: Text(
          "Manage Categories",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.backgroundColors,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddCategoryScreen(),
                  ));
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
      body: StreamBuilder<QuerySnapshot>(
          stream:
              _firestore.collection("categories").orderBy("name").snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text("Error: ${snapshot.error}"),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: AppTheme.secondaryColor,
                ),
              );
            }
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  color: AppTheme.secondaryColor,
                ),
              );
            }
            final categories = snapshot.data!.docs
                .map((doc) => Category.fromMap(
                    doc.id, doc.data() as Map<String, dynamic>))
                .toList();
            if (categories.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: 64,
                      color: AppTheme.textSecondaryColor,
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      "No categories found",
                      style: TextStyle(
                        fontSize: 18,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddCategoryScreen(),
                            ));
                      },
                      child: Text(
                        "Add Category",
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final Category category = categories[index];
                  return Card(
                    margin: EdgeInsets.only(
                      bottom: 12,
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      leading: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.category_outlined,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      title: Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        category.description,
                        style: TextStyle(
                          fontSize: 14,
                        ),
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
                        onSelected: (value) {
                          _handleCategoryAction(context, value, category);
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ManageQuizzesScreen(
                              categoryId: category.id,
                              categoryName: category.name,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                });
          }),
    );
  }

  Future<void> _handleCategoryAction(
      BuildContext context, String action, Category category) async {
    if (action == "edit") {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddCategoryScreen(category: category),
          ));
    } else if (action == "delete") {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            "Delete Category",
          ),
          content: Text("Are you sure you want to delete this category?"),
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
                )),
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
            )
          ],
        ),
      );
      if (confirm == true) {
        await _firestore.collection("categories").doc(category.id).delete();
      }
    }
  }
}
