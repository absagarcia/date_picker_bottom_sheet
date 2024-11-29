import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:date_picker_textfield/date_picker_textfield.dart';
import 'package:intl/intl.dart';

void main() {
  group('DatePickerTextField Tests', () {
    testWidgets('renders correctly with default properties', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DatePickerTextField(),
          ),
        ),
      );

      // Verify the widget renders correctly
      expect(find.byType(DatePickerTextField), findsOneWidget);
      expect(find.text('Selecciona una fecha'), findsOneWidget);
    });

    testWidgets('displays a date when selected', (tester) async {
      final controller = TextEditingController();
      final selectedDate = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day);
      final formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DatePickerTextField(
              controller: controller,
              dateFormat: 'dd-MM-yyyy',
              confirmButtonText: 'OK',
            ),
          ),
        ),
      );

      // Simulate a tap to open the date picker
      await tester.tap(find.byType(TextFormField));
      await tester.pumpAndSettle();

      // Simulate selecting a specific day (e.g., 15)
      await tester.tap(find.text(
          DateTime.now().day.toString())); // Select day 15 in the calendar
      await tester.tap(find.text('OK')); // Press the "OK" button
      await tester.pumpAndSettle();

      // Verify the controller contains the selected date in the expected format
      expect(controller.text, formattedDate);
    });

    testWidgets('validates input correctly with a validator', (tester) async {
      final key = GlobalKey<FormState>();
      String? validator(String? value) {
        if (value == null || value.isEmpty) {
          return 'Please select a date';
        }
        return null;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: key,
              child: DatePickerTextField(
                validator: validator,
                confirmButtonText: 'OK',
              ),
            ),
          ),
        ),
      );

      // Simulate form validation
      final formState = key.currentState!;
      expect(formState.validate(),
          isFalse); // Should fail because no date is selected

      // Simulate selecting a date
      await tester.tap(find.byType(TextFormField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('15')); // Select day 15
      await tester.tap(find.text('OK')); // Press "OK"
      await tester.pumpAndSettle();

      // Validate again after selecting a date
      expect(formState.validate(), isTrue);
    });

    testWidgets('onChanged callback is triggered when a date is selected',
        (tester) async {
      String? selectedDate;
      final expectedDate = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day);
      final formattedDate = DateFormat('dd-MM-yyyy').format(expectedDate);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DatePickerTextField(
              onChanged: (value) {
                selectedDate = value;
              },
              confirmButtonText: 'OK',
            ),
          ),
        ),
      );

      // Simulate selecting a date
      await tester.tap(find.byType(TextFormField));
      await tester.pumpAndSettle();
      await tester
          .tap(find.text(DateTime.now().day.toString())); // Select actual day
      await tester.tap(find.text('OK')); // Press "OK"
      await tester.pumpAndSettle();

      // Verify the onChanged callback was triggered with the selected date
      expect(selectedDate, formattedDate);
    });

    testWidgets('custom InputDecoration works as expected', (tester) async {
      const hintText = 'Custom hint';
      const labelText = 'Custom label';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DatePickerTextField(
              decoration: const InputDecoration(
                hintText: hintText,
                labelText: labelText,
              ),
            ),
          ),
        ),
      );

      // Verify that the custom properties are displayed correctly
      expect(find.text(hintText), findsOneWidget);
      expect(find.text(labelText), findsOneWidget);
    });

    testWidgets('respects selectableFutureOnly = false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DatePickerTextField(
              selectableFutureOnly: false,
            ),
          ),
        ),
      );

      // Open the date picker
      await tester.tap(find.byType(TextFormField));
      await tester.pumpAndSettle();

      // Try selecting a past date (e.g., yesterday)
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(find.text('${yesterday.day}'),
          findsOneWidget); // Should be selectable
    });
  });
}
