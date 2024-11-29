library date_picker_textfield;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A customizable `DatePickerBottomSheet` widget that combines a `TextFormField`
/// with a date picker for user-friendly date input.
///
/// It supports external controllers, validators, and change listeners.
///
/// Example usage:
/// ```dart
/// DatePickerBottomSheet(
///   controller: myController,
///   validator: (value) {
///     if (value == null || value.isEmpty) {
///       return 'Please select a date';
///     }
///     return null;
///   },
///   onChanged: (value) => print('Selected date: $value'),
/// )
/// ```
class DatePickerBottomSheet extends StatefulWidget {
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final InputDecoration? decoration;
  final String? labelText;
  final String? hintText;
  final String dateFormat;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Widget? suffixIcon;
  final TextStyle? style;
  final bool selectableFutureOnly;
  final String confirmButtonText;
  final String cancelButtonText;
  final String? bottomSheetText;
  final bool Function(DateTime date)? selectableDayPredicate;

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

  Future<void> _selectDate(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime initialDate = now;

    if (_internalController.text.isNotEmpty) {
      try {
        initialDate =
            DateFormat(widget.dateFormat).parse(_internalController.text);
      } catch (e) {
        // Handle invalid date format
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
                    widget.bottomSheetText!,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 24),
                  ),
                ],
              ),
              Expanded(
                child: CalendarDatePicker(
                  initialDate: initialDate,
                  firstDate: widget.firstDate ?? DateTime.now(),
                  lastDate: widget.lastDate ??
                      DateTime.now().add(Duration(days: 365 * 5)),
                  onDateChanged: (date) => selectedDate = date,
                  selectableDayPredicate: widget.selectableDayPredicate ??
                      (date) => widget.selectableFutureOnly
                          ? date.isAfter(
                              DateTime.now().subtract(const Duration(days: 1)))
                          : true,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
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
          labelText: widget.labelText ?? 'Selecciona una fecha',
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
