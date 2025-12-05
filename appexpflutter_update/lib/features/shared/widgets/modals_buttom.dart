import 'package:appexpflutter_update/features/home/presentation/screens/widgets/popover.dart';
import 'package:flutter/material.dart';

class Modals {
  final BuildContext context;
  final Widget child;
  final double? height;

  Modals({required this.context, required this.child, required this.height});
  Future<dynamic> homeModalButtom() {
    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Popover(
          child: Container(
            height: height,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
