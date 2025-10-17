import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class MonthlySection extends StatefulWidget {
  final int day;
  final ValueChanged<int> onDaySelected;

  const MonthlySection({
    super.key,
    required this.day,
    required this.onDaySelected,
  });

  @override
  State<MonthlySection> createState() => _MonthlySectionState();
}

class _MonthlySectionState extends State<MonthlySection> {
  late int _day;

  @override
  void initState() {
    super.initState();
    _day = widget.day;
  }

  Future<void> _showPicker() async {
    final result = await showModalBottomSheet<int>(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 200,
          child: Column(
            children: [
              const Text('Select day', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 32,
                  onSelectedItemChanged: (index) => Navigator.pop(context, index + 1),
                  scrollController: FixedExtentScrollController(initialItem: _day - 1),
                  children: List.generate(31, (i) => Center(child: Text('${i + 1}'))),
                ),
              ),
              TextButton(onPressed: Navigator.of(context).pop, child: const Text('Done')),
            ],
          ),
        );
      },
    );
    if (result != null) {
      widget.onDaySelected(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Day of month:'),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: _showPicker,
          child: Text('${widget.day}'),
        ),
      ],
    );
  }
}