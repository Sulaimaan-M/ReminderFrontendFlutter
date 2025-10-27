import 'package:flutter/material.dart';
import 'inline_day_picker.dart';

enum MonthlyMode { singleDay, dayRange }

class MonthlySelector extends StatefulWidget {
  final MonthlyMode mode;
  final int singleDay;
  final int rangeStart;
  final int rangeEnd;
  final ValueChanged<MonthlyMode> onModeChanged;
  final ValueChanged<int> onSingleDayChanged;
  final ValueChanged<int> onRangeStartChanged;
  final ValueChanged<int> onRangeEndChanged;

  const MonthlySelector({
    super.key,
    required this.mode,
    required this.singleDay,
    required this.rangeStart,
    required this.rangeEnd,
    required this.onModeChanged,
    required this.onSingleDayChanged,
    required this.onRangeStartChanged,
    required this.onRangeEndChanged,
  });

  @override
  State<MonthlySelector> createState() => _MonthlySelectorState();
}

class _MonthlySelectorState extends State<MonthlySelector> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<MonthlyMode>(
          segments: const [
            ButtonSegment(
              value: MonthlyMode.singleDay,
              label: Text('Single Day'),
              icon: Icon(Icons.calendar_today, size: 16),
            ),
            ButtonSegment(
              value: MonthlyMode.dayRange,
              label: Text('Day Range'),
              icon: Icon(Icons.date_range, size: 16),
            ),
          ],
          selected: {widget.mode},
          onSelectionChanged: (Set<MonthlyMode> newSelection) {
            widget.onModeChanged(newSelection.first);
          },
        ),
        const SizedBox(height: 16),
        if (widget.mode == MonthlyMode.singleDay) ...[
          Text(
            'Day of Month',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          InlineDayPicker(
            day: widget.singleDay,
            onDayChanged: widget.onSingleDayChanged,
          ),
          const SizedBox(height: 8),
          Text(
            'Note: If day doesn\'t exist (e.g., Feb 31), last day of month will be used.',
            style: TextStyle(fontSize: 11, color: Colors.grey[600], fontStyle: FontStyle.italic),
          ),
        ] else ...[
          Text(
            'Day Range',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'From Day',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 4),
                    _buildCompactDayPicker(widget.rangeStart, widget.onRangeStartChanged),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'To Day',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 4),
                    _buildCompactDayPicker(widget.rangeEnd, widget.onRangeEndChanged),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Reminders will trigger every day from ${widget.rangeStart} to ${widget.rangeEnd} of each month.',
            style: TextStyle(fontSize: 11, color: Colors.grey[600], fontStyle: FontStyle.italic),
          ),
        ],
      ],
    );
  }

  Widget _buildCompactDayPicker(int day, ValueChanged<int> onChanged) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade50,
      ),
      child: InlineDayPicker(
        day: day,
        onDayChanged: onChanged,
      ),
    );
  }
}