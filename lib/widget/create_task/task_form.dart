import 'package:flutter/material.dart';
import '../../model/interval_type.dart';
import 'form_sections/task_name_section.dart';
import 'form_sections/time_section.dart';
import 'form_sections/repetition_section.dart';
import 'form_sections/dynamic_section.dart';
import '../form_actions.dart';

class TaskForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController textController;
  final int hour;
  final int minute;
  final IntervalType repetition;
  final DateTime simpleDate;
  final List<int> selectedWeekdays;
  final Function(int) onHourChanged;
  final Function(int) onMinuteChanged;
  final Function(IntervalType) onRepetitionChanged;
  final Function(DateTime) onDateChanged;
  final Function(List<int>) onDaysChanged;
  final VoidCallback onSave;

  const TaskForm({
    super.key,
    required this.formKey,
    required this.textController,
    required this.hour,
    required this.minute,
    required this.repetition,
    required this.simpleDate,
    required this.selectedWeekdays,
    required this.onHourChanged,
    required this.onMinuteChanged,
    required this.onRepetitionChanged,
    required this.onDateChanged,
    required this.onDaysChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Form(
            key: formKey,
            child: ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                TaskNameSection(controller: textController),
                const SizedBox(height: 20),
                TimeSection(
                  hour: hour,
                  minute: minute,
                  onHourChanged: onHourChanged,
                  onMinuteChanged: onMinuteChanged,
                ),
                const SizedBox(height: 20),
                RepetitionSection(
                  value: repetition,
                  onChanged: onRepetitionChanged,
                ),
                const SizedBox(height: 20),
                DynamicSection(
                  repetition: repetition,
                  simpleDate: simpleDate,
                  selectedDays: selectedWeekdays,
                  onDateChanged: onDateChanged,
                  onDaysChanged: onDaysChanged,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        FormActions(onSave: onSave),
      ],
    );
  }
}