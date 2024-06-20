import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class CustomDropdownButton<T> extends StatelessWidget {
  final List<DropdownMenuItem<T>>? items;
  final T? value;
  final Widget? prefixIcon;
  final Widget? icon;
  final void Function(T?)? onChanged;
  final String? hint;
  final TextStyle? styleHint;

  const CustomDropdownButton({
    super.key,
    required this.prefixIcon,
    this.onChanged,
    this.value,
    required this.items,
    this.hint,
    this.icon,
    this.styleHint,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: 330,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(2.0, 5.0),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
          child: DropdownButtonFormField<T>(
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: prefixIcon,
              ),
              border: InputBorder.none,
            ),
            value: value,
            items: items,
            onChanged: onChanged,
            hint: SingleChildScrollView(
              child: AutoSizeText(
                hint ?? '',
                style: styleHint,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            icon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: icon,
            ),
            iconEnabledColor: Colors.blue, // Example color
            style: TextStyle(color: Colors.black.withOpacity(.7), fontSize: 20),
            dropdownColor: Colors.white,
            isExpanded: true,
          ),
        ),
      ),
    );
  }
}
