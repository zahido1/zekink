import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  
  Map<String, dynamic> userData = {};
  Map<String, dynamic> childData = {};
  Map<String, dynamic> analyticsData = {};
  List<Map<String, dynamic>> recentActivities = [];
  List<String> todaysBadges = [];
  bool isLoading = true;
  String parentName = "Parent";
  String childName = "Your Child";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _fetchOrGenerateData(user.uid);
      }
    } catch (e) {
      print("Error loading data: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchOrGenerateData(String uid) async {
    try {
      
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        userData = userDoc.data() ?? {};
        parentName = userData['name'] ?? "Parent";
      }

      
      final childDoc = await _firestore.collection('children').doc(uid).get();
      if (childDoc.exists) {
        childData = childDoc.data() ?? {};
        childName = childData['childName'] ?? "Your Child";
      }

      
      final analyticsDoc = await _firestore.collection('analytics').doc(uid).get();
      if (analyticsDoc.exists) {
        analyticsData = analyticsDoc.data() ?? {};
        print("Analytics data loaded from Firebase: $analyticsData");
      }

      
      try {
        final activitiesQuery = await _firestore
            .collection('activities')
            .where('userId', isEqualTo: uid)
            .orderBy('timestamp', descending: true)
            .limit(4)
            .get();
        recentActivities = activitiesQuery.docs.map((doc) => doc.data()).toList();
        print("Fetched ${recentActivities.length} activities from Firebase");
      } catch (e) {
        print("Error fetching activities (may need index): $e");
        
        recentActivities = _generateRecentActivities();
        print("Generated ${recentActivities.length} activities locally");
      }

      
      if (analyticsData.isEmpty) {
        print("No analytics data found, generating initial data...");
        await _generateAndStoreStaticData(uid);
      } else {
        print("Using existing analytics data from Firebase");
        
        todaysBadges = List<String>.from(analyticsData['todaysBadges'] ?? []);
        
        
        if (recentActivities.isEmpty) {
          print("No activities found, generating some for display...");
          recentActivities = _generateRecentActivities();
        }
      }

      
      if ((analyticsData['todaysBadges'] as List?)?.isEmpty ?? true) {
        await _generateTodaysBadges(uid);
      }

    } catch (e) {
      print("Error fetching data: $e");
      
      final analyticsDoc = await _firestore.collection('analytics').doc(uid).get();
      if (!analyticsDoc.exists) {
        await _generateAndStoreStaticData(uid);
      }
    }
  }

  Future<void> _generateAndStoreStaticData(String uid) async {
    final random = Random();

    
    analyticsData = {
      'focusScore': 65 + random.nextInt(30), 
      'studyTime': (2 + random.nextDouble() * 3).toStringAsFixed(1), 
      'dayStreak': 1 + random.nextInt(14), 
      'totalBadges': 8 + random.nextInt(20), 
      'weeklyStudyTime': 8.5 + random.nextDouble() * 8, 
      'weeklyFocusTarget': 78 + random.nextInt(15), 
      'weeklyAssignments': 4 + random.nextInt(3), 
      'weeklyAssignmentsTotal': 6,
      'screenTimeHours': 2 + random.nextDouble() * 3, 
      'appUsageCount': 15 + random.nextInt(20), 
      'riskLevel': ['Low', 'Medium', 'High'][random.nextInt(3)],
      'lastActiveTime': DateTime.now().subtract(Duration(minutes: random.nextInt(120))).toIso8601String(),
      'todaysBadges': _getRandomBadges(),
      'lastUpdated': DateTime.now().toIso8601String(),
      'dataGenerated': true, 
    };

    
    recentActivities = _generateRecentActivities();

    try {
      
      await _firestore.collection('analytics').doc(uid).set(analyticsData);
      print("Generated and stored new analytics data");

      
      if (recentActivities.isNotEmpty) {
        try {
          final batch = _firestore.batch();
          for (int i = 0; i < recentActivities.length; i++) {
            final activityRef = _firestore.collection('activities').doc();
            batch.set(activityRef, {
              ...recentActivities[i],
              'userId': uid,
              'id': activityRef.id,
            });
          }
          await batch.commit();
          print("Stored ${recentActivities.length} activities to Firebase");
        } catch (e) {
          print("Error storing activities: $e");
          
        }
      }

      
      todaysBadges = List<String>.from(analyticsData['todaysBadges'] ?? []);

      print("Static data generated and stored successfully");
    } catch (e) {
      print("Error storing static data: $e");
    }
  }

  Future<void> _generateTodaysBadges(String uid) async {
    final badges = _getRandomBadges();
    analyticsData['todaysBadges'] = badges;
    try {
      await _firestore.collection('analytics').doc(uid).update({
        'todaysBadges': badges,
        'lastUpdated': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print("Error updating badges: $e");
    }
  }

  List<String> _getRandomBadges() {
    final allBadges = [
      "🎯 Focus Master",
      "📚 Study Champion",
      "⏱️ Time Manager",
      "🔥 Learning Streak",
      "🏆 Achievement Unlocked",
      "⭐ Star Performer",
      "🧠 Brain Booster",
      "📱 Screen Balance",
    ];
    final random = Random();
    final numBadges = 2 + random.nextInt(4); 
    allBadges.shuffle();
    return allBadges.take(numBadges).toList();
  }

  List<Map<String, dynamic>> _generateRecentActivities() {
    final activities = [
      "$childName started study session",
      "Focus milestone achieved by $childName",
      "$childName completed homework",
      "New learning badge earned",
      "Study goal reached for today",
      "$childName took a healthy break",
      "Assignment submitted on time",
      "Screen time limit respected",
    ];
    final times = ["2 min ago", "15 min ago", "1 hour ago", "2 hours ago"];
    final random = Random();

    return List.generate(4, (index) {
      return {
        'title': activities[random.nextInt(activities.length)],
        'time': times[index],
        'timestamp': DateTime.now().subtract(Duration(minutes: [2, 15, 60, 120][index])).toIso8601String(),
        'type': 'activity',
      };
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning";
    if (hour < 17) return "Good afternoon";
    return "Good evening";
  }

  Color _getFocusColor(int focusScore) {
    if (focusScore >= 80) return Colors.green;
    if (focusScore >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getFocusMessage(int focusScore) {
    if (focusScore >= 80) return "$childName has excellent focus today!";
    if (focusScore >= 60) return "$childName is doing well, minor distractions noted.";
    return "$childName needs support with focus today.";
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              
            ],
          ),
        ),
      );
    }

    final focusScore = analyticsData['focusScore'] ?? 75;
    final studyTime = analyticsData['studyTime'] ?? "2.5";
    final dayStreak = analyticsData['dayStreak'] ?? 7;
    final totalBadges = analyticsData['totalBadges'] ?? 12;
    final weeklyStudyTime = analyticsData['weeklyStudyTime'] ?? 8.5;
    final weeklyFocusTarget = analyticsData['weeklyFocusTarget'] ?? 78;
    final weeklyAssignments = analyticsData['weeklyAssignments'] ?? 4;
    final weeklyAssignmentsTotal = analyticsData['weeklyAssignmentsTotal'] ?? 6;
    final screenTimeHours = (analyticsData['screenTimeHours'] ?? 3.0).toStringAsFixed(1);
    final appUsageCount = analyticsData['appUsageCount'] ?? 25;
    final riskLevel = analyticsData['riskLevel'] ?? 'Low';
    final lastActiveTime = analyticsData['lastActiveTime'] ?? DateTime.now().toIso8601String();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadUserData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${_getGreeting()}, ${parentName.split(' ').first}!",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Here's how $childName is doing today",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Focus Level",
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              "$focusScore%",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Stack(
                          children: [
                            Container(
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            Container(
                              height: 10,
                              width: MediaQuery.of(context).size.width * (focusScore / 100) * 0.75,
                              decoration: BoxDecoration(
                                color: _getFocusColor(focusScore),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getFocusMessage(focusScore),
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _infoCard("$dayStreak", "Day Streak", Icons.local_fire_department, Colors.orange),
                  _infoCard("${studyTime}h", "Study Today", Icons.access_time, Colors.blue),
                  _infoCard("$totalBadges", "Badges", Icons.emoji_events, Colors.amber),
                ],
              ),
              const SizedBox(height: 16),

              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Safety & Screen Time",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _safetyMetric("Risk Level", riskLevel, _getRiskColor(riskLevel)),
                        _safetyMetric("Screen Time", "${screenTimeHours}h", Colors.blue),
                        _safetyMetric("Apps Used", "$appUsageCount", Colors.purple),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Last active: ${_formatLastActiveTime(lastActiveTime)}",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              
              const Text(
                "Weekly Progress",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _progressTile(
                "Study Time",
                "${weeklyStudyTime.toStringAsFixed(1)} / 12 hours",
                weeklyStudyTime / 12,
              ),
              _progressTile(
                "Focus Score",
                "$weeklyFocusTarget / 85 %",
                weeklyFocusTarget / 85,
              ),
              _progressTile(
                "Assignments",
                "$weeklyAssignments / $weeklyAssignmentsTotal completed",
                weeklyAssignments / weeklyAssignmentsTotal,
              ),
              const SizedBox(height: 16),

              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recent Activity",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: _loadUserData,
                    child: const Text("Refresh"),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (recentActivities.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.grey),
                      SizedBox(width: 12),
                      Text(
                        "No recent activities to show",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              else
                ...recentActivities.map((activity) => _activityTile(
                      activity['title'] ?? "Activity",
                      activity['time'] ?? "Just now",
                    )),
              const SizedBox(height: 16),

              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$childName's Achievements Today",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: todaysBadges.map((badge) {
                        return _badge(badge, _getBadgeColor(badge));
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Your child is building great learning habits! Keep encouraging them.",
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _formatLastActiveTime(String timestamp) {
    try {
      final time = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(time);

      if (difference.inMinutes < 60) {
        return "${difference.inMinutes}m ago";
      } else if (difference.inHours < 24) {
        return "${difference.inHours}h ago";
      } else {
        return "${difference.inDays}d ago";
      }
    } catch (e) {
      return "Recently";
    }
  }

  Color _getBadgeColor(String badge) {
    if (badge.contains('Focus')) return Colors.orange;
    if (badge.contains('Study')) return Colors.green;
    if (badge.contains('Time')) return Colors.blue;
    if (badge.contains('Streak') || badge.contains('Learning')) return Colors.red;
    if (badge.contains('Achievement')) return Colors.purple;
    if (badge.contains('Star')) return Colors.amber;
    if (badge.contains('Brain')) return Colors.indigo;
    if (badge.contains('Screen')) return Colors.teal;
    return Colors.grey;
  }

  Widget _infoCard(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _safetyMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _progressTile(String title, String subtitle, double progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.grey.shade200,
            color: Colors.blue,
            minHeight: 8,
            borderRadius: BorderRadius.circular(6),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _activityTile(String title, String time) {
    return ListTile(
      leading: const Icon(Icons.notifications, color: Colors.blue),
      title: Text(title),
      subtitle: Text(time, style: const TextStyle(color: Colors.grey)),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 13)),
    );
  }
}