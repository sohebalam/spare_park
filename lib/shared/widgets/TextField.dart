import 'package:flutter/material.dart';

TextField buildTextField() {
  return TextField(
    decoration: InputDecoration(
      hintText: 'Search for a destination',
      hintStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      suffixIcon: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Icon(
          Icons.search,
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}
