import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';

class MonitorAdminPage extends StatefulWidget {
  const MonitorAdminPage({super.key});

  @override
  State<MonitorAdminPage> createState() => _MonitorAdminPageState();
}

class _MonitorAdminPageState extends State<MonitorAdminPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
      ),
      body: Row(
        children: [
          // Left side - User Contributions (50% width)
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'User Contributions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildUserContributionsList(),
                  ),
                ],
              ),
            ),
          ),

          // Right side - Religious Places (50% width)
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Religious Places',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildReligiousPlacesList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReligiousPlacesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('Religious Places').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No religious places found'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;

            return InkWell(
              onTap: () => _showReligiousPlaceDetails(doc.id, data),
              child: Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['Name'] ?? 'No name',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (data['Address'] != null)
                        Text('Address: ${data['Address']}'),
                      if (data['Contact'] != null)
                        Text('Contact: ${data['Contact']}'),
                      if (data['Rate'] != null)
                        Text('Rating: ${data['Rate']?.toStringAsFixed(1)} ★'),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUserContributionsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('User Contribution').orderBy('Timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No contributions found'));
        }

        // Filter documents where Type is "Updated New Place"
        final filteredDocs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['Type'] == 'Updated New Place';
        }).toList();

        if (filteredDocs.isEmpty) {
          return const Center(child: Text('No updated place contributions found'));
        }

        return ListView.builder(
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final doc = filteredDocs[index];
            final data = doc.data() as Map<String, dynamic>;

            return InkWell(
              onTap: () => _showContributionDetails(doc.id, data),
              child: Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            data['Place Name'] ?? 'No name',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Chip(
                            label: Text(data['Status'] ?? 'Unknown'),
                            backgroundColor: _getStatusColor(data['Status']),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Type: ${data['Type'] ?? 'Unknown'}'),
                      Text('Submitted: ${_formatTimestamp(data['Timestamp'])}'),
                      if (data['UserID'] != null)
                        Text('User: ${data['UserID']?.substring(0, 8)}...'),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showReligiousPlaceDetails(String docId, Map<String, dynamic> data) async {
    final nameController = TextEditingController(text: data['Name']);
    final addressController = TextEditingController(text: data['Address']);
    final contactController = TextEditingController(text: data['Contact']);
    final websiteController = TextEditingController(text: data['Website'] ?? '');
    final descriptionController = TextEditingController(text: data['Description'] ?? '');
    final rateController = TextEditingController(text: data['Rate']?.toString() ?? '0.0');
    final locationController = TextEditingController(text: data['Location'] ?? '');

    List<String> hours = [];
    if (data['Hours'] != null) {
      hours = List<String>.from(data['Hours']);
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Edit Religious Place'),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: addressController,
                      decoration: const InputDecoration(labelText: 'Address'),
                    ),
                    TextFormField(
                      controller: contactController,
                      decoration: const InputDecoration(labelText: 'Contact'),
                    ),
                    TextFormField(
                      controller: websiteController,
                      decoration: const InputDecoration(labelText: 'Website'),
                    ),
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                    ),
                    TextFormField(
                      controller: locationController,
                      decoration: const InputDecoration(labelText: 'Location'),
                    ),
                    TextFormField(
                      controller: rateController,
                      decoration: const InputDecoration(labelText: 'Rating'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    const Text('Hours:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Column(
                      children: hours.map((hour) => ListTile(
                        title: Text(hour),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              hours.remove(hour);
                            });
                          },
                        ),
                      )).toList(),
                    ),
                    TextButton(
                      onPressed: () {
                        _addNewHour(setState, hours);
                      },
                      child: const Text('Add New Hours'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    await _firestore.collection('Religious Places').doc(docId).update({
                      'Name': nameController.text,
                      'Address': addressController.text,
                      'Contact': contactController.text,
                      'Website': websiteController.text,
                      'Description': descriptionController.text,
                      'Location': locationController.text,
                      'Rate': double.tryParse(rateController.text) ?? 0.0,
                      'Hours': hours,
                    });
                    if (mounted) Navigator.pop(context);
                  }
                },
                child: const Text('Save Changes'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _addNewHour(Function setState, List<String> hours) async {
    final hourController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Hours'),
        content: TextField(
          controller: hourController,
          decoration: const InputDecoration(labelText: 'Hours (e.g., "9:00 AM - 5:00 PM (MON-FRI)")'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (hourController.text.isNotEmpty) {
                setState(() {
                  hours.add(hourController.text);
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _showContributionDetails(String docId, Map<String, dynamic> data) async {
    final statusController = TextEditingController(text: data['Status'] ?? 'Pending');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(data['Place Name'] ?? 'Contribution Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Type: ${data['Type'] ?? 'Unknown'}'),
              Text('Status: ${data['Status'] ?? 'Pending'}'),
              const SizedBox(height: 16),
              Text('Place Name: ${data['Place Name'] ?? 'Not provided'}'),
              Text('Address: ${data['Address'] ?? 'Not provided'}'),
              Text('Contact: ${data['Contact'] ?? 'Not provided'}'),
              Text('Hours: ${data['Hours'] ?? 'Not specified'}'),
              if (data['Website'] != null && data['Website'].toString().isNotEmpty && data['Website'] != 'na')
                Text('Website: ${data['Website']}'),
              const SizedBox(height: 16),
              Text('Submitted: ${_formatTimestamp(data['Timestamp'])}'),
              Text('User ID: ${data['UserID'] ?? 'Unknown'}'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: data['Status'] ?? 'Pending',
                items: ['Pending', 'Approved', 'Rejected'].map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (value) {
                  statusController.text = value!;
                },
                decoration: const InputDecoration(
                  labelText: 'Change Status',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _firestore.collection('User Contribution').doc(docId).update({
                'Status': statusController.text,
              });
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'No date';
    final dateTime = timestamp.toDate();
    return DateFormat('MMM d, y h:mm a').format(dateTime);
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
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
}