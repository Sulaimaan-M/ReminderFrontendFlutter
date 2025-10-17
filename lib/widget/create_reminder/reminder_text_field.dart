import 'package:flutter/material.dart';

class ReminderTextField extends StatelessWidget {
  final TextEditingController controller;
  const ReminderTextField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Reminder Text *',
        border: OutlineInputBorder(),
      ),
      validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
    );
  }
}