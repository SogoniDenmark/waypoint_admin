import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';

class AdminInventoryPage extends StatefulWidget {
  const AdminInventoryPage({super.key});

  @override
  State<AdminInventoryPage> createState() => _AdminInventoryPageState();
}

class _AdminInventoryPageState extends State<AdminInventoryPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  // Controllers for the new religious place form
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final List<String> _hours = [];

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _websiteController.dispose();
    _descriptionController.dispose();
    _rateController.dispose();
    _locationController.dispose();
    super.dispose();
  }

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

          // Right side - Add New Religious Place Form (50% width)
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add New Religious Place',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _contactController,
                        decoration: const InputDecoration(
                          labelText: 'Contact',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _websiteController,
                        decoration: const InputDecoration(
                          labelText: 'Website',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location (Coordinates)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _rateController,
                        decoration: const InputDecoration(
                          labelText: 'Rating',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Opening Hours:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Column(
                        children: _hours.map((hour) => ListTile(
                          title: Text(hour),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _hours.remove(hour);
                              });
                            },
                          ),
                        )).toList(),
                      ),
                      TextButton(
                        onPressed: () => _addNewHour(),
                        child: const Text('Add New Hours'),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: _addNewReligiousPlace,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                          ),
                          child: const Text('Add Religious Place'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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

        // Filter documents where Type is "Added New Place"
        final filteredDocs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['Type'] == 'Added New Place';
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

  Future<void> _addNewHour() async {
    final hourController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Hours'),
        content: TextField(
          controller: hourController,
          decoration: const InputDecoration(
            labelText: 'Hours (e.g., "9:00 AM - 5:00 PM (MON-FRI)")',
          ),
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
                  _hours.add(hourController.text);
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

  Future<void> _addNewReligiousPlace() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await _firestore.collection('Religious Places').add({
          'Name': _nameController.text,
          'Address': _addressController.text,
          'Contact': _contactController.text,
          'Website': _websiteController.text,
          'Description': _descriptionController.text,
          'Location': _locationController.text,
          'Rate': double.tryParse(_rateController.text) ?? 0.0,
          'Hours': _hours,
        });

        // Clear the form after successful submission
        _nameController.clear();
        _addressController.clear();
        _contactController.clear();
        _websiteController.clear();
        _descriptionController.clear();
        _locationController.clear();
        _rateController.clear();
        setState(() {
          _hours.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Religious place added successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding religious place: $e')),
        );
      }
    }
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