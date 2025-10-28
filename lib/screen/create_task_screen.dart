import 'package:flutter/material.dart';
import '../model/interval_type.dart';
import '../model/task.dart';
import '../service/task_service.dart';
import '../widget/create_task/task_form.dart'; // NEW

class CreateTaskScreen extends StatefulWidget {
  final Task? task;
  const CreateTaskScreen({super.key, this.task});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();

  int _hour = DateTime.now().hour;
  int _minute = DateTime.now().minute;
  IntervalType _repetition = IntervalType.simple;

  DateTime _simpleDate = DateTime.now();
  List<int> _selectedWeekdays = [DateTime.now().weekday - 1];
  // ... other state variables

  @override
  void initState() {
    super.initState();
    if (widget.task != null) _loadFromTask(widget.task!);
  }

  void _loadFromTask(Task t) {
    _textController.text = t.taskText;
    _hour = t.nextReminderAt.hour;
    _minute = t.nextReminderAt.minute;
    _repetition = t.interval;

    if (_repetition == IntervalType.simple) {
      _simpleDate = t.nextReminderAt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUpdate = widget.task != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isUpdate ? 'Edit Task' : 'New Task'),
        elevation: 0,
      ),
      body: TaskForm( // MODULARIZED
        formKey: _formKey,
        textController: _textController,
        hour: _hour,
        minute: _minute,
        repetition: _repetition,
        simpleDate: _simpleDate,
        selectedWeekdays: _selectedWeekdays,
        // ... pass other state variables
        onHourChanged: (h) => setState(() => _hour = h),
        onMinuteChanged: (m) => setState(() => _minute = m),
        onRepetitionChanged: (r) => setState(() => _repetition = r),
        onDateChanged: (date) => setState(() => _simpleDate = date),
        onDaysChanged: (days) => setState(() => _selectedWeekdays = days),
        onSave: () => _validateAndSave(isUpdate),
      ),
    );
  }

  Future<void> _validateAndSave(bool isUpdate) async {
    if (!_formKey.currentState!.validate()) return;

    final ok = isUpdate
        ? await TaskService().updateTask(
      taskId: widget.task!.id!,
      taskText: _textController.text.trim(),
      hour: _hour,
      minute: _minute,
      recurrenceType: _repetition,
      simpleDate: _repetition == IntervalType.simple ? _simpleDate : null,
      weeklyDays: _repetition == IntervalType.weekly ? _selectedWeekdays : null,
      // ... other parameters
    )
        : await TaskService().createTask(
      taskText: _textController.text.trim(),
      hour: _hour,
      minute: _minute,
      recurrenceType: _repetition,
      simpleDate: _repetition == IntervalType.simple ? _simpleDate : null,
      weeklyDays: _repetition == IntervalType.weekly ? _selectedWeekdays : null,
      // ... other parameters
    );

    if (!mounted) return;

    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save task')),
      );
    }
  }
}