import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quiz_crafter/model/category.dart';
import 'package:quiz_crafter/theme/theme.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key, this.category});

  final Category? category;

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name);
    _descriptionController =
        TextEditingController(text: widget.category?.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      if (widget.category != null) {
        final updateCategory = widget.category!.copyWith(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
        );

        await _firestore
            .collection("categories")
            .doc(widget.category!.id)
            .update(
              updateCategory.toMap(),
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Category updated successfully",
              ),
            ),
          );
        }
      } else {
        await _firestore.collection("categories").add(
              Category(
                id: _firestore.collection("categories").doc().id,
                name: _nameController.text.trim(),
                description: _descriptionController.text.trim(),
                createdAt: DateTime.now(),
              ).toMap(),
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Category added successfully",
              ),
            ),
          );
        }
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      //print("Error saving category: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _onWilPop() async {
    if (_nameController.text.isNotEmpty ||
        _descriptionController.text.isNotEmpty) {
      return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                "Discard Changes?",
              ),
              content: Text(
                "Are you sure you want to discard changes?",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: Text(
                    "Cancel",
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: Text(
                    "Discard",
                    style: TextStyle(
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ],
            ),
          ) ??
          false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWilPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.secondaryColor,
          title: Text(
            widget.category != null ? "Edit Category" : "Add Category",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.backgroundColors,
            ),
          ),
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
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Category Details",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    "Create a new category for organizing your quizzes",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  TextFormField(
                    cursorColor: AppTheme.primaryColor,
                    textInputAction: TextInputAction.next,
                    controller: _nameController,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 20,
                      ),
                      labelText: "Category Name",
                      hintText: "Enter category name",
                      prefixIcon: Icon(
                        Icons.category_rounded,
                        color: AppTheme.primaryColor,
                      ),
                      labelStyle: TextStyle(color: AppTheme.primaryColor),
                      floatingLabelStyle: TextStyle(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Enter category name" : null,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    cursorColor: AppTheme.primaryColor,
                    textInputAction: TextInputAction.next,
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      alignLabelWithHint: false,
                      fillColor: Colors.white,
                      labelText: "Description",
                      hintText: "Enter category description",
                      prefixIcon: Icon(
                        Icons.description_rounded,
                        color: AppTheme.primaryColor,
                      ),
                      labelStyle: TextStyle(
                        color: AppTheme.primaryColor,
                      ),
                      floatingLabelStyle: TextStyle(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Enter description name" : null,
                  ),
                  SizedBox(
                    height: 32,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveCategory,
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.secondaryColor,
                                ),
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              widget.category != null
                                  ? "Update Category"
                                  : "Add Category",
                              style: TextStyle(
                                fontSize: 16,
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
