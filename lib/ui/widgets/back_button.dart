import 'package:flutter/material.dart';

Widget backButton(BuildContext context) {
  return Positioned(
    top: 40,
    left: 8,
    child: SizedBox(
      height: 50.0,
      width: 50.0,
      child: FloatingActionButton(
        heroTag: Object(),
        onPressed: () => Navigator.of(context).pop(),
        backgroundColor: Colors.black54,
        child: const Icon(
          Icons.arrow_back_ios_outlined,
          size: 20,
        ),
      ),
    ),
  );
}
