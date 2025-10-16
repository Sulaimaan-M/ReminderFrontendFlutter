// lib/widget/create_reminder/yearly_section.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../model/yearly_selection.dart'; // 👈 UPDATED IMPORT

class YearlySection extends StatefulWidget {
  final YearlySelection selection;
  final ValueChanged<YearlySelection> onSelectionChanged;

  const YearlySection({
    super.key,
    required this.selection,
    required this.onSelectionChanged,
  });

  @override
  State<YearlySection> createState() => _YearlySectionState();
}

class _YearlySectionState extends State<YearlySection> {
  late int _month;
  late int _day;

  @override
  void initState() {
    super.initState();
    _month = widget.selection.month;
    _day = widget.selection.day;
  }

  Future<void> _showPicker() async {
    final result = await showModalBottomSheet<YearlySelection>(
      context: context,
      builder: (context) {
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              height: 220,
              child: Column(
                children: [
                  const Text('Select month and day', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 100,
                          child: CupertinoPicker(
                            itemExtent: 32,
                            scrollController: FixedExtentScrollController(initialItem: _month - 1),
                            onSelectedItemChanged: (index) => setState(() => _month = index + 1),
                            children: List.generate(12, (i) => Center(child: Text(months[i]))),
                          ),
                        ),
                        const SizedBox(width: 24),
                        SizedBox(
                          width: 80,
                          child: CupertinoPicker(
                            itemExtent: 32,
                            scrollController: FixedExtentScrollController(initialItem: _day - 1),
                            onSelectedItemChanged: (index) => setState(() => _day = index + 1),
                            children: List.generate(31, (i) => Center(child: Text('${i + 1}'))),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, YearlySelection(_month, _day)),
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
      widget.onSelectionChanged(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Repeat yearly on:'),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: _showPicker,
          child: Text('${months[widget.selection.month - 1]} ${widget.selection.day}'),
        ),
      ],
    );
  }
}