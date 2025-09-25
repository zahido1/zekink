import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zekink/onboarding.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String selectedLanguage = 'English';
  bool pushNotifications = true;
  bool focusAlerts = true;
  bool dailyReminders = true;
  bool achievementNotifications = true;
  bool darkMode = false;
  bool soundEffects = true;
  bool parentalControls = true;
  bool dataSharing = false;
  bool isLoading = true;
  
  
  String parentName = "Parent Account";
  int childrenCount = 1;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final userData = userDoc.data() ?? {};
          setState(() {
            parentName = userData['name'] ?? "Parent Account";
          });
        }

        
        final childrenQuery = await _firestore
            .collection('children')
            .where('parentId', isEqualTo: user.uid)
            .get();
        
        setState(() {
          childrenCount = childrenQuery.docs.length;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading user data: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      if (mounted) {
        
        Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => OnboardingScreen(),
                        ),
                        (Route<dynamic> route) => false,
                      );

      }
    } catch (e) {
      print("Error signing out: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error signing out: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4A5568), Color(0xFF2D3748)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.settings,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Settings",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Customize your Zekink experience",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            
            _buildSection(
              title: "Account",
              children: [
                _buildAccountCard(),
                const SizedBox(height: 16),
                _buildSettingsItem(
                  icon: Icons.person,
                  title: "Profile Settings",
                  subtitle: "Update your personal information",
                  onTap: () {},
                ),
                _buildSettingsItem(
                  icon: Icons.star,
                  title: "Premium Subscription",
                  subtitle: "Manage your premium features",
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "Pro",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () {},
                ),
                _buildSettingsItem(
                  icon: Icons.family_restroom,
                  title: "Family Management",
                  subtitle: "Manage children and family settings",
                  onTap: () {},
                ),
              ],
            ),

            
            _buildSection(
              title: "Language",
              children: [
                _buildLanguageGrid(),
              ],
            ),

            
            _buildSection(
              title: "Notifications",
              children: [
                _buildSwitchItem(
                  icon: Icons.notifications,
                  title: "Push Notifications",
                  subtitle: "Receive app notifications",
                  value: pushNotifications,
                  onChanged: (value) {
                    setState(() => pushNotifications = value);
                  },
                ),
                _buildSwitchItem(
                  icon: Icons.psychology,
                  title: "Focus Alerts",
                  subtitle: "Get notified about focus changes",
                  value: focusAlerts,
                  onChanged: (value) {
                    setState(() => focusAlerts = value);
                  },
                ),
                _buildSwitchItem(
                  icon: Icons.schedule,
                  title: "Daily Reminders",
                  subtitle: "Remind me to study daily",
                  value: dailyReminders,
                  onChanged: (value) {
                    setState(() => dailyReminders = value);
                  },
                ),
                _buildSwitchItem(
                  icon: Icons.emoji_events,
                  title: "Achievement Notifications",
                  subtitle: "Celebrate your accomplishments",
                  value: achievementNotifications,
                  onChanged: (value) {
                    setState(() => achievementNotifications = value);
                  },
                ),
              ],
            ),

            
            _buildSection(
              title: "Appearance",
              children: [
                _buildSwitchItem(
                  icon: Icons.dark_mode,
                  title: "Dark Mode",
                  subtitle: "Use dark theme",
                  value: darkMode,
                  onChanged: (value) {
                    setState(() => darkMode = value);
                  },
                ),
                _buildSwitchItem(
                  icon: Icons.volume_up,
                  title: "Sound Effects",
                  subtitle: "Play sounds for interactions",
                  value: soundEffects,
                  onChanged: (value) {
                    setState(() => soundEffects = value);
                  },
                ),
                _buildSettingsItem(
                  icon: Icons.palette,
                  title: "Theme Customization",
                  subtitle: "Customize colors and themes",
                  onTap: () {},
                ),
              ],
            ),

            
            _buildSection(
              title: "Privacy & Security",
              children: [
                _buildSwitchItem(
                  icon: Icons.family_restroom,
                  title: "Parental Controls",
                  subtitle: "Enable parental supervision",
                  value: parentalControls,
                  onChanged: (value) {
                    setState(() => parentalControls = value);
                  },
                ),
                _buildSwitchItem(
                  icon: Icons.share,
                  title: "Data Sharing",
                  subtitle: "Share analytics for improvement",
                  value: dataSharing,
                  onChanged: (value) {
                    setState(() => dataSharing = value);
                  },
                ),
                _buildSettingsItem(
                  icon: Icons.privacy_tip,
                  title: "Privacy Policy",
                  subtitle: "Read our privacy policy",
                  onTap: () {},
                ),
                _buildSettingsItem(
                  icon: Icons.description,
                  title: "Terms of Service",
                  subtitle: "View terms and conditions",
                  onTap: () {},
                ),
              ],
            ),

            
            _buildSection(
              title: "Support",
              children: [
                _buildSettingsItem(
                  icon: Icons.help_center,
                  title: "Help Center",
                  subtitle: "Get help and tutorials",
                  onTap: () {},
                ),
                _buildSettingsItem(
                  icon: Icons.contact_support,
                  title: "Contact Support",
                  subtitle: "Reach out for assistance",
                  onTap: () {},
                ),
                _buildInfoItem(
                  title: "App Version",
                  value: "2.1.0",
                ),
              ],
            ),
            const SizedBox(height: 20),

            
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showSignOutDialog(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Sign Out",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    "Zekink Smart Pen Assistant",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Version 2.1.0 • Made with ",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Icon(Icons.favorite, size: 12, color: Colors.red),
                      const Text(
                        " for students",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "© 2024 Zekink Technologies",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildAccountCard() {
    if (isLoading) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.purple.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(width: 16),
            Text(
              "Loading account info...",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.purple.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  parentName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Managing $childrenCount ${childrenCount == 1 ? 'child' : 'children'}",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageGrid() {
    final languages = [
      {'name': 'English', 'flag': '🇺🇸', 'selected': selectedLanguage == 'English'},
      {'name': 'Azerbaijani', 'flag': '🇦🇿', 'selected': selectedLanguage == 'Azerbaijani'},
      {'name': 'Turkish', 'flag': '🇹🇷', 'selected': selectedLanguage == 'Turkish'},
      {'name': 'Russian', 'flag': '🇷🇺', 'selected': selectedLanguage == 'Russian'},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 3,
        ),
        itemCount: languages.length,
        itemBuilder: (context, index) {
          final language = languages[index];
          final isSelected = language['selected'] as bool;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedLanguage = language['name'] as String;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.shade50 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: Colors.blue.shade100,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    language['flag'] as String,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      language['name'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.blue : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.grey.shade600, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              )
            : null,
        trailing: trailing ?? const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.grey.shade600, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              )
            : null,
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildInfoItem({required String title, required String value}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.info, color: Colors.grey.shade600, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Sign Out"),
          content: Text("Are you sure you want to sign out of $parentName?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text("Sign Out"),
            ),
          ],
        );
      },
    );
  }
}