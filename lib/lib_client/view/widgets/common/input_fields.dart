import 'package:flutter/material.dart';
import 'package:project_hub/lib_client/core/constant/color.dart';

class InputFields extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?) valid;
  final TextInputType keyboardType;
  final bool obscureText;

  const InputFields({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    required this.valid,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: valid,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: AppColor.textSecondaryColor, fontSize: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColor.borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColor.primaryColor, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

