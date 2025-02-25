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

  void updateImageUrl(String? newImageUrl) {
    if (_user != null) {
      _user = UserModel(
        uid: _user?.uid ?? '',
        docID: _user?.docID ?? '',
        name: _user?.name ?? '',
        email: _user?.email ?? '',
        imageUrl: newImageUrl ?? '', // ✅ Updated imageUrl
        role: _user?.role ?? '',
        mobile: _user?.mobile ?? '',
        address: _user?.address ?? '',
        gender: _user?.gender ?? '',
        birthdate: _user?.birthdate ?? DateTime(1900),
        fatherOfConfession: _user?.fatherOfConfession ?? '',
        notes: _user?.notes ?? '',
        mobileFaceNetEmbeddings: _user?.mobileFaceNetEmbeddings ?? [],
        groupName: _user?.groupName ?? '',
        motherPhone: _user?.motherPhone ?? '',
        fatherPhone: _user?.fatherPhone ?? '',
        grade: _user?.grade ?? 0,
        school: _user?.school ?? '',
      );
      notifyListeners();
    }
  }
}
