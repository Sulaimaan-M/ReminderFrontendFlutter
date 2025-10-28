import 'package:flutter/material.dart';

class TodoHeader extends StatelessWidget {
  final String title;

  const TodoHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }
}

class TodoEmptyState extends StatelessWidget {
  final String text;

  const TodoEmptyState({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Center(child: Text(text, style: TextStyle(color: Colors.grey[600], fontSize: 16))),
      ),
    );
  }
}

class TodoDivider extends StatelessWidget {
  const TodoDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Divider(thickness: 1, color: Colors.grey[300]),
      ),
    );
  }
}