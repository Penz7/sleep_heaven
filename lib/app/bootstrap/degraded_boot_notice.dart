import 'package:flutter/material.dart';

class DegradedBootNotice extends StatelessWidget {
  const DegradedBootNotice({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        color: Colors.orange.shade700,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: SafeArea(
          bottom: false,
          child: Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
    );
  }
}
