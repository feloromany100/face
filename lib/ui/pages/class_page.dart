import 'package:face_recognition/services/firebase_services.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/Face detection/face_detector_view.dart';
import '../../ui/pages/Drawer/profile_page.dart';
import '../widgets/my_app_bar.dart';

class ClassPage extends StatefulWidget {
  const ClassPage({super.key});

  @override
  State<ClassPage> createState() => ClassPageState();
}

class ClassPageState extends State<ClassPage> {
  FirebaseService firebaseService = FirebaseService();
  bool isLoading = true;

  String? role;
  String? imageUrl;
  List<String> classIds = [];
  List<String> servantIds = [];
  List<String> studentIds = [];

  @override
  void initState() {
    super.initState();
    _initializeAllData();
  }

  Future<void> _initializeAllData() async {
    try {
      role = await firebaseService.getCurrentUserRole();
      classIds = await firebaseService.getCurrentUserClasses();
      servantIds = await firebaseService.getPersonIds("servant_ids", classIds);
      studentIds = await firebaseService.getPersonIds("student_ids", classIds);
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(title: "My class"), // Arabic title
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show only one loader
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildSectionTitle("الخدام"), // Arabic title
              _buildList(context, servantIds, isEditable: false),
              const SizedBox(height: 20),
              _buildSectionTitle("المخدومين"), // Arabic title
              _buildList(context, studentIds, isEditable: role == "servant"),
            ],
          ),
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
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'Tajawal', // Arabic-friendly font
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<String> personIds, {required bool isEditable}) {
    if (personIds.isEmpty) {
      return const Center(child: Text("لا توجد بيانات", style: TextStyle(fontSize: 18)));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: firebaseService.firestore
          .collection('Users')
          .where(FieldPath.documentId, whereIn: personIds)
          .orderBy("name")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("لا توجد بيانات", style: TextStyle(fontSize: 18)));
        }

        var docs = snapshot.data!.docs;

        return Column(
          children: docs.asMap().entries.map((entry) {
            int index = entry.key + 1; // Start from 1
            var doc = entry.value;
            var data = doc.data() as Map<String, dynamic>;
            bool hasImage = data['imageUrl'] != null && data['imageUrl'] != '';
            String imageUrl = hasImage ? data['imageUrl'] : '';

            return Row(
              children: [
                _buildFaceIcon(imageUrl, data['role'], doc.id),
                Expanded(
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text(
                        "${_convertToArabicNumbers(index)}. ${data['name'] ?? ''}",
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      onTap: () {
                        if (data["uid"] != null && data["uid"] == FirebaseService().firebaseAuth.currentUser!.uid) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ProfilePage(personID: doc.id)),
                          );
                        } else if (data["role"] == "student") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ProfilePage(personID: doc.id)),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        );
      },
    );
  }
  // Function to convert numbers to Arabic numerals
  String _convertToArabicNumbers(int number) {
    const arabicNumbers = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((digit) => arabicNumbers[int.parse(digit)]).join('');
  }

  Widget _buildFaceIcon(String? imageUrl, String personRole, personId) {
    if(imageUrl != '' && imageUrl != null) {
      return InkWell(
        onTap: () {
          if(personRole == 'student') {
            Navigator.push(context, MaterialPageRoute(builder: (context) => FaceDetectorView(personID: personId,)));
          }
        },
        child: CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(imageUrl),
        ),
      );
    }
    if(personRole == 'student') {
      return IconButton(
        icon: const Icon(Icons.face),
        color: Colors.grey.shade700,
        iconSize: 50,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => FaceDetectorView(personID: personId,)));
        },
      );
    }
    return Container();
  }

}
