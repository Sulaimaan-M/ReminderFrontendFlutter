import 'package:flutter/material.dart';
import '../model/interval_type.dart';
import '../model/task.dart';
import '../model/yearly_selection.dart';
import '../service/task_service.dart';
import '../widget/create_task/task_form.dart';
import '../widget/create_task/monthly_selector.dart';

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

  // Simple mode
  DateTime _simpleDate = DateTime.now();

  // Weekly mode
  List<int> _selectedWeekdays = [DateTime.now().weekday - 1];

  // Monthly mode
  MonthlyMode _monthlyMode = MonthlyMode.singleDay;
  int _monthlySingleDay = 1;
  int _monthlyRangeStart = 1;
  int _monthlyRangeEnd = 5;

  // Yearly mode
  YearlySelection _yearlySelection = YearlySelection(1, 1); // January 1st

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
    // TODO: Load monthly and yearly data from task if needed
  }

  @override
  Widget build(BuildContext context) {
    final isUpdate = widget.task != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isUpdate ? 'Edit Task' : 'New Task'),
        elevation: 0,
      ),
      body: TaskForm(
        formKey: _formKey,
        textController: _textController,
        hour: _hour,
        minute: _minute,
        repetition: _repetition,
        simpleDate: _simpleDate,
        selectedWeekdays: _selectedWeekdays,

        // Monthly
        monthlyMode: _monthlyMode,
        monthlySingleDay: _monthlySingleDay,
        monthlyRangeStart: _monthlyRangeStart,
        monthlyRangeEnd: _monthlyRangeEnd,

        // Yearly
        yearlySelection: _yearlySelection,

        // Callbacks
        onHourChanged: (h) => setState(() => _hour = h),
        onMinuteChanged: (m) => setState(() => _minute = m),
        onRepetitionChanged: (r) => setState(() => _repetition = r),
        onDateChanged: (date) => setState(() => _simpleDate = date),
        onDaysChanged: (days) => setState(() => _selectedWeekdays = days),

        // Monthly callbacks
        onMonthlyModeChanged: (mode) => setState(() => _monthlyMode = mode),
        onMonthlySingleDayChanged: (day) => setState(() => _monthlySingleDay = day),
        onMonthlyRangeStartChanged: (day) => setState(() => _monthlyRangeStart = day),
        onMonthlyRangeEndChanged: (day) => setState(() => _monthlyRangeEnd = day),

        // Yearly callback
        onYearlySelectionChanged: (selection) => setState(() => _yearlySelection = selection),

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
      // Monthly - convert based on mode
      monthlySingleDay: _repetition == IntervalType.monthly && _monthlyMode == MonthlyMode.singleDay
          ? _monthlySingleDay
          : null,
      monthlyRangeStart: _repetition == IntervalType.monthly && _monthlyMode == MonthlyMode.dayRange
          ? _monthlyRangeStart
          : null,
      monthlyRangeEnd: _repetition == IntervalType.monthly && _monthlyMode == MonthlyMode.dayRange
          ? _monthlyRangeEnd
          : null,
      // Yearly - extract from YearlySelection
      yearlyMonth: _repetition == IntervalType.yearly ? _yearlySelection.month : null,
      yearlyDay: _repetition == IntervalType.yearly ? _yearlySelection.day : null,
    )
        : await TaskService().createTask(
      taskText: _textController.text.trim(),
      hour: _hour,
      minute: _minute,
      recurrenceType: _repetition,
      simpleDate: _repetition == IntervalType.simple ? _simpleDate : null,
      weeklyDays: _repetition == IntervalType.weekly ? _selectedWeekdays : null,
      // Monthly - convert based on mode
      monthlySingleDay: _repetition == IntervalType.monthly && _monthlyMode == MonthlyMode.singleDay
          ? _monthlySingleDay
          : null,
      monthlyRangeStart: _repetition == IntervalType.monthly && _monthlyMode == MonthlyMode.dayRange
          ? _monthlyRangeStart
          : null,
      monthlyRangeEnd: _repetition == IntervalType.monthly && _monthlyMode == MonthlyMode.dayRange
          ? _monthlyRangeEnd
          : null,
      // Yearly - extract from YearlySelection
      yearlyMonth: _repetition == IntervalType.yearly ? _yearlySelection.month : null,
      yearlyDay: _repetition == IntervalType.yearly ? _yearlySelection.day : null,
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

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}