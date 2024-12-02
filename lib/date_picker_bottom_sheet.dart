library date_picker_textfield;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A customizable widget for selecting dates through a bottom sheet.
///
/// Combines a `TextFormField` with a calendar date picker for user-friendly
/// date input. Supports external controllers, validation, and various
/// customizations for appearance and functionality.
///
/// Example usage:
/// ```dart
/// DatePickerBottomSheet(
///   controller: myController,
///   validator: (value) => value?.isEmpty == true ? 'Select a date' : null,
///   onChanged: (value) => print('Date selected: $value'),
/// )
/// ```
class DatePickerBottomSheet extends StatefulWidget {
  /// Controller for managing the text field content.
  ///
  /// If not provided, an internal controller will be used.
  final TextEditingController? controller;

  /// Validator function for the text field.
  ///
  /// Can be used to ensure that the selected date meets specific requirements.
  final FormFieldValidator<String>? validator;

  /// Callback triggered when the date changes.
  ///
  /// Provides the formatted date string as its parameter.
  final ValueChanged<String>? onChanged;

  /// Decoration for the `TextFormField`.
  ///
  /// Overrides [labelText], [hintText], and [suffixIcon] if provided.
  final InputDecoration? decoration;

  /// Label text displayed within the `TextFormField`.
  ///
  /// Ignored if [decoration] is provided.
  final String? labelText;

  /// Hint text displayed within the `TextFormField`.
  ///
  /// Defaults to the provided date format.
  final String? hintText;

  /// Format for displaying and parsing dates.
  ///
  /// Defaults to `'dd-MM-yyyy'`.
  final String dateFormat;

  /// The earliest selectable date.
  ///
  /// Defaults to the current date if not provided.
  final DateTime? firstDate;

  /// The latest selectable date.
  ///
  /// Defaults to five years from the current date if not provided.
  final DateTime? lastDate;

  /// Icon displayed at the end of the `TextFormField`.
  ///
  /// Defaults to a calendar icon with a tap handler to open the bottom sheet.
  final Widget? suffixIcon;

  /// Text style for the `TextFormField`.
  ///
  /// Applies to the displayed date and placeholder text.
  final TextStyle? style;

  /// Whether only future dates can be selected.
  ///
  /// Defaults to `true`.
  final bool selectableFutureOnly;

  /// Text for the confirmation button in the bottom sheet.
  ///
  /// Defaults to `'Aceptar'`.
  final String confirmButtonText;

  /// Text for the cancel button in the bottom sheet.
  ///
  /// Defaults to `'Cancelar'`.
  final String cancelButtonText;

  /// Text displayed at the top of the bottom sheet.
  ///
  /// Provides context to the user about the current selection task.
  final String? bottomSheetText;

  /// Predicate to determine which days are selectable.
  ///
  /// Defaults to allowing all future days if [selectableFutureOnly] is `true`.
  final bool Function(DateTime date)? selectableDayPredicate;

  /// Creates a `DatePickerBottomSheet` with customizable properties.
  const DatePickerBottomSheet({
    super.key,
    this.controller,
    this.validator,
    this.onChanged,
    this.decoration,
    this.labelText,
    this.hintText,
    this.dateFormat = 'dd-MM-yyyy',
    this.firstDate,
    this.lastDate,
    this.suffixIcon,
    this.style,
    this.selectableFutureOnly = true,
    this.confirmButtonText = 'Aceptar',
    this.cancelButtonText = 'Cancelar',
    this.selectableDayPredicate,
    this.bottomSheetText = 'Selecciona una fecha',
  });

  @override
  State<DatePickerBottomSheet> createState() => _DatePickerBottomSheetState();
}

/// Internal state for `DatePickerBottomSheet`.
///
/// Manages the lifecycle of the text controller and handles date selection.
class _DatePickerBottomSheetState extends State<DatePickerBottomSheet> {
  late TextEditingController _internalController;

  @override
  void initState() {
    super.initState();
    _internalController = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  /// Opens the bottom sheet to select a date.
  Future<void> _selectDate(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime initialDate = now;

    if (_internalController.text.isNotEmpty) {
      try {
        initialDate =
            DateFormat(widget.dateFormat).parse(_internalController.text);
      } catch (e) {
        // Invalid date format, fallback to current date
      }
    }

    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        DateTime selectedDate = initialDate;
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.bottomSheetText ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Expanded(
                child: CalendarDatePicker(
                  initialDate: initialDate,
                  firstDate: widget.firstDate ?? now,
                  lastDate:
                      widget.lastDate ?? now.add(const Duration(days: 1825)),
                  onDateChanged: (date) => selectedDate = date,
                  selectableDayPredicate: widget.selectableDayPredicate ??
                      (date) => widget.selectableFutureOnly
                          ? date.isAfter(now.subtract(const Duration(days: 1)))
                          : true,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      final formattedDate =
                          DateFormat(widget.dateFormat).format(selectedDate);
                      _internalController.text = formattedDate;
                      widget.onChanged?.call(formattedDate);
                    });
                    Navigator.pop(context);
                  },
                  child: Text(widget.confirmButtonText),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final decoration = widget.decoration ??
        InputDecoration(
          labelText: widget.labelText ?? 'Select a date',
          hintText: widget.hintText ?? widget.dateFormat.toUpperCase(),
          suffixIcon: widget.suffixIcon ??
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => _selectDate(context),
              ),
        );

    return TextFormField(
      controller: _internalController,
      decoration: decoration,
      readOnly: true,
      onTap: () => _selectDate(context),
      style: widget.style,
      validator: widget.validator,
      onChanged: widget.onChanged,
    );
  }
}
