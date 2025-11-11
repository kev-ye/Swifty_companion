import 'package:flutter/material.dart';

// 用户详情页面
class UserDetailView extends StatelessWidget {
  final Map<String, dynamic> userData;

  const UserDetailView({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    final cursusUsers = userData['cursus_users'] as List? ?? [];
    final mainCursus = cursusUsers.isNotEmpty ? cursusUsers.last : null;
    final skills = mainCursus?['skills'] as List? ?? [];
    final projectsUsers = userData['projects_users'] as List? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(userData['login'] ?? 'User Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: userData['image']?['versions']?['large'] != null
                    ? NetworkImage(userData['image']['versions']['large'] as String)
                    : null,
                child: userData['image']?['versions']?['large'] == null
                    ? const Icon(Icons.person, size: 60)
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoCard('Basic Information', [
              _buildInfoRow('Login', userData['login']?.toString()),
              _buildInfoRow('Email', userData['email']?.toString()),
              _buildInfoRow('Mobile', userData['phone']?.toString()),
              _buildInfoRow('Wallet', '${userData['wallet'] ?? 0} ₳'),
              _buildInfoRow('Level', mainCursus?['level']?.toStringAsFixed(2) ?? 'N/A'),
              _buildInfoRow('Location', userData['location']?.toString() ?? 'Unavailable'),
              _buildInfoRow('Evaluation Points', '${userData['correction_point'] ?? 0}'),
            ]),
            const SizedBox(height: 16),
            if (skills.isNotEmpty) ...[
              const Text(
                'Skills',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: skills.map<Widget>((skill) {
                      final level = (skill['level'] ?? 0.0) as double;
                      final percentage = (level % 1) * 100;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(skill['name']?.toString() ?? ''),
                                Text('Lv ${level.toStringAsFixed(2)} (${percentage.toStringAsFixed(0)}%)'),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: Colors.grey[300],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (projectsUsers.isNotEmpty) ...[
              const Text(
                'Projects',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: projectsUsers.map<Widget>((project) {
                      final status = project['status']?.toString() ?? '';
                      final validated = project['validated?'] as bool?;
                      final finalMark = project['final_mark'] as int?;

                      Color statusColor = Colors.grey;
                      if (validated == true) {
                        statusColor = Colors.green;
                      } else if (status == 'finished' && validated == false) {
                        statusColor = Colors.red;
                      }

                      return ListTile(
                        leading: Icon(
                          validated == true ? Icons.check_circle : Icons.cancel,
                          color: statusColor,
                        ),
                        title: Text(project['project']?['name']?.toString() ?? 'Unknown'),
                        subtitle: Text('Status: $status'),
                        trailing: finalMark != null
                            ? Text(
                                '$finalMark/100',
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value ?? 'N/A'),
          ),
        ],
      ),
    );
  }
}

