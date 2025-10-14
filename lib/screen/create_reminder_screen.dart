// screen/create_reminder_screen.dart

import 'package:flutter/material.dart';
import '../model/reminder.dart';
import '../service/reminder_service.dart';
import '../widget/create_reminder/reminder_text_field.dart';
import '../widget/create_reminder/time_picker_section.dart';
import '../widget/create_reminder/repetition_selector.dart';
import '../widget/create_reminder/dynamic_section.dart';
import '../widget/create_reminder/yearly_section.dart';

class CreateReminderScreen extends StatefulWidget {
  final Reminder? reminder;
  const CreateReminderScreen({super.key, this.reminder});

  @override
  State<CreateReminderScreen> createState() => _CreateReminderScreenState();
}

class _CreateReminderScreenState extends State<CreateReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();

  int _hour = DateTime.now().hour;
  int _minute = DateTime.now().minute;
  IntervalType _repetition = IntervalType.simple;
  DateTime _simpleDate = DateTime.now();
  int _selectedWeekday = DateTime.now().weekday - 1;
  int _monthlyDay = DateTime.now().day;
  YearlySelection _yearlySelection = YearlySelection(DateTime.now().month, DateTime.now().day);

  @override
  void initState() {
    super.initState();
    if (widget.reminder != null) _loadReminder(widget.reminder!);
  }

  void _loadReminder(Reminder r) {
    _textController.text = r.reminderTxt;
    _hour = r.remindAt.hour;
    _minute = r.remindAt.minute;
    _repetition = r.interval;
    if (_repetition == IntervalType.simple) {
      _simpleDate = r.remindAt;
    }
    // Note: Weekly/Monthly/Yearly extra data not stored in Reminder model yet
    // So we use current defaults for _selectedWeekday, _monthlyDay, _yearlySelection
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.reminder == null
            ? const Text('New Reminder')
            : const Text('Edit Reminder'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReminderTextField(controller: _textController),
              const SizedBox(height: 16),
              TimePickerSection(
                hour: _hour,
                minute: _minute,
                onTimeSelected: (time) => setState(() {
                  _hour = time.hour;
                  _minute = time.minute;
                }),
              ),
              const SizedBox(height: 16),
              RepetitionSelector(
                value: _repetition,
                onChanged: (v) => setState(() => _repetition = v!),
              ),
              const SizedBox(height: 16),
              DynamicSection(
                repetition: _repetition,
                simpleDate: _simpleDate,
                selectedWeekday: _selectedWeekday,
                monthlyDay: _monthlyDay,
                yearlySelection: _yearlySelection,
                onSimpleDateSelected: (date) => setState(() => _simpleDate = date),
                onWeekdaySelected: (index) => setState(() => _selectedWeekday = index),
                onMonthlyDaySelected: (day) => setState(() => _monthlyDay = day),
                onYearlySelectionChanged: (sel) => setState(() => _yearlySelection = sel),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _onSave,
                child: const Text('Save Reminder'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    DateTime remindAt;
    if (_repetition == IntervalType.simple) {
      remindAt = DateTime(_simpleDate.year, _simpleDate.month, _simpleDate.day, _hour, _minute);
    } else {
      final now = DateTime.now();
      remindAt = DateTime(now.year, now.month, now.day, _hour, _minute);
    }

    final reminder = Reminder(
      reminderTxt: _textController.text.trim(),
      remindAt: remindAt,
      interval: _repetition,
    );

    final service = ReminderService();

    // ✅ Use editReminder if editing, createReminder if new
    final success = widget.reminder != null
        ? await service.editReminder(reminder)
        : await service.createReminder(reminder);

    if (!mounted) return;
    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save')));
    }
  }
}