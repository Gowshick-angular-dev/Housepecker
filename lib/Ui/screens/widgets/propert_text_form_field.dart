import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../utils/Extensions/extensions.dart';
import '../../../utils/validator.dart';

enum CustomTextFieldValidator1 {
  nullCheck,
  phoneNumber,
  email,
  password,
  maxFifty,
}

class CustomTextFormField1 extends StatelessWidget {
  final String? hintText;
  final TextEditingController? controller;
  final int? minLine;
  final int? maxLine;
  final bool? isReadOnly;
  final List<TextInputFormatter>? formaters;
  final CustomTextFieldValidator1? validator;
  final Color? fillColor;
  final Function(dynamic value)? onChange;
  final Widget? prefix;
  final TextInputAction? action;
  final TextInputType? keyboard;
  final Widget? suffix;
  final bool? dense;
  const CustomTextFormField1({
    Key? key,
    this.hintText,
    this.controller,
    this.minLine,
    this.maxLine,
    this.formaters,
    this.isReadOnly,
    this.validator,
    this.fillColor,
    this.onChange,
    this.prefix,
    this.keyboard,
    this.action,
    this.suffix,
    this.dense,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      inputFormatters: formaters,
      textInputAction: action,
      keyboardAppearance: Brightness.light,
      readOnly: isReadOnly ?? false,
      style: TextStyle( color: Color(0xff929292),
          fontSize: 14),
      minLines: minLine ?? 1,
      maxLines: maxLine ?? 1,
      onChanged: onChange,
      validator: (String? value) {
        if (validator == CustomTextFieldValidator1.nullCheck) {
          return Validator.nullCheckValidator(value);
        }

        if (validator == CustomTextFieldValidator1.maxFifty) {
          if ((value ??= "").length > 50) {
            return "You can enter 50 letters max";
          } else {
            return null;
          }
        }
        if (validator == CustomTextFieldValidator1.email) {
          return Validator.validateEmail(value);
        }
        if (validator == CustomTextFieldValidator1.phoneNumber) {
          return Validator.validatePhoneNumber(value);
        }
        if (validator == CustomTextFieldValidator1.password) {
          return Validator.validatePassword(value);
        }
        return null;
      },
      keyboardType: keyboard,
      decoration: InputDecoration(
          prefix: prefix,
          isDense: dense,
          suffixIcon: suffix,
          hintText: hintText,
          hintStyle: TextStyle(
              color: Color(0xff929292),
              fontSize: 13),
          filled: true,
          fillColor: fillColor ?? Color(0xfff5f5f5),
          focusedBorder: OutlineInputBorder(
              borderSide:
              BorderSide(width: 1.5, color: context.color.tertiaryColor),
              borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
              borderSide:
              BorderSide(width: 1.5, color: Color(0xffededed)),
              borderRadius: BorderRadius.circular(10)),
          border: OutlineInputBorder(
              borderSide:
              BorderSide(width: 1.5, color: Color(0xffededed)),
              borderRadius: BorderRadius.circular(10))),
    );
  }
}
