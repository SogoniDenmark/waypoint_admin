import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'bottom_navbar/history.dart';
import 'bottom_navbar/inventory.dart';
import 'bottom_navbar/monitoring.dart';
import 'bottom_navbar/scan.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentPageIndex = 0;
  bool _isUserContributionExpanded = false;

  final List<Widget> _pages = [
    HistoryPage(),
    UserManagementPage(),
    MonitorAdminPage(),
    AdminInventoryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade100,
        centerTitle: true,
        title: Text(
          'WAYPOINT ADMIN',
          style: GoogleFonts.bebasNeue(
            fontSize: 35,
          ),
        ),
      ),
      body: Row(
        children: [
          // Permanent drawer
          Container(
            width: 300, // Fixed width for the drawer
            color: Colors.lightGreen[50],
            child: Column(
              children: [
                const SizedBox(height: 80), // Space for app bar
                const DrawerHeader(
                  child: Center(
                    child: Image(
                      image: AssetImage('images/logo.png'),
                      width: 125,
                      height: 125,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      _buildDrawerItem(Icons.desktop_mac_outlined, 'Dashboerd Visual Report', 0),
                      _buildDrawerItem(Icons.supervised_user_circle_outlined, 'User Management', 1),
                      ExpansionTile(
                        leading: const Icon(Icons.people_alt),
                        title: const Text(
                          'User Contribution Update',
                          style: TextStyle(fontSize: 20),
                        ),
                        initiallyExpanded: false,
                        onExpansionChanged: (bool expanded) {
                          setState(() {
                            _isUserContributionExpanded = expanded;
                          });
                        },
                        children: [
                          _buildSubDrawerItem(Icons.edit_location, 'Update/Edit Religious Place', 2),
                          _buildSubDrawerItem(Icons.add_location, 'Add New Religious Place', 3),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text(
                    'Log Out',
                    style: TextStyle(fontSize: 20),
                  ),
                  onTap: () {
                    FirebaseAuth.instance.signOut();
                  },
                ),
              ],
            ),
          ),
          // Main content area
          Expanded(
            child: _pages[_currentPageIndex],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: const TextStyle(fontSize: 20),
      ),
      selected: _currentPageIndex == index,
      tileColor: _currentPageIndex == index ? Colors.green[100] : null,
      onTap: () {
        setState(() {
          _currentPageIndex = index;
        });
      },
    );
  }

  Widget _buildSubDrawerItem(IconData icon, String title, int index) {
    return Padding(
      padding: const EdgeInsets.only(left: 28.0),
      child: ListTile(
        leading: Icon(icon, size: 20),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18),
        ),
        selected: _currentPageIndex == index,
        tileColor: _currentPageIndex == index ? Colors.green[100] : null,
        onTap: () {
          setState(() {
            _currentPageIndex = index;
          });
        },
      ),
    );
  }
}