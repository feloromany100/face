import 'package:face_recognition/services/firebase_services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/user.dart';
import '../../../providers/user_provider.dart';
import '../../../services/Face detection/face_detector_view.dart';

class ProfilePage extends StatefulWidget {
  final String personID;

  const ProfilePage({super.key, required this.personID});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
   UserModel? userData;
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Image
            InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => FaceDetectorView(personID: userData!.docID,)));
              },
              child: userData?.imageUrl != '' ?
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(userData!.imageUrl),
              ) :
              const CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage("assets/unknown.png"),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              userData!.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              userData!.groupName,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 15),

            // Info Cards
            _buildInfoCard(Icons.person, "Gender", userData?.gender),
            _buildInfoCard(Icons.calendar_today, "Birthdate", userData?.birthdate),
            _buildInfoCard(Icons.phone, "Mobile Phone", userData?.mobile),
            _buildInfoCard(Icons.email, "Email", userData?.email),
            _buildInfoCard(Icons.church, "Father of Confession", userData?.fatherOfConfession),
            _buildInfoCard(Icons.school, "School", userData?.school),
            _buildInfoCard(Icons.grade, "Grade", userData?.grade),
            _buildInfoCard(Icons.home, "Address", userData?.address),
            _buildInfoCard(Icons.phone_android, "Mother's phone", userData?.motherPhone),
            _buildInfoCard(Icons.phone_android, "Father's phone", userData?.fatherPhone),

            // Notes Section
            if (userData!.notes.isNotEmpty)
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
                      Text(userData!.notes, style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, dynamic value) {
    String formattedValue;

    if (value is DateTime) {
      formattedValue = DateFormat('yyyy-MM-dd').format(value); // Format as needed
    } else {
      formattedValue = value.toString(); // Keep string values unchanged
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.red.shade400),
        title: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(formattedValue, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

   Future<UserModel?> _getUserData(BuildContext context, String id) async {
     final userProvider = Provider.of<UserProvider>(context, listen: false);
     var currentUserData = userProvider.user;

     FirebaseService firebaseService = FirebaseService();
     var data = await firebaseService.getUserData(widget.personID);

     if (data == null) return null; // Ensure data exists before mapping
     var studentUserData = UserModel.fromMap(data, widget.personID);

     if (currentUserData != null && id == currentUserData.docID) {
       return currentUserData;
     } else {
       return studentUserData;
     }
   }

   Future<void> _loadUserData() async {
     UserModel? fetchedUser = await _getUserData(context, widget.personID);
     if (mounted) {
       setState(() {
         userData = fetchedUser;
       });
     }
   }
}


