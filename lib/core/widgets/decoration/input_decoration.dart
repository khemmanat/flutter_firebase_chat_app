import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_app/core/constants/color.dart';

const textInputDecoration = InputDecoration(
  labelStyle: TextStyle(color: ThemeColor.primaryBlackColor),
  // fillColor: Colors.white,
  // filled: true,
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: ThemeColor.primaryColor, width: 2.0),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: ThemeColor.primaryColor, width: 2.0),
  ),
  errorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: ThemeColor.primaryColor, width: 2.0),
  ),
);
