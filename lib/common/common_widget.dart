import 'package:flutter/material.dart';

mixin Common_widget {
  static ClipRRect buildButton(
      String text, VoidCallback onPressed, Color bcolor, Color fcolor) {
    return ClipRRect(
      //     borderRadius: BorderRadius.circular(1.0),
      child: SizedBox(
        width: 180,
        height: 55.0,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: bcolor,
            foregroundColor: fcolor,
          ),
          child: Text(text),
        ),
      ),
    );
  }

  static TextFormField buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    IconData? suffixIcon,
    bool? obscureText
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText ?? false,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        prefixIcon: Icon(prefixIcon),
        suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
      ),
    );
  }
}