import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quiz_crafter/about_us_screen.dart';
import 'package:quiz_crafter/privacy_policy.dart';
import 'package:quiz_crafter/theme/theme.dart';
import 'package:quiz_crafter/view/admin/all_leader_board_screen.dart';
import 'package:quiz_crafter/view/admin/manage_categories_screen.dart';
import 'package:quiz_crafter/view/admin/manage_quizzes_screen.dart';
import 'package:quiz_crafter/view/auth/app_login_screen.dart';
import 'package:quiz_crafter/view/user/review_list_screen.dart';
import 'package:quiz_crafter/view/user/student_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<Map<String, dynamic>> _statisticsFuture;

  Future<Map<String, dynamic>> _fetchStatistics() async {
    final categoriesCount =
        await _firestore.collection("categories").count().get();
    final quizzesCount = await _firestore.collection("quizzes").count().get();

    final latestQuizzes = await _firestore
        .collection("quizzes")
        .orderBy("createdAt", descending: true)
        .limit(5)
        .get();
    final categories = await _firestore.collection("categories").get();

    final categoryData =
        await Future.wait(categories.docs.map((category) async {
      final quizCount = await _firestore
          .collection("quizzes")
          .where("categoryId", isEqualTo: category.id)
          .count()
          .get();
      return {
        "name": category.data()["name"] as String,
        "count": quizCount.count,
      };
    }));
    return {
      "totalCategories": categoriesCount.count,
      "totalQuizzes": quizzesCount.count,
      "latestQuizzes": latestQuizzes.docs,
      "categoryData": categoryData,
    };
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 25,
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 32,
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              textAlign: TextAlign.center,
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
          ]),
        ),
      ),
    );
  }

  String userEmail = "";

  @override
  void initState() {
    super.initState();
    _loadAdminInfo();
    _statisticsFuture = _fetchStatistics();
  }

  Future<void> _refreshDashboard() async {
    setState(() {
      _statisticsFuture = _fetchStatistics();
    });
  }

  Future<void> _loadAdminInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString('userEmail') ?? "admin@quizcrafter.com";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.5),
      appBar: AppBar(
        backgroundColor: AppTheme.secondaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Admin Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.backgroundColors,
          ),
        ),
        elevation: 0,
      ),
      drawer: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: AppTheme.primaryColor,
        ),
        child: Drawer(
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: AppTheme.secondaryColor),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.admin_panel_settings,
                    color: AppTheme.primaryColor,
                    size: 30,
                  ),
                ),
                accountName: Text(
                  "Administrator",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                accountEmail: Text(userEmail),
              ),
              ListTile(
                leading: Icon(
                  Icons.category_rounded,
                  color: AppTheme.secondaryColor,
                  size: 24,
                ),
                title: Text(
                  "Manage Categories",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ManageCategoriesScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.quiz_rounded,
                  color: AppTheme.secondaryColor,
                  size: 24,
                ),
                title: Text(
                  "Manage Quizzes",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ManageQuizzesScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.reviews,
                    color: AppTheme.secondaryColor, size: 24),
                title: Text(
                  "Review List",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReviewListScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.supervised_user_circle,
                    color: AppTheme.secondaryColor, size: 24),
                title: Text(
                  "Student List",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => StudentListScreen()));
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.leaderboard,
                  color: AppTheme.secondaryColor,
                ),
                title: Text(
                  "All Leaderboards",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AllLeaderboardsScreen(),
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
              // Spacer(),
              // Divider(color: AppTheme.secondaryColor),
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
                      builder: (_) => AppLogInScreen(),
                    ),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        color: AppTheme.secondaryColor,
        child: FutureBuilder(
            future: _fetchStatistics(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.secondaryColor,
                  ),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text("Error: ${snapshot.error}"),
                );
              }
              final Map<String, dynamic> stats = snapshot.data!;
              final List<dynamic> categoryData = stats["categoryData"];
              final List<QueryDocumentSnapshot> latestQuizzes =
                  stats["latestQuizzes"];
              return SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome Admin",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.backgroundColors,
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        "Here's your QuizCrafter overview",
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.backgroundColors,
                        ),
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              "Total Categories",
                              stats["totalCategories"].toString(),
                              Icons.category_rounded,
                              AppTheme.secondaryColor,
                            ),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Expanded(
                            child: _buildStatCard(
                              "Total Quizzes",
                              stats["totalQuizzes"].toString(),
                              Icons.quiz_outlined,
                              AppTheme.secondaryColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.pie_chart_rounded,
                                    color: AppTheme.primaryColor,
                                    size: 24,
                                  ),
                                  SizedBox(
                                    width: 12,
                                  ),
                                  Text(
                                    "Category Statistics",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: categoryData.length,
                                  itemBuilder: (context, index) {
                                    final category = categoryData[index];
                                    final totalQuizzes = categoryData.fold<int>(
                                      0,
                                      (sum, item) =>
                                          sum + (item["count"] as int),
                                    );
                                    final percentage = totalQuizzes > 0
                                        ? (category["count"] as int) /
                                            totalQuizzes *
                                            100
                                        : 0.0;
                                    return Padding(
                                      padding: EdgeInsets.only(bottom: 16),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              children: [
                                                Text(
                                                  category["name"],
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: AppTheme
                                                        .textPrimaryColor,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  "${category["count"]} ${(category["count"] as int) == 1 ? "Quiz" : "Quizzes"}",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: AppTheme
                                                        .textSecondaryColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryColor
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              "${percentage.toStringAsFixed(1)}%",
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: AppTheme.primaryColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.history_rounded,
                                    color: AppTheme.primaryColor,
                                    size: 24,
                                  ),
                                  SizedBox(
                                    width: 12,
                                  ),
                                  Text(
                                    "Recent Activity",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: latestQuizzes.length,
                                  itemBuilder: (context, index) {
                                    final quiz = latestQuizzes[index].data()
                                        as Map<String, dynamic>;
                                    return Padding(
                                      padding: EdgeInsets.only(bottom: 16),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryColor
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.quiz_rounded,
                                              color: AppTheme.primaryColor,
                                              size: 20,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 16,
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  quiz["title"],
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: AppTheme
                                                        .textPrimaryColor,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 4,
                                                ),
                                                Text(
                                                  "Created on ${_formatDate(quiz["createdAt"].toDate())}",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: AppTheme
                                                        .textPrimaryColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.speed_rounded,
                                    color: AppTheme.primaryColor,
                                    size: 24,
                                  ),
                                  SizedBox(
                                    width: 12,
                                  ),
                                  Text(
                                    "Quiz Actions",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              GridView.count(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.9,
                                crossAxisSpacing: 16,
                                shrinkWrap: true,
                                children: [
                                  _buildDashboardCard(
                                    context,
                                    "Quizzes",
                                    Icons.add_rounded,
                                    () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ManageQuizzesScreen()));
                                    },
                                  ),
                                  _buildDashboardCard(
                                    context,
                                    "Categories",
                                    Icons.add_rounded,
                                    () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ManageCategoriesScreen()));
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }
}
