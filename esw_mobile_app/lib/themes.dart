import 'package:flutter/material.dart';

InputDecoration getInputDecoration(String hintText) {
  return InputDecoration(
    hintText: hintText,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
    ),
  );
}
