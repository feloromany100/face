import 'package:flutter/material.dart';
import '../../services/Face detection/face_detector_view.dart';
import '../../ui/pages/Drawer/profile_page.dart';
import '../widgets/my_app_bar.dart';

class ClassPage extends StatelessWidget {
  final List<String> servants = ["John Doe", "Mary Smith"];
  final List<String> students = ["Alice Brown", "Bob Johnson", "Charlie Davis"];

  ClassPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(title: "My Class"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Servants"),
            _buildList(context, servants),
            const SizedBox(height: 20),
            _buildSectionTitle("Students"),
            _buildList(context, students),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.red.shade400,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<String> names) {
    return Column(
      children: names.map((name) {
        return Row(
          children: [
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    name,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfilePage(
                          name: "John Doe",
                          gender: "Male",
                          birthdate: "01-01-2000",
                          mobilePhone: "+201234567890",
                          email: "johndoe@example.com",
                          fatherOfConfession: "Fr. Mark",
                          school: "Saint Mary School",
                          grade: "10",
                          address: "123 Church Street, Cairo",
                          groupName: "Youth Group",
                          motherPhone: "+201234567891",
                          fatherPhone: "+201234567892",
                          notes: "Very active in church activities.",
                          imageUrl: "https://example.com/profile.jpg", // Replace with actual image URL
                        ),
                      ),
                    );

                  },
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.face),
              color: Colors.grey.shade700,
              iconSize: 50,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FaceDetectorView()));
              },
            ),
          ],
        );
      }).toList(),
    );
  }
}
