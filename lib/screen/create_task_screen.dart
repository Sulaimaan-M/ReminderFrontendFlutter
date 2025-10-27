import 'package:flutter/material.dart';
import '../model/reminder.dart';
import '../service/reminder_service.dart';
import '../widget/create_task/inline_time_picker.dart';
import '../widget/create_task/inline_date_picker.dart';
import '../widget/create_task/weekly_multi_selector.dart';
import '../widget/create_task/monthly_selector.dart';
import '../widget/create_task/inline_yearly_picker.dart';
import '../model/yearly_selection.dart';
import '../util/reminder_time_adjuster.dart';

class CreateTaskScreen extends StatefulWidget {
  final Reminder? reminder;
  const CreateTaskScreen({super.key, this.reminder});

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

  MonthlyMode _monthlyMode = MonthlyMode.singleDay;
  int _monthlySingleDay = DateTime.now().day;
  int _monthlyRangeStart = 1;
  int _monthlyRangeEnd = 7;

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.reminder == null
            ? const Text('New Task')
            : const Text('Edit Task'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20.0),
                children: [
                  _buildTaskNameField(),
                  const SizedBox(height: 20),
                  _buildTimeField(),
                  const SizedBox(height: 20),
                  _buildRepetitionField(),
                  const SizedBox(height: 20),
                  _buildDynamicSection(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildTaskNameField() {
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
          controller: _textController,
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

  Widget _buildTimeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        InlineTimePicker(
          hour: _hour,
          minute: _minute,
          onHourChanged: (h) => setState(() => _hour = h),
          onMinuteChanged: (m) => setState(() => _minute = m),
        ),
      ],
    );
  }

  Widget _buildRepetitionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Repeat',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<IntervalType>(
          value: _repetition,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            filled: true,
          ),
          items: IntervalType.values.map((e) {
            return DropdownMenuItem(value: e, child: Text(e.label));
          }).toList(),
          onChanged: (value) => setState(() => _repetition = value!),
        ),
      ],
    );
  }

  Widget _buildDynamicSection() {
    switch (_repetition) {
      case IntervalType.simple:
        return _buildSimpleSection();
      case IntervalType.weekly:
        return _buildWeeklySection();
      case IntervalType.monthly:
        return _buildMonthlySection();
      case IntervalType.yearly:
        return _buildYearlySection();
      case IntervalType.daily:
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSimpleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        InlineDatePicker(
          date: _simpleDate,
          onDateChanged: (date) => setState(() => _simpleDate = date),
        ),
      ],
    );
  }

  Widget _buildWeeklySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Days of Week',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        WeeklyMultiSelector(
          selectedDays: _selectedWeekdays,
          onDaysChanged: (days) => setState(() => _selectedWeekdays = days),
        ),
      ],
    );
  }

  Widget _buildMonthlySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monthly Schedule',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        MonthlySelector(
          mode: _monthlyMode,
          singleDay: _monthlySingleDay,
          rangeStart: _monthlyRangeStart,
          rangeEnd: _monthlyRangeEnd,
          onModeChanged: (mode) => setState(() => _monthlyMode = mode),
          onSingleDayChanged: (day) => setState(() => _monthlySingleDay = day),
          onRangeStartChanged: (day) => setState(() => _monthlyRangeStart = day),
          onRangeEndChanged: (day) => setState(() => _monthlyRangeEnd = day),
        ),
      ],
    );
  }

  Widget _buildYearlySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date (Month & Day)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        InlineYearlyPicker(
          selection: _yearlySelection,
          onSelectionChanged: (sel) => setState(() => _yearlySelection = sel),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _validateAndSave,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              widget.reminder == null ? 'Create Task' : 'Update Task',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _validateAndSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (_repetition == IntervalType.weekly && _selectedWeekdays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one day for weekly reminder')),
      );
      return;
    }

    await _onSave();
  }

  Future<void> _onSave() async {
    DateTime remindAt;
    if (_repetition == IntervalType.simple) {
      remindAt = DateTime(_simpleDate.year, _simpleDate.month, _simpleDate.day, _hour, _minute);
    } else {
      final now = DateTime.now();
      remindAt = DateTime(now.year, now.month, now.day, _hour, _minute);
    }

    remindAt = ReminderTimeAdjuster.adjustToFuture(remindAt, _repetition);

    final deviceId = await ReminderService().getDeviceId() ?? 0;

    final reminder = Reminder(
      id: widget.reminder?.id,
      reminderTxt: _textController.text.trim(),
      remindAt: remindAt,
      interval: _repetition,
      deviceId: deviceId,
    );

    final service = ReminderService();
    Reminder? result;

    if (widget.reminder != null) {
      result = await service.editReminder(reminder);
    } else {
      result = await service.createReminder(reminder);
    }

    if (!mounted) return;
    if (result != null) {
      Navigator.pop(context, result);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save')));
    }
  }
}