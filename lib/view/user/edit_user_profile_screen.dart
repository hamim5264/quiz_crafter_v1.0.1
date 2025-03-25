import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quiz_crafter/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();

  String email = '';

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    email = prefs.getString("userEmail") ?? "";

    final doc =
        await FirebaseFirestore.instance.collection("users").doc(email).get();
    if (doc.exists) {
      final data = doc.data()!;
      _firstName.text = data["firstName"];
      _lastName.text = data["lastName"];
      _phone.text = data["phone"];
      _address.text = data["address"];
      setState(() {});
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    await FirebaseFirestore.instance.collection("users").doc(email).update({
      "firstName": _firstName.text.trim(),
      "lastName": _lastName.text.trim(),
      "phone": _phone.text.trim(),
      "address": _address.text.trim(),
    });

    final fullName = "${_firstName.text.trim()} ${_lastName.text.trim()}";
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("userName", fullName);

    setState(() => _loading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 10),
              Text(
                "Profile updated successfully!",
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
    await Future.delayed(Duration(seconds: 1));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColors,
      appBar: AppBar(
        title: Text(
          "Edit Profile",
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.secondaryColor,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(color: AppTheme.secondaryColor))
          : SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Profile image upload coming soon!",
                            ),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        backgroundColor: AppTheme.cardColor,
                        radius: 50,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    TextFormField(
                      controller: _firstName,
                      decoration: const InputDecoration(
                        labelText: "First Name",
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppTheme.secondaryColor,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      validator: (value) => value!.isEmpty ? "Required" : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _lastName,
                      decoration: const InputDecoration(
                        labelText: "Last Name",
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppTheme.secondaryColor,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      validator: (value) => value!.isEmpty ? "Required" : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _phone,
                      decoration: const InputDecoration(
                        labelText: "Phone",
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppTheme.secondaryColor,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      validator: (value) => value!.isEmpty ? "Required" : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _address,
                      decoration: const InputDecoration(
                        labelText: "Address",
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppTheme.secondaryColor,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      validator: (value) => value!.isEmpty ? "Required" : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      initialValue: email,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppTheme.secondaryColor,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        child: Text(
                          "Save",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
