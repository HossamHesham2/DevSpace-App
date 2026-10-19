import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hintText;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscureText;
  final TextAlign? textAlign;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.label,
    this.hintText,
    this.suffix,
    this.validator,
    this.textAlign,
    this.keyboardType,
    this.controller,
    this.obscureText = false,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        SizedBox(height: 20.h),
        TextFormField(
          validator: validator,
          obscureText: obscureText,
          controller: controller,
          keyboardType: keyboardType,
          autocorrect: true,
          textAlign: textAlign ?? TextAlign.start,
          decoration: InputDecoration(
            prefixIcon: prefix,
            suffixIcon: suffix,
            hintText: hintText,
          ),
        ),
      ],
    );
  }
}
