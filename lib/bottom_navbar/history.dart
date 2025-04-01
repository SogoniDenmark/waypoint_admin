import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(home: HistoryPage()));
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int totalUsers = 0;
  int activeUsers = 0;
  int totalContributions = 0;
  List<Map<String, dynamic>> updateContributions = [];
  List<Map<String, dynamic>> addContributions = [];
  List<Map<String, dynamic>> allUsers = [];
  Map<String, String> userIdentifiers = {};

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    // Fetch users data and cache identifiers
    final usersQuery = await _firestore.collection('users').get();
    totalUsers = usersQuery.size;

    // Initialize active status and cache identifiers
    final batch = _firestore.batch();
    for (var doc in usersQuery.docs) {
      if (!doc.data().containsKey('active')) {
        batch.update(doc.reference, {'active': true});
      }
      final userData = doc.data();
      userIdentifiers[doc.id] = userData['email'] ?? userData['contact'] ?? 'Unknown user';
    }
    await batch.commit();

    // Re-fetch users after potential update
    final updatedUsersQuery = await _firestore.collection('users').get();
    activeUsers = updatedUsersQuery.docs.where((doc) => doc['active'] == true).length;
    allUsers = updatedUsersQuery.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'email': data['email'] ?? 'Unknown',
        'contact': data['contact'] ?? 'No contact',
        'fullName': data['fullName'] ?? 'Unknown',
        'nickname': data['nickname'] ?? '',
        'religion': data['religion'] ?? '',
        'active': data['active'] ?? true,
      };
    }).toList();

    // Fetch contributions
    final contributionsQuery = await _firestore.collection('User Contribution').get();
    totalContributions = contributionsQuery.size;

    // Process contributions
    updateContributions = [];
    addContributions = [];

    for (var doc in contributionsQuery.docs) {
      final data = doc.data();
      final contribution = {
        'id': doc.id,
        'Address': data['Address'] ?? 'Not provided',
        'Contact': data['Contact'] ?? 'Not provided',
        'Hours': data['Hours'] ?? 'Not specified',
        'Place Name': data['Place Name'] ?? 'Unknown Place',
        'Status': data['Status'] ?? 'Unknown',
        'Timestamp': data['Timestamp'],
        'Type': data['Type'] ?? 'Unknown',
        'UserID': data['UserID'] ?? 'Unknown',
        'Website': data['Website'] ?? '',
      };

      if (contribution['Type'] == 'Updated New Place') {
        updateContributions.add(contribution);
      } else if (contribution['Type'] == 'Added New Place') {
        addContributions.add(contribution);
      }
    }

    // Sort by timestamp (newest first)
    updateContributions.sort((a, b) => (b['Timestamp'] as Timestamp).compareTo(a['Timestamp'] as Timestamp));
    addContributions.sort((a, b) => (b['Timestamp'] as Timestamp).compareTo(a['Timestamp'] as Timestamp));

    if (mounted) {
      setState(() {});
    }
  }

  void _showContributionDetails(Map<String, dynamic> contribution) {
    final timestamp = contribution['Timestamp'] as Timestamp?;
    final dateTime = timestamp?.toDate();
    final formattedDate = dateTime != null
        ? DateFormat('MMM d, y h:mm a').format(dateTime)
        : 'No date';

    final userData = allUsers.firstWhere(
          (user) => user['id'] == contribution['UserID'],
      orElse: () => {'email': 'Unknown', 'contact': 'Unknown'},
    );
    final userIdentifier = userData['email'] ?? userData['contact'] ?? 'Unknown user';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(contribution['Place Name']),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Submitted by: $userIdentifier'),
              const SizedBox(height: 8),
              Text('Type: ${contribution['Type']}'),
              Text('Status: ${contribution['Status']}'),
              const SizedBox(height: 12),
              Text('Address: ${contribution['Address']}'),
              Text('Contact: ${contribution['Contact']}'),
              Text('Hours: ${contribution['Hours']}'),
              const SizedBox(height: 12),
              Text('Submitted: $formattedDate'),
              if (contribution['Website'] != null && contribution['Website'].isNotEmpty)
                Text('Website: ${contribution['Website']}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  Icon(icon, color: color),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContributionList({
    required String title,
    required List<Map<String, dynamic>> contributions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (contributions.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text('No contributions found'),
          )
        else
          ...contributions.map((contribution) => _buildContributionItem(contribution)).toList(),
      ],
    );
  }

  Widget _buildContributionItem(Map<String, dynamic> contribution) {
    final userData = allUsers.firstWhere(
          (user) => user['id'] == contribution['UserID'],
      orElse: () => {'email': 'Unknown', 'contact': 'Unknown'},
    );
    final userIdentifier = userData['email'] ?? userData['contact'] ?? 'Unknown user';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(userIdentifier),
        subtitle: Text(contribution['Place Name']),
        trailing: ElevatedButton(
          onPressed: () => _showContributionDetails(contribution),
          child: const Text('Review'),
        ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(user['fullName']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user['email'] ?? 'No email'),
            if (user['contact'] != null && user['contact'] != 'No contact')
              Text(user['contact']),
          ],
        ),
        trailing: Switch(
          value: user['active'],
          onChanged: (value) => _toggleUserActiveStatus(user['id'], user['active']),
          activeColor: Colors.green,
        ),
        leading: CircleAvatar(
          backgroundColor: user['active'] ? Colors.green : Colors.grey,
          child: Text(
            user['fullName'].toString().substring(0, 1),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Future<void> _toggleUserActiveStatus(String userId, bool currentStatus) async {
    await _firestore.collection('users').doc(userId).update({
      'active': !currentStatus,
    });
    _fetchDashboardData();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange[200]!;
      case 'approved':
        return Colors.green[200]!;
      case 'rejected':
        return Colors.red[200]!;
      default:
        return Colors.grey[200]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text('Dashboard'),
          elevation: 0,
          backgroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchDashboardData,
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.dashboard)),
              Tab(icon: Icon(Icons.people)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Dashboard Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Stats Cards Row
                  Row(
                    children: [
                      _buildStatCard(
                        title: 'Total Users',
                        value: totalUsers.toString(),
                        icon: Icons.people,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 16),
                      _buildStatCard(
                        title: 'Active Users',
                        value: activeUsers.toString(),
                        icon: Icons.verified_user,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 16),
                      _buildStatCard(
                        title: 'Contributions',
                        value: totalContributions.toString(),
                        icon: Icons.upload_file,
                        color: Colors.purple,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildContributionList(
                    title: 'Update/Edit Religious Place',
                    contributions: updateContributions,
                  ),
                  const SizedBox(height: 24),
                  _buildContributionList(
                    title: 'Add New Religious Place',
                    contributions: addContributions,
                  ),
                ],
              ),
            ),
            // Users Management Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'User Management (${activeUsers}/${totalUsers} active)',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...allUsers.map(_buildUserCard).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}