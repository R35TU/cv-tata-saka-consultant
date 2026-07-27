import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController? controller;
  final TextInputType keyboardType;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.obscureText = false,
    this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F8), // Light gray background matching screenshot
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: const Color(0xFFCCCCCC), // Thin gray border
          width: 1.0,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        obscureText: _obscured,
        keyboardType: widget.keyboardType,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
          fontFamily: 'Inter',
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(
            color: Color(0xFFA0A0A0), // Gray hint text
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: 'Inter',
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: widget.obscureText ? 12.0 : 16.0,
          ),
          border: InputBorder.none,
          isDense: true,
          suffixIcon: widget.obscureText
              ? IconButton(
                  icon: Icon(
                    _obscured ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFFA0A0A0),
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscured = !_obscured;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }
}
