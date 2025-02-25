import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:face_recognition/services/firebase_services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/user.dart';
import '../../../providers/user_provider.dart';
import '../../../services/Face detection/face_detector_view.dart';
import 'dart:ui' as ui;


class ProfilePage extends StatefulWidget {
  final String personID;

  const ProfilePage({super.key, required this.personID});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
   UserModel? userData;
   UserProvider? userProvider ;

   // Local state variables
   String? mobilePhone;
   String? name;
   String? email;
   String? address;
   DateTime? birthdate;
   String? fatherOfConfession;
   String? school;
   int? grade;
   String? motherPhone;
   String? fatherPhone;

  @override
  void initState() {
    super.initState();
    _initializeUserData();
    userProvider = Provider.of<UserProvider>(context, listen: false);
  }

  void _initializeUserData() async {
     userData = await _getUserData(context, widget.personID);
     setState(() {
        name = userData?.name;
       mobilePhone = userData?.mobile;
       email = userData?.email;
       address = userData?.address;
       birthdate = userData?.birthdate;
       fatherOfConfession = userData?.fatherOfConfession;
       school = userData?.school;
       grade = userData?.grade;
       motherPhone = userData?.motherPhone;
       fatherPhone = userData?.fatherPhone;
     });
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.edit, color: Colors.transparent),
                Text(
                  name!,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blueAccent),
                  onPressed: () => _showEditDialog('name', name),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              userData!.groupName,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 15),

            // Info Cards
            _buildInfoCard(Icons.phone, "Mobile Phone", mobilePhone, "mobile"),
            _buildInfoCard(Icons.email, "Email", email, "email"),
            _buildInfoCard(Icons.home, "Address", address, "address"),
            _buildInfoCard(Icons.calendar_today, "Birthdate", birthdate, "birthdate"),
            _buildInfoCard(Icons.church, "Father of Confession", fatherOfConfession, "father_of_confession"),
            _buildInfoCard(Icons.school, "School/College", school, "school_college"),
            _buildInfoCard(Icons.grade, "Grade", grade.toString(), "grade"),
            _buildInfoCard(Icons.phone_android, "Mother's phone", motherPhone, "mother_number"),
            _buildInfoCard(Icons.phone_android, "Father's phone", fatherPhone, "father_number"),

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

   Widget _buildInfoCard(IconData icon, String label, dynamic value, String fieldName) {
     String formattedValue = value is DateTime
         ? DateFormat('yyyy-MM-dd').format(value) // Format birthdate
         : value.toString(); // Convert other values to string

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
         trailing: IconButton(
           icon: const Icon(Icons.edit, color: Colors.blueAccent),
           onPressed: () => _showEditDialog(fieldName, value),
         ),
       ),
     );
   }

   void _showEditDialog(String fieldName, dynamic currentValue) {
     TextEditingController controller = TextEditingController(text: currentValue.toString());
     bool isNumberField = ["mobile", "mother_number", "father_number"].contains(fieldName);
     bool isEmailField = fieldName == "email";
     bool isNameField = fieldName == "name";
     bool isGradeField = fieldName == "grade";
     bool isBirthdateField = fieldName == "birthdate";

     if (isBirthdateField) {
       _selectDate(currentValue);
       return;
     }

     showDialog(
       context: context,
       builder: (context) {
         return AlertDialog(
           title: const Text("تعديل البيانات", textAlign: TextAlign.right),
           content: isGradeField
               ? _buildGradeDropdown(currentValue.toString())
               : TextField(
             controller: controller,
             textAlign: TextAlign.right,
             keyboardType: isNumberField ? TextInputType.number : TextInputType.text,
             decoration: InputDecoration(
               border: const OutlineInputBorder(),
               hintText: isEmailField ? "أدخل البريد الإلكتروني" : "أدخل القيمة الجديدة",
             ),
           ),
           actions: [
             TextButton(
               onPressed: () => Navigator.pop(context),
               child: const Text("إلغاء", style: TextStyle(color: Colors.red)),
             ),
             TextButton(
               onPressed: () {
                 String newValue = controller.text.trim();
                 if (isNumberField && !_validatePhoneNumber(newValue)) return;
                 if (isEmailField && !_validateEmail(newValue)) return;
                 if (isNameField && !_validateName(newValue)) return;
                 _updateFirestoreValue(widget.personID, fieldName, newValue);
                 Navigator.pop(context);
               },
               child: const Text("حفظ", style: TextStyle(color: Colors.blue)),
             ),
           ],
         );
       },
     );
   }

   Widget _buildGradeDropdown(String currentValue) {
     Map<String, int> gradeOptions = {
       "أولى إعدادي": 7,
       "ثانية إعدادي": 8,
       "ثالثة إعدادي": 9,
       "أولى ثانوي": 10,
       "ثانية ثانوي": 11,
       "ثالثة ثانوي": 12,
       "أولى جامعة": 13,
       "ثانية جامعة": 14,
       "ثالثة جامعة": 15,
       "رابعة جامعة": 16,
       "خريج": 17,
     };

     return StatefulBuilder(
       builder: (context, setState) {
         return DropdownButtonFormField<String>(
           value: currentValue,
           items: gradeOptions.entries.map((entry) {
             return DropdownMenuItem<String>(
               value: entry.value.toString(),
               child: Directionality(
                 textDirection: ui.TextDirection.rtl,
                 child: Text(entry.key),
               ),
             );
           }).toList(),
           onChanged: (newValue) {
             if (newValue != null) {
               _updateFirestoreValue(widget.personID, "grade", int.parse(newValue));
               Navigator.pop(context);
             }
           },
           decoration: const InputDecoration(border: OutlineInputBorder()),
         );
       },
     );
   }

   Future<void> _selectDate(DateTime currentDate) async {
     DateTime? picked = await showDatePicker(
       context: context,
       initialDate: currentDate,
       firstDate: DateTime(2000),
       lastDate: DateTime.now(),
     );
     if (picked != null) {
       _updateFirestoreValue(widget.personID, "birthdate", picked);
     }
   }

   bool _validatePhoneNumber(String number) {
     if (number.length != 11 || !RegExp(r'^[0-9]+$').hasMatch(number)) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text("رقم الهاتف يجب أن يكون ١١ رقماً")),
       );
       return false;
     }
     return true;
   }

   bool _validateName(String name) {
     if (name.length > 25) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text("الاسم يجب أن يكون أقل من ٢٥ حرف")),
       );
       return false;
     }
     return true;
   }

   bool _validateEmail(String email) {
     if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(email)) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text("يرجى إدخال بريد إلكتروني صالح")),
       );
       return false;
     }
     return true;
   }

   Future<void> _updateFirestoreValue(String userId, String fieldName, dynamic newValue) async {
     try {
       // Update Firestore value
       await FirebaseFirestore.instance.collection('Users').doc(userId).update({
         fieldName: newValue,
       });
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text("تم التحديث بنجاح")),
       );

       // Update local state
       setState(() {
         switch (fieldName) {
           case "name":
             name = newValue;
             break;
           case "mobile":
             mobilePhone = newValue;
             break;
           case "email":
             email = newValue;
             break;
           case "address":
             address = newValue;
             break;
           case "birthdate":
             birthdate = newValue;
             break;
           case "father_of_confession":
             fatherOfConfession = newValue;
             break;
           case "school_college":
             school = newValue;
             break;
           case "grade":
             grade = newValue;
             break;
           case "mother_number":
             motherPhone = newValue;
             break;
           case "father_number":
             fatherPhone = newValue;
             break;
         }
       });

       // Update provider state
       userProvider?.updateUserField(fieldName, newValue);

     } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text("خطأ: ${e.toString()}")),
       );
     }
   }

   Future<UserModel?> _getUserData(BuildContext context, String id) async {
     var currentUserData = userProvider?.user;

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

}


