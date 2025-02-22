import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final String name;
  final String gender;
  final String birthdate;
  final String mobilePhone;
  final String email;
  final String fatherOfConfession;
  final String school;
  final String grade;
  final String address;
  final String groupName;
  final String motherPhone;
  final String fatherPhone;
  final String notes;
  final String imageUrl; // Profile picture URL

  const ProfilePage({
    super.key,
    required this.name,
    required this.gender,
    required this.birthdate,
    required this.mobilePhone,
    required this.email,
    required this.fatherOfConfession,
    required this.school,
    required this.grade,
    required this.address,
    required this.groupName,
    required this.motherPhone,
    required this.fatherPhone,
    required this.notes,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Image
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(imageUrl),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              "Group: $groupName",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 15),

            // Info Cards
            _buildInfoCard(Icons.person, "Gender", gender),
            _buildInfoCard(Icons.calendar_today, "Birthdate", birthdate),
            _buildInfoCard(Icons.phone, "Mobile Phone", mobilePhone),
            _buildInfoCard(Icons.email, "Email", email),
            _buildInfoCard(Icons.church, "Father of Confession", fatherOfConfession),
            _buildInfoCard(Icons.school, "School", school),
            _buildInfoCard(Icons.grade, "Grade", grade),
            _buildInfoCard(Icons.home, "Address", address),
            _buildInfoCard(Icons.phone_android, "Mother's phone", motherPhone),
            _buildInfoCard(Icons.phone_android, "Father's phone", fatherPhone),

            // Notes Section
            if (notes.isNotEmpty)
              Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Notes",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(notes, style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.red.shade400),
        title: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(value, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
