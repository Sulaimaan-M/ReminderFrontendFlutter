import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class SimpleDateSection extends StatefulWidget {
  final DateTime date;
  final ValueChanged<DateTime> onDateSelected;

  const SimpleDateSection({
    super.key,
    required this.date,
    required this.onDateSelected,
  });

  @override
  State<SimpleDateSection> createState() => _SimpleDateSectionState();
}

class _SimpleDateSectionState extends State<SimpleDateSection> {
  late int _month;
  late int _day;
  late int _year;

  @override
  void initState() {
    super.initState();
    _month = widget.date.month;
    _day = widget.date.day;
    _year = widget.date.year;
  }

  Future<void> _showPicker() async {
    final result = await showModalBottomSheet<DateTime>(
      context: context,
      builder: (context) {
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              height: 240,
              child: Column(
                children: [
                  const Text('Select date', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildPicker(
                          items: months,
                          initialIndex: _month - 1,
                          onIndexChanged: (index) => setState(() => _month = index + 1),
                        ),
                        const SizedBox(width: 12),
                        _buildPicker(
                          items: List.generate(31, (i) => '${i + 1}'),
                          initialIndex: _day - 1,
                          onIndexChanged: (index) => setState(() => _day = index + 1),
                        ),
                        const SizedBox(width: 12),
                        _buildPicker(
                          items: List.generate(10, (i) => '${2025 + i}'),
                          initialIndex: _year - 2025,
                          onIndexChanged: (index) => setState(() => _year = 2025 + index),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, DateTime(_year, _month, _day)),
                    child: const Text('Done'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    if (result != null) {
      widget.onDateSelected(result);
    }
  }

  Widget _buildPicker({
    required List<String> items,
    required int initialIndex,
    required ValueChanged<int> onIndexChanged,
  }) {
    return SizedBox(
      width: 70,
      child: CupertinoPicker(
        itemExtent: 32,
        scrollController: FixedExtentScrollController(initialItem: initialIndex),
        onSelectedItemChanged: onIndexChanged,
        children: items.map((e) => Center(child: Text(e))).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Date:'),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: _showPicker,
          child: Text('${widget.date.month}/${widget.date.day}/${widget.date.year}'),
        ),
      ],
    );
  }
}