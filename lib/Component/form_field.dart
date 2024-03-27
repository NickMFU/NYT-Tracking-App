import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DefaultFormField extends StatelessWidget {
   
  final String hint;
  final bool isPassword;
  final TextInputType? textInputType;
  final TextEditingController controller;
  final IconData? suffixIcon;
  final Function? suffixFunction;
  final Function? function;
  final Widget? prefixWidget;
  final String validText;
  final bool isDropdown;
  final List<String>? dropdownItems;

  DefaultFormField({
    
    required this.hint,
    required this.controller,
    this.textInputType,
    this.isPassword = false,
    this.suffixIcon,
    this.suffixFunction,
    this.function,
    this.prefixWidget,
    required this.validText,
    this.isDropdown = false,
    this.dropdownItems,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isDropdown
        ? DropdownButtonFormField<String>(
            value: controller.text,
            items: dropdownItems!.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: (value) {
              // Instead of directly modifying controller.text, use the provided controller
              controller.text = value!;
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade100,
              hintText: hint,
              hintStyle: GoogleFonts.roboto(
                fontSize: 15.0,
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Color.fromARGB(255, 28, 0, 154), width: 2.0), // Set blue border here
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: prefixWidget,
              suffixIcon: IconButton(
                onPressed: () {
                  suffixFunction!();
                },
                icon: Icon(suffixIcon),
                color: Colors.grey.shade400,
              ),
            ),
          )
        : TextFormField(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade100,
              hintText: hint,
              hintStyle: GoogleFonts.roboto(
                fontSize: 15.0,
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.blue, width: 2.0), // Set blue border here
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: prefixWidget,
              suffixIcon: IconButton(
                onPressed: () {
                  suffixFunction!();
                },
                icon: Icon(suffixIcon),
                color: Colors.grey.shade400,
              ),
            ),
            style: GoogleFonts.roboto(
              color: Colors.black,
              fontSize: 15,
            ),
            controller: controller,
            keyboardType: textInputType,
            obscureText: isPassword,
            validator: (value) {
              if (value!.isEmpty) {
                return validText;
              } else {
                return null;
              }
            },
          );
  }
}
