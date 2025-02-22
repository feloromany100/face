import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key, required this.title});
  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(fontSize: 22, color: Colors.black, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(
        color: Colors.black, //change color on your need
      ),
    );
  }
}
