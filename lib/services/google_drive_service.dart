import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;

class GoogleDriveUploader {
  static const String folderId = "1sgnE_byEpKYeiLfKU44UwAv4YiufBnYB"; // Replace with your Drive folder ID

  static Future<drive.DriveApi?> _getDriveApi() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn(
        scopes: [drive.DriveApi.driveFileScope],
      ).signIn();

      if (googleUser == null) return null; // User canceled sign-in

      final googleAuth = await googleUser.authentication;
      final authClient = auth.authenticatedClient(
        http.Client(),
        auth.AccessCredentials(
          auth.AccessToken("Bearer", googleAuth.accessToken!, DateTime.now().toUtc()),
          null,
          [drive.DriveApi.driveFileScope],
        ),
      );

      return drive.DriveApi(authClient);
    } catch (e) {
      print("Error initializing Google Drive API: $e");
      return null;
    }
  }

  static Future<String?> uploadToGoogleDrive(Uint8List faceBytes) async {
    try {
      final driveApi = await _getDriveApi();
      if (driveApi == null) return null;

      File file = await _saveTempFile(faceBytes);

      final drive.File driveFile = drive.File()
        ..name = "face_${DateTime.now().millisecondsSinceEpoch}.jpg"
        ..parents = [folderId];

      final uploadedFile = await driveApi.files.create(
        driveFile,
        uploadMedia: drive.Media(file.openRead(), file.lengthSync()),
      );

      return "https://drive.google.com/uc?export=view&id=${uploadedFile.id}";
    } catch (e) {
      print("Error uploading to Google Drive: $e");
      return null;
    }
  }

  static Future<File> _saveTempFile(Uint8List bytes) async {
    final tempDir = await getTemporaryDirectory();
    File file = File("${tempDir.path}/face.jpg");
    await file.writeAsBytes(bytes);
    return file;
  }
}
