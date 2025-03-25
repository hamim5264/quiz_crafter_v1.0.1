import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:quiz_crafter/about_us_screen.dart';
import 'package:quiz_crafter/model/category.dart';
import 'package:quiz_crafter/privacy_policy.dart';
import 'package:quiz_crafter/theme/theme.dart';
import 'package:quiz_crafter/view/auth/app_login_screen.dart';
import 'package:quiz_crafter/view/user/category_screen.dart';
import 'package:quiz_crafter/view/user/create_review_screen.dart';
import 'package:quiz_crafter/view/user/edit_user_profile_screen.dart';
import 'package:quiz_crafter/view/user/review_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Category> _allCategories = [];
  List<Category> _filteredCategories = [];
  List<String> _categoryFilters = ["All"];
  String _selectedFilter = "All";
  String userName = "";
  String userEmail = "";
  bool isLoading = true;
  String profileImageUrl = "";

  @override
  void initState() {
    super.initState();
    //_fetchCategories();
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    await _fetchUserInfo();
    await _fetchCategories();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString("userEmail") ?? "";

    if (email.isNotEmpty) {
      final userDoc =
          await FirebaseFirestore.instance.collection("users").doc(email).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        userName = "${data['firstName']} ${data['lastName']}";
        userEmail = data["email"];
        profileImageUrl = data["profileImage"] ?? "";
      }
    }
  }

  Future<void> _fetchCategories() async {
    final snapshot = await FirebaseFirestore.instance
        .collection("categories")
        .orderBy("createdAt", descending: true)
        .get();

    _allCategories = snapshot.docs
        .map((doc) => Category.fromMap(doc.id, doc.data()))
        .toList();

    _categoryFilters = ["All"] +
        _allCategories.map((category) => category.name).toSet().toList();
    _filteredCategories = _allCategories;
  }

  void _filterCategories(String query, {String? categoryFilter}) {
    setState(() {
      _filteredCategories = _allCategories.where((category) {
        final matchesSearch = category.name
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            category.description.toLowerCase().contains(query.toLowerCase());
        final matchesCategory = categoryFilter == null ||
            categoryFilter == "All" ||
            category.name.toLowerCase() == categoryFilter.toLowerCase();

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(
            backgroundColor: AppTheme.backgroundColors,
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.secondaryColor),
            ),
          )
        : Scaffold(
            backgroundColor: AppTheme.backgroundColors,
            drawer: Drawer(
              child: Column(
                children: [
                  Column(
                    children: [
                      UserAccountsDrawerHeader(
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor,
                        ),
                        currentAccountPicture: profileImageUrl.isNotEmpty
                            ? CircleAvatar(
                                backgroundImage: NetworkImage(profileImageUrl),
                              )
                            : CircleAvatar(
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.person,
                                  color: AppTheme.primaryColor,
                                  size: 30,
                                ),
                              ),
                        accountName: Text(
                          userName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        accountEmail: Text(
                          userEmail,
                        ),
                      ),
                      ListTile(
                        tileColor: AppTheme.primaryColor,
                        leading: Icon(
                          Icons.update,
                          color: AppTheme.secondaryColor,
                        ),
                        title: Text("View or Update Profile",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.backgroundColors,
                            )),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditProfileScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.reviews,
                      color: AppTheme.secondaryColor,
                      size: 24,
                    ),
                    title: Text(
                      "Review List",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReviewListScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.info_outline,
                      color: AppTheme.secondaryColor,
                      size: 24,
                    ),
                    title: Text(
                      "About Us",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AboutUsScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.privacy_tip_outlined,
                      color: AppTheme.secondaryColor,
                      size: 24,
                    ),
                    title: Text(
                      "Privacy Policy",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PrivacyPolicyScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.logout,
                      color: AppTheme.secondaryColor,
                      size: 24,
                    ),
                    title: Text(
                      "Logout",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AppLogInScreen()),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: AppTheme.secondaryColor,
                elevation: 0,
                child: Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CreateReviewScreen()));
                }),
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 260,
                  pinned: true,
                  floating: true,
                  centerTitle: false,
                  backgroundColor: AppTheme.primaryColor,
                  elevation: 0,
                  iconTheme: IconThemeData(
                    color: Colors.white,
                    size: 24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  title: Text(
                    "QuizCrafter",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryColor,
                      fontSize: 24,
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: SafeArea(
                      child: Column(
                        children: [
                          SizedBox(
                            height: kToolbarHeight + 16,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Welcome $userName!",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                      color: Colors.white,
                                    )),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  "Let's test your knowledge today",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: TextField(
                                    cursorColor: AppTheme.secondaryColor,
                                    controller: _searchController,
                                    onChanged: (value) =>
                                        _filterCategories(value),
                                    decoration: InputDecoration(
                                      hintText: "Search Categories...",
                                      prefixIcon: Icon(
                                        Icons.search,
                                        color: AppTheme.secondaryColor,
                                      ),
                                      suffixIcon: _searchController
                                              .text.isNotEmpty
                                          ? IconButton(
                                              onPressed: () {
                                                _searchController.clear();
                                                _filterCategories("");
                                              },
                                              icon: Icon(
                                                Icons.clear,
                                                color: AppTheme.secondaryColor,
                                              ),
                                            )
                                          : null,
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    collapseMode: CollapseMode.pin,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.all(16),
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categoryFilters.length,
                      itemBuilder: (context, index) {
                        final filter = _categoryFilters[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            right: 8,
                          ),
                          child: ChoiceChip(
                            checkmarkColor: Colors.white,
                            label: Text(
                              filter,
                              style: TextStyle(
                                color: _selectedFilter == filter
                                    ? Colors.white
                                    : AppTheme.textPrimaryColor,
                              ),
                            ),
                            selected: _selectedFilter == filter,
                            selectedColor: AppTheme.secondaryColor,
                            backgroundColor: Colors.white,
                            onSelected: (bool selected) {
                              setState(() {
                                _selectedFilter = filter;
                                _filterCategories(
                                  _searchController.text,
                                  categoryFilter: filter,
                                );
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.all(16),
                  sliver: _filteredCategories.isEmpty
                      ? SliverToBoxAdapter(
                          child: Center(
                            child: Text(
                              "No categories found",
                              style: TextStyle(
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                          ),
                        )
                      : SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildCategoryCard(
                              _filteredCategories[index],
                              index,
                            ),
                            childCount: _filteredCategories.length,
                          ),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  childAspectRatio: 0.75 //0.8,
                                  ),
                        ),
                ),
              ],
            ),
          );
  }

  Widget _buildCategoryCard(Category category, int index) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CategoryScreen(category: category)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.quiz, size: 48, color: AppTheme.primaryColor),
              ),
              SizedBox(height: 12),
              Flexible(
                child: Text(
                  category.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ),
              SizedBox(height: 6),
              Text(
                category.description,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 100 * index))
        .slideY(
          begin: 0.5,
          end: 0,
          duration: Duration(milliseconds: 300),
        )
        .fadeIn();
  }
}
