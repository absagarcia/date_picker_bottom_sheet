import 'dart:developer';

import 'package:date_picker_bottom_sheet/date_picker_bottom_sheet.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('DatePickerBottomSheet Example')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: DatePickerBottomSheet(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a date';
              }
              return null;
            },
            onChanged: (value) => log('Selected date: $value'),
          ),
        ),
      ),
    );
  }
}
