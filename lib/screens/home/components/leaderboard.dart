import 'package:flutter/material.dart';

class Leaderboard extends StatelessWidget {
  final List<Map<String, dynamic>> leaderboardData;
  final String currentUserEmail;

  const Leaderboard({
    super.key,
    required this.leaderboardData,
    required this.currentUserEmail,
  });

  @override
  Widget build(BuildContext context) {
    // Leaderboard showing top users and highlight current user
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Leaderboard',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: leaderboardData.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final user = leaderboardData[index];
                final isCurrentUser = user['email'] == currentUserEmail;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user['avatarUrl'] ?? ''),
                    backgroundColor: Colors.green.shade100,
                  ),
                  title: Text(
                    user['name'] ?? '',
                    style: TextStyle(
                      fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                      color: isCurrentUser ? Colors.green.shade900 : Colors.black,
                    ),
                  ),
                  trailing: Text(
                    '${user['points']} Poin',
                    style: TextStyle(
                      fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                      color: isCurrentUser ? Colors.green.shade900 : Colors.black,
                    ),
                  ),
                  tileColor: isCurrentUser ? Colors.green.shade50 : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}