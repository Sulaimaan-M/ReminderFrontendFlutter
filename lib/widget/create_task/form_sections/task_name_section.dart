import 'package:flutter/material.dart';

class TaskNameSection extends StatelessWidget {
  final TextEditingController controller;

  const TaskNameSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Task Name',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter task name',
            border: OutlineInputBorder(),
            filled: true,
          ),
          validator: (v) => v?.trim().isEmpty == true ? 'Task name is required' : null,
        ),
      ],
    );
  }
}// TODO Implement this library.