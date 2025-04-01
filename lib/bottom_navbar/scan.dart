import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> users = [];
  Map<String, int> userContributions = {'update': 0, 'add': 0};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final querySnapshot = await _firestore.collection('users').get();
      setState(() {
        users = querySnapshot.docs.map((doc) {
          final data = doc.data();
          final contactInfo = data['email'] ??
              (data['contact'] != null ?
              'Contact: ${data['contact']}' :
              'No contact info');
          return {
            'id': doc.id,
            'email': contactInfo,
            'contact': data['contact'] ?? '',
            'nickname': data['nickname'] ?? 'No nickname',
            'fullName': data['fullName'] ?? '',
            'religion': data['religion'] ?? '',
            'dateJoined': data['dateJoined'] ?? Timestamp.now(),
            'active': data['active'] ?? true,
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading users: $e')),
      );
    }
  }

  Future<Map<String, int>> _fetchUserContributions(String userId) async {
    try {
      final updateQuery = await _firestore.collection('User Contribution')
          .where('UserID', isEqualTo: userId)
          .where('Type', isEqualTo: 'Updated New Place')
          .get();

      final addQuery = await _firestore.collection('User Contribution')
          .where('UserID', isEqualTo: userId)
          .where('Type', isEqualTo: 'Added New Place')
          .get();

      return {
        'update': updateQuery.size,
        'add': addQuery.size,
      };
    } catch (e) {
      return {'update': 0, 'add': 0};
    }
  }

  Future<void> _toggleUserStatus(String userId, bool currentStatus) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'active': !currentStatus,
      });
      _fetchUsers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating user: $e')),
      );
    }
  }

  Widget _buildHeaderRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 3,
            child: Text('Email/Contact', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 2,
            child: Text('Nickname', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 2,
            child: Text('Date Joined', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 2,
            child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showUserDetails(BuildContext context, Map<String, dynamic> user) async {
    final contributions = await _fetchUserContributions(user['id']);
    final dateJoined = (user['dateJoined'] as Timestamp).toDate();
    final formattedDate = DateFormat('MMM d, y').format(dateJoined);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user['fullName'].isNotEmpty ? user['fullName'] : 'User Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (user['email'].contains('@'))
                _buildDetailRow('Email:', user['email'])
              else if (user['contact'] != null && user['contact'].isNotEmpty)
                _buildDetailRow('Contact:', user['contact']),
              _buildDetailRow('Nickname:', user['nickname']),
              _buildDetailRow('Religion:', user['religion']),
              _buildDetailRow('Date Joined:', formattedDate),
              _buildDetailRow('Status:', user['active'] ? 'Active' : 'Inactive'),

              const SizedBox(height: 20),
              const Text('Contributions:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildContributionCard(
                      'Update/Edit',
                      contributions['update'] ?? 0,
                      Colors.blue
                  ),
                  _buildContributionCard(
                      'Add New',
                      contributions['add'] ?? 0,
                      Colors.green
                  ),
                ],
              ),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildContributionCard(String type, int count, Color color) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          Text(type, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text('$count', style: TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchUsers,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          _buildHeaderRow(),
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final dateJoined = (user['dateJoined'] as Timestamp).toDate();
                final formattedDate = DateFormat('MMM d, y').format(dateJoined);

                return InkWell(
                  onTap: () => _showUserDetails(context, user),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey[200]!))),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: Text(user['email'])),
                        Expanded(flex: 2, child: Text(user['nickname'])),
                        Expanded(flex: 2, child: Text(formattedDate)),
                        Expanded(
                          flex: 2,
                          child: Switch(
                            value: user['active'],
                            onChanged: (value) => _toggleUserStatus(user['id'], user['active']),
                            activeColor: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}