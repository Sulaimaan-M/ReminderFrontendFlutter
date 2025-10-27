import 'package:flutter/material.dart';
import '../model/interval_type.dart';
import '../model/task.dart';
import '../service/task_service.dart';
import '../widget/create_task/inline_time_picker.dart';
import '../widget/create_task/inline_date_picker.dart';
import '../widget/create_task/weekly_multi_selector.dart';
import '../widget/create_task/monthly_selector.dart';
import '../widget/create_task/inline_yearly_picker.dart';
import '../model/yearly_selection.dart';

class CreateTaskScreen extends StatefulWidget {
  final Task? task; // null => create, non-null => update
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
  MonthlyMode _monthlyMode = MonthlyMode.singleDay;
  int _monthlySingleDay = DateTime.now().day;
  int _monthlyRangeStart = 1;
  int _monthlyRangeEnd = 7;
  YearlySelection _yearlySelection = YearlySelection(DateTime.now().month, DateTime.now().day);

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
    // For weekly/monthly/yearly, we don’t yet have pattern details from backend response;
    // Keep defaults for dynamic section and allow the user to reselect.
  }

  @override
  Widget build(BuildContext context) {
    final isUpdate = widget.task != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isUpdate ? 'Edit Task' : 'New Task'),
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
          _buildSaveButton(isUpdate),
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
      case IntervalType.weekly:
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
      case IntervalType.monthly:
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
      case IntervalType.yearly:
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
      case IntervalType.daily:
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSaveButton(bool isUpdate) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _validateAndSave(isUpdate),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(isUpdate ? 'Update Task' : 'Create Task'),
          ),
        ),
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
      monthlySingleDay: _repetition == IntervalType.monthly && _monthlyMode == MonthlyMode.singleDay
          ? _monthlySingleDay
          : null,
      monthlyRangeStart: _repetition == IntervalType.monthly && _monthlyMode == MonthlyMode.dayRange
          ? _monthlyRangeStart
          : null,
      monthlyRangeEnd: _repetition == IntervalType.monthly && _monthlyMode == MonthlyMode.dayRange
          ? _monthlyRangeEnd
          : null,
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
      monthlySingleDay: _repetition == IntervalType.monthly && _monthlyMode == MonthlyMode.singleDay
          ? _monthlySingleDay
          : null,
      monthlyRangeStart: _repetition == IntervalType.monthly && _monthlyMode == MonthlyMode.dayRange
          ? _monthlyRangeStart
          : null,
      monthlyRangeEnd: _repetition == IntervalType.monthly && _monthlyMode == MonthlyMode.dayRange
          ? _monthlyRangeEnd
          : null,
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
}