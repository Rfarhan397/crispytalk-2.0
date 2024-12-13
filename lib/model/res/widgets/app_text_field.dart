import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../constant.dart';
import '../../../provider/theme/theme_provider.dart';
import '../constant/app_colors.dart';

class AppTextField extends StatelessWidget {
  final String hintText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted,onChanged;
  final FocusNode? focusNode;
  final bool borderSides;
  final double? radius;
  final Color? focusBdColor,focusColor,fillColor,hintColor,bdColor;
  final Color? enableBorderColor;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool hasPrefixIcon;
final bool obscureText;
  const AppTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.validator,
    this.borderSides = false,
    this.onFieldSubmitted,
    this.focusNode,
    this.radius,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.suffixIcon,
    this.prefixIcon, this.focusBdColor,
    this.onChanged,
    this.focusColor,
    this.fillColor,
    this.hintColor,
    this.bdColor,
     this.enableBorderColor,
    this.hasPrefixIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeLanguageProvider>(context).isDarkMode;
    return TextFormField(
      maxLines: 1,
      style: const TextStyle(
        color: AppColors.appBlackColor,
      ),
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      controller: controller,
      validator: validator,
      focusNode: focusNode,
      onFieldSubmitted: onFieldSubmitted,
      cursorColor: Colors.black,
      obscureText: obscureText,
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon:hasPrefixIcon? prefixIcon: null,
        suffixIcon:suffixIcon,
        hintText: hintText,
        filled: true,
        hintMaxLines: 1,

        border: OutlineInputBorder(
          borderSide:  BorderSide(color: bdColor ?? Colors.transparent, width: 2),
          borderRadius: BorderRadius.circular(radius ?? 20),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius ?? 20),
          borderSide: const BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius ?? 20),
          borderSide:  BorderSide(color:focusBdColor ?? primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius ?? 20),
          borderSide:  BorderSide(color: isDarkMode ? Colors.white : Color(0xffD1DBE8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius ?? 20),
          borderSide:  BorderSide(color: enableBorderColor ?? Colors.transparent),
        ),
        fillColor:  fillColor ?? Color(0xffD9D9D9) ,
        focusColor: focusColor ?? Color(0xffD9D9D9),
        hintStyle:  TextStyle(fontSize: 14.0, color: hintColor ??Colors.grey),
      ),
    );
  }
}

class NumberTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final int newTextLength = newValue.text.length;
    int selectionIndex = newValue.selection.end;
    int usedSubstringIndex = 0;
    final StringBuffer newText = StringBuffer();
    if (newTextLength >= 1) {
      newText.write('+');
      if (newValue.selection.end >= 1) selectionIndex++;
    }
    if (newTextLength >= 3) {
      newText.write('${newValue.text.substring(0, usedSubstringIndex = 2)} ');
      if (newValue.selection.end >= 2) selectionIndex += 1;
    }
    // Dump the rest.
    if (newTextLength >= usedSubstringIndex) {
      newText.write(newValue.text.substring(usedSubstringIndex));
    }
    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
