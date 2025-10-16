// widget/create_reminder/time_picker_section.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// for TimeSelection

class TimeSelection {
  final int hour;
  final int minute;
  TimeSelection(this.hour, this.minute);
}

class TimePickerSection extends StatefulWidget {
  final int hour;
  final int minute;
  final ValueChanged<TimeSelection> onTimeSelected;

  const TimePickerSection({
    super.key,
    required this.hour,
    required this.minute,
    required this.onTimeSelected,
  });

  @override
  State<TimePickerSection> createState() => _TimePickerSectionState();
}

class _TimePickerSectionState extends State<TimePickerSection> {
  late int _hour;
  late int _minute;

  @override
  void initState() {
    super.initState();
    _hour = widget.hour;
    _minute = widget.minute;
  }

  Future<void> _showTimePicker() async {
    final result = await showModalBottomSheet<TimeSelection>(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 200,
          child: Column(
            children: [
              const Text('Select time', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      child: CupertinoPicker(
                        itemExtent: 32,
                        scrollController: FixedExtentScrollController(initialItem: _hour),
                        onSelectedItemChanged: (index) => setState(() => _hour = index),
                        children: List.generate(24, (i) => Center(child: Text(i.toString().padLeft(2, '0')))),
                      ),
                    ),
                    const Text(' : ', style: TextStyle(fontSize: 20)),
                    SizedBox(
                      width: 80,
                      child: CupertinoPicker(
                        itemExtent: 32,
                        scrollController: FixedExtentScrollController(initialItem: _minute),
                        onSelectedItemChanged: (index) => setState(() => _minute = index),
                        children: List.generate(60, (i) => Center(child: Text(i.toString().padLeft(2, '0')))),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, TimeSelection(_hour, _minute)),
                child: const Text('Done'),
              ),
            ],
          ),
        );
      },
    );
    if (result != null) {
      widget.onTimeSelected(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Time:'),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: _showTimePicker,
          child: Text('${widget.hour.toString().padLeft(2, '0')}:${widget.minute.toString().padLeft(2, '0')}'),
        ),
      ],
    );
  }
}