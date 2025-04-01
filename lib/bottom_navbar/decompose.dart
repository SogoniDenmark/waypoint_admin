import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminAnalyticsDashboard extends StatelessWidget {
  const AdminAnalyticsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Analytics Dashboard'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildStatsRow(context),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Recent Decomposed Plants'),
            _buildDecomposedPlantsList(context),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Plant Health Reports'),
            _buildHealthReportsList(context),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'User Activity'),
            _buildUserActivityStats(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analytics Dashboard',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Overview of system health and user activity',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('decomposed_plants').snapshots(),
      builder: (context, snapshot) {
        final decomposedCount = snapshot.hasData ? snapshot.data!.docs.length : 0;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('inventories').snapshots(),
          builder: (context, inventorySnapshot) {
            int totalPlants = 0;
            int unhealthyPlants = 0;

            if (inventorySnapshot.hasData) {
              for (var inventory in inventorySnapshot.data!.docs) {
                final items = inventory['items'] as List<dynamic>;
                totalPlants += items.length;
                unhealthyPlants += items.where((item) => item['status'] == 'unhealthy').length;
              }
            }

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, userSnapshot) {
                final userCount = userSnapshot.hasData ? userSnapshot.data!.docs.length : 0;

                return Row(
                  children: [
                    _StatCard(
                      title: 'Total Plants',
                      value: totalPlants.toString(),
                      icon: Icons.eco,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      title: 'Unhealthy',
                      value: '$unhealthyPlants (${totalPlants > 0 ? ((unhealthyPlants / totalPlants) * 100).toStringAsFixed(1) : 0}%)',
                      icon: Icons.warning,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      title: 'Decomposed',
                      value: decomposedCount.toString(),
                      icon: Icons.delete,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      title: 'Users',
                      value: userCount.toString(),
                      icon: Icons.people,
                      color: Colors.blue,
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildDecomposedPlantsList(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('decomposed_plants')
                  .orderBy('decomposedDate', descending: true)
                  .limit(5)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text("No decomposed plants found."),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final plant = doc.data() as Map<String, dynamic>;
                    final date = DateTime.parse(plant['decomposedDate']);
                    final formattedDate = DateFormat('MMM dd, yyyy').format(date);

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: plant['imageUrl1'] != null && plant['imageUrl1'].isNotEmpty
                          ? CircleAvatar(
                        backgroundImage: NetworkImage(plant['imageUrl1']),
                        radius: 20,
                      )
                          : const CircleAvatar(
                        child: Icon(Icons.eco),
                        radius: 20,
                      ),
                      title: Text(
                        plant['plantName'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${plant['decompositionReason']} • $formattedDate',
                      ),
                      trailing: Chip(
                        label: Text(plant['plantType']),
                        backgroundColor: Colors.grey[200],
                      ),
                      onTap: () {
                        _showDecomposedPlantDetails(context, plant);
                      },
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FullDecomposedPlantsPage(),
                  ),
                );
              },
              child: const Text('View All Decomposed Plants'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthReportsList(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('remedy_reports')
                  .orderBy('date', descending: true)
                  .limit(5)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text("No health reports found."),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final report = doc.data() as Map<String, dynamic>;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        backgroundColor: Colors.orange,
                        child: Icon(Icons.health_and_safety, color: Colors.white),
                      ),
                      title: Text(
                        report['label'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '% • ${report['date']}',
                      ),
                      trailing: Chip(
                        label: Text('${report['confidence'].toStringAsFixed(0)}%'),
                        backgroundColor: _getConfidenceColor(report['confidence']),
                        labelStyle: const TextStyle(color: Colors.white),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserActivityStats(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .orderBy('lastUpdated', descending: true)
                  .limit(5)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text("No users found."),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final user = doc.data() as Map<String, dynamic>;
                    final lastUpdated = (user['lastUpdated'] as Timestamp).toDate();
                    final formattedDate = DateFormat('MMM dd, yyyy').format(lastUpdated);

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      title: Text(
                        user['username'] ?? 'No username',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${user['email']} • $formattedDate',
                      ),
                      trailing: Chip(
                        label: Text(user['role'] ?? 'User'),
                        backgroundColor: user['role'] == 'Staff'
                            ? Colors.blue[100]
                            : Colors.grey[200],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence > 90) return Colors.red;
    if (confidence > 70) return Colors.orange;
    return Colors.green;
  }

  void _showDecomposedPlantDetails(BuildContext context, Map<String, dynamic> plant) {
    final date = DateTime.parse(plant['decomposedDate']);
    final formattedDate = DateFormat('MMMM dd, yyyy').format(date);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(plant['plantName']),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (plant['imageUrl1'].isNotEmpty)
                Image.network(
                  plant['imageUrl1'],
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 16),
              _buildDetailRow('Inventory', plant['inventoryName']),
              _buildDetailRow('Plant Type', plant['plantType']),
              _buildDetailRow('Plant Part', plant['plantPart']),
              _buildDetailRow('Decomposed By', plant['decomposedBy']),
              _buildDetailRow('Date', formattedDate),
              _buildDetailRow('Reason', plant['decompositionReason']),
              _buildDetailRow('Purpose', plant['decompositionPurpose']),
              if (plant['description'].isNotEmpty)
                _buildDetailRow('Description', plant['description']),
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
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class FullDecomposedPlantsPage extends StatelessWidget {
  const FullDecomposedPlantsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Decomposed Plants'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('decomposed_plants')
            .orderBy('decomposedDate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No decomposed plants found."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final plant = doc.data() as Map<String, dynamic>;
              final date = DateTime.parse(plant['decomposedDate']);
              final formattedDate = DateFormat('MMM dd, yyyy').format(date);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: plant['imageUrl1'] != null && plant['imageUrl1'].isNotEmpty
                      ? CircleAvatar(
                    backgroundImage: NetworkImage(plant['imageUrl1']),
                    radius: 24,
                  )
                      : const CircleAvatar(
                    child: Icon(Icons.eco),
                    radius: 24,
                  ),
                  title: Text(
                    plant['plantName'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${plant['decompositionReason']} • $formattedDate'),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        children: [
                          Chip(
                            label: Text(plant['plantType']),
                            backgroundColor: Colors.grey[200],
                            labelStyle: const TextStyle(fontSize: 12),
                          ),
                          Chip(
                            label: Text(plant['inventoryName']),
                            backgroundColor: Colors.blue[100],
                            labelStyle: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  onTap: () {
                    _showDecomposedPlantDetails(context, plant);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showDecomposedPlantDetails(BuildContext context, Map<String, dynamic> plant) {
    final date = DateTime.parse(plant['decomposedDate']);
    final formattedDate = DateFormat('MMMM dd, yyyy').format(date);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(plant['plantName']),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (plant['imageUrl1'].isNotEmpty)
                Image.network(
                  plant['imageUrl1'],
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 16),
              _buildDetailRow('Inventory', plant['inventoryName']),
              _buildDetailRow('Plant Type', plant['plantType']),
              _buildDetailRow('Plant Part', plant['plantPart']),
              _buildDetailRow('Decomposed By', plant['decomposedBy']),
              _buildDetailRow('Date', formattedDate),
              _buildDetailRow('Reason', plant['decompositionReason']),
              _buildDetailRow('Purpose', plant['decompositionPurpose']),
              if (plant['description'].isNotEmpty)
                _buildDetailRow('Description', plant['description']),
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
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}