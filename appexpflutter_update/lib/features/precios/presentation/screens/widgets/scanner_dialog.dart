import 'package:flutter/material.dart';

class ScannerDialog extends StatelessWidget {
  const ScannerDialog({super.key, this.child});
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}
