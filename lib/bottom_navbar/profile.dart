import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = '';
  String email = '';
  bool isLoading = true;
  bool isEditing = false;
  final TextEditingController _usernameController = TextEditingController();
  late Stream<QuerySnapshot> _messagesStream;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    _messagesStream = FirebaseFirestore.instance
        .collection('user_messages')
        .where('recipientId', isEqualTo: userId)
        .snapshots();
  }

  Future<void> _loadUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        email = user.email ?? 'No Email';

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            username = userDoc['username'] ?? 'No Username';
            _usernameController.text = username;
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateUsername() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'username': _usernameController.text});

        setState(() {
          username = _usernameController.text;
          isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username updated successfully!')),
        );
      }
    } catch (e) {
      print('Error updating username: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update username.')),
      );
    }
  }

  Future<void> _markAsRead(String messageId) async {
    await FirebaseFirestore.instance
        .collection('user_messages')
        .doc(messageId)
        .update({'read': true});
  }

  void _showMessageDialog(Map<String, dynamic> message) {
    final messageTime = (message['timestamp'] as Timestamp).toDate();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Message from ${message['senderName'] ?? 'Admin'}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message['message'],
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                DateFormat('MMM dd, yyyy - hh:mm a').format(messageTime),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.green[200],
          ),
        ),
        centerTitle: true,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      backgroundColor: Colors.green[50],
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              // Profile Section
              Container(
                height: constraints.maxHeight * 0.4,
                padding: const EdgeInsets.all(20),
                child: Card(
                  elevation: 5,
                  shadowColor: Colors.green.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.person,
                          size: 80,
                          color: Colors.green,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isEditing ? '' : 'Username: $username',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.green),
                              onPressed: () {
                                if (!isEditing) {
                                  setState(() {
                                    isEditing = true;
                                    _usernameController.text = username;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                        if (isEditing) ...[
                          const SizedBox(height: 10),
                          TextField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'Edit Username',
                              labelStyle: const TextStyle(color: Colors.green),
                              hintText: 'Enter your new username',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                  color: Colors.green,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _updateUsername,
                            child: const Text('Save Changes'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        Text(
                          'Email: $email',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Messages Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Messages',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: StreamBuilder<QuerySnapshot>(
                              stream: _messagesStream,
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Center(child: Text('Error loading messages'));
                                }
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator());
                                }

                                final messages = snapshot.data!.docs;
                                messages.sort((a, b) {
                                  final aTime = (a['timestamp'] as Timestamp).toDate();
                                  final bTime = (b['timestamp'] as Timestamp).toDate();
                                  return bTime.compareTo(aTime);
                                });

                                if (messages.isEmpty) {
                                  return Center(
                                    child: Text(
                                      'No messages yet',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  );
                                }

                                return ListView.builder(
                                  itemCount: messages.length,
                                  itemBuilder: (context, index) {
                                    final message = messages[index];
                                    final isRead = message['read'] == true;
                                    final messageData = message.data() as Map<String, dynamic>;

                                    return Card(
                                      margin: const EdgeInsets.symmetric(vertical: 4),
                                      color: isRead ? Colors.white : Colors.blue[50],
                                      child: ListTile(
                                        leading: Icon(
                                          Icons.email,
                                          color: isRead ? Colors.grey : Colors.blue,
                                        ),
                                        title: Text(
                                          'From: ${messageData['senderName'] ?? 'Admin'}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              messageData['message'],
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              DateFormat('MMM dd, HH:mm').format(
                                                  (messageData['timestamp'] as Timestamp).toDate()),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                        onTap: () {
                                          if (!isRead) {
                                            _markAsRead(message.id);
                                          }
                                          _showMessageDialog(messageData);
                                        },
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}