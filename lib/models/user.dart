import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String docID;
  final String name;
  final String email;
  String imageUrl;
  final String role;
  final String mobile;
  final String groupName;
  final String motherPhone;
  final String fatherPhone;
  final int grade;
  final String school;
  final String address;
  final DateTime? birthdate;
  final String fatherOfConfession;
  final String notes;
  final List<double> mobileFaceNetEmbeddings;

  UserModel({
    required this.uid,
    required this.docID,
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.role,
    required this.mobile,
    required this.groupName,
    required this.motherPhone,
    required this.fatherPhone,
    required this.grade,
    required this.school,
    required this.address,
    required this.birthdate,
    required this.fatherOfConfession,
    required this.notes,
    required this.mobileFaceNetEmbeddings,
  });

  // Convert Firestore data to UserModel
  factory UserModel.fromMap(Map<String, dynamic> data, String docID) {
    return UserModel(
      uid: data['uid'] ?? '',
      docID: docID,
      name: data['name'] ?? 'Guest',
      email: data['email'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      role: data['role'] ?? 'User',
      mobile: data['mobile'] ?? '',
      groupName: data['group_name'] ?? '',
      motherPhone: data['mother_number'] ?? '',
      fatherPhone: data['father_number'] ?? '',
      grade: int.tryParse(data['grade'].toString()) ?? 0,
      school: data['school_college'] ?? '',
      address: data['address'] ?? '',
      birthdate: (data['birthdate'] != null && data['birthdate'] is Timestamp)
          ? (data['birthdate'] as Timestamp).toDate()
          : DateTime(1900), // Convert Timestamp to DateTime
      fatherOfConfession: data['father_of_confession'] ?? '',
      notes: data['notes'] ?? '',
      mobileFaceNetEmbeddings: List<double>.from(data['mobileFaceNetEmbeddings'] ?? []),
    );
  }

  UserModel? copyWith({
    String? name,
    String? mobile,
    String? email,
    String? address,
    DateTime? birthdate,
    String? fatherOfConfession,
    String? school,
    int? grade,
    String? motherPhone,
    String? fatherPhone,
    String? notes,
    String? imageUrl,
  }) {
    return UserModel(
      docID: docID,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      address: address ?? this.address,
      birthdate: birthdate ?? this.birthdate,
      fatherOfConfession: fatherOfConfession ?? this.fatherOfConfession,
      school: school ?? this.school,
      grade: grade ?? this.grade,
      motherPhone: motherPhone ?? this.motherPhone,
      fatherPhone: fatherPhone ?? this.fatherPhone,
      uid: uid,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      role: role,
      groupName: groupName,
      notes: notes ?? this.notes,
      mobileFaceNetEmbeddings: mobileFaceNetEmbeddings,
    );
  }
}