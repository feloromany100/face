import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/firebase_services.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  Future<void> fetchCurrentUserData() async {
    try {
      String userId = await FirebaseService().getCurrentUserID();

      var userData = await FirebaseService().getUserData(userId);

      if (userData != null) {
        _user = UserModel.fromMap(userData, userId);
        notifyListeners();
      } else {
        print("No user data found");
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  void updateUserField(String field, dynamic value) {
    if (_user == null) return;

    _user = _user!.copyWith(
      name: field == "name" ? value : user!.name,
      mobile: field == "mobile" ? value : user!.mobile,
      email: field == "email" ? value : user!.email,
      address: field == "address" ? value : user!.address,
      birthdate: field == "birthdate" ? value : user!.birthdate,
      fatherOfConfession:
      field == "father_of_confession" ? value : user!.fatherOfConfession,
      school: field == "school_college" ? value : user!.school,
      grade: field == "grade" ? int.tryParse(value.toString()) : user!.grade,
      motherPhone: field == "mother_number" ? value : user!.motherPhone,
      fatherPhone: field == "father_number" ? value : user!.fatherPhone,
      notes: field == "notes" ? value : user!.notes,
    );
    notifyListeners();
  }

  void updateFieldImageUrl(String? newImageUrl) {
    if (_user != null) {
      _user = _user!.copyWith(imageUrl: newImageUrl);
      notifyListeners();
    }
  }

}
