import 'package:flutter/material.dart';

Widget buildGridItem(BuildContext context, String title, IconData icon, Widget? page) {
  return GestureDetector(
    onTap: () {
      if (page != null) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      }
    },
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50, color: Colors.red),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  );
}
