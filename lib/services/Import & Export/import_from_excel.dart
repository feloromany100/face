import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';

class UploadExcelScreen extends StatefulWidget {
  const UploadExcelScreen({super.key});
  @override
  State<UploadExcelScreen> createState() => UploadExcelScreenState();
}

class UploadExcelScreenState extends State<UploadExcelScreen> {
  Future<void> pickAndUploadExcel() async {
    // Pick Excel file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      Uint8List? bytes = result.files.first.bytes; // Use bytes directly
      if (bytes != null) {
        _processExcel(bytes);
      } else {
        File file = File(result.files.first.path!); // Fallback to file path
        Uint8List fileBytes = await file.readAsBytes();
        _processExcel(fileBytes);
      }
    }

  }

  Future<void> _processExcel(Uint8List fileBytes) async {
    var excel = Excel.decodeBytes(fileBytes);
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Upload Servants
    if (excel.tables.containsKey("Servants")) {
      var sheet = excel.tables["Servants"]!;
      for (var row in sheet.rows.skip(1)) {
        Map<String, dynamic> servantData = {
          "name": row[0]?.value?.toString() ?? "",
          "gender": row[1]?.value?.toString() ?? "",
          "birthdate": _convertToTimestamp(row[2]?.value),
          "mobile": row[3]?.value?.toString() ?? "",
          "email": row[4]?.value?.toString() ?? "",
          "father_of_confession": row[5]?.value?.toString() ?? "",
          "address": row[6]?.value?.toString() ?? "",
          "notes": row[7]?.value?.toString() ?? "",
          "role": "servant"
        };
        await firestore.collection("Users").add(servantData);
      }
    }

    // Upload Students
    if (excel.tables.containsKey("Students")) {
      var sheet = excel.tables["Students"]!;
      for (var row in sheet.rows.skip(1)) {
        Map<String, dynamic> studentData = {
          "name": row[0]?.value?.toString() ?? "",
          "gender": row[1]?.value?.toString() ?? "",
          "birthdate": _convertToTimestamp(row[2]?.value),
          "mobile": row[3]?.value?.toString() ?? "",
          "email": row[4]?.value?.toString() ?? "",
          "father_of_confession": row[5]?.value?.toString() ?? "",
          "school_college": row[6]?.value?.toString() ?? "",
          "grade": row[7]?.value?.toString() ?? "",
          "address": row[8]?.value?.toString() ?? "",
          "group_name": row[9]?.value?.toString() ?? "",
          "mother_number": row[10]?.value?.toString() ?? "",
          "father_number": row[11]?.value?.toString() ?? "",
          "notes": row[12]?.value?.toString() ?? "",
          "role": "student"
        };
        await firestore.collection("Users").add(studentData);
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Excel data uploaded successfully!")),
    );
  }

  // Function to convert Excel date value to Firestore Timestamp
  Timestamp? _convertToTimestamp(dynamic value) {
    if (value is DateTime) {
      return Timestamp.fromDate(value);
    } else if (value is int) {
      // Excel stores dates as numbers, convert to DateTime
      return Timestamp.fromDate(DateTime(1899, 12, 30).add(Duration(days: value)));
    } else if (value is String) {
      try {
        return Timestamp.fromDate(DateTime.parse(value));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Excel to Firestore")),
      body: Center(
        child: ElevatedButton(
          onPressed: pickAndUploadExcel,
          child: const Text("Select Excel File"),
        ),
      ),
    );
  }
}
