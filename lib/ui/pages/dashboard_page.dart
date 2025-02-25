import 'package:face_recognition/ui/widgets/my_app_bar.dart';
import 'package:flutter/material.dart';

import '../widgets/my_drawer.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const MyAppBar(title: "Dashboard"),
      drawer: const MyDrawer(), // Add your drawer here
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildDashboardCard(
              icon: Icons.group,
              label: "My Class",
              color: Colors.blueAccent,
              onTap: () {
                Navigator.pushNamed(context, '/classPage');
              },
            ),
            _buildDashboardCard(
              icon: Icons.bookmark,
              label: "Subjects",
              color: Colors.orange,
              onTap: () {},
            ),
            _buildDashboardCard(
              icon: Icons.play_circle_fill,
              label: "Lectures",
              color: Colors.redAccent,
              onTap: () {},
            ),
            _buildDashboardCard(
              icon: Icons.bar_chart,
              label: "Result",
              color: Colors.green,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.7), // Slight transparency for better visual effect
              color.withValues(alpha: 1.0),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(3, 3),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
