import 'package:flutter/material.dart';
import 'package:date_picker_textfield/date_picker_textfield.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('DatePickerTextField Example')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: DatePickerTextField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a date';
              }
              return null;
            },
            onChanged: (value) => print('Selected date: $value'),
          ),
        ),
      ),
    );
  }
}
