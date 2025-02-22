import 'package:flutter/material.dart';

Widget buildTextField(
    TextEditingController controller, String hint, bool obscure) {
  return TextFormField(
    controller: controller,
    obscureText: obscure,
    decoration: InputDecoration(
      hintText: hint,
      enabledBorder:
      OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(15),
      ),
    ),
    validator: (value) => value!.isEmpty ? "$hint is required" : null,
  );
}