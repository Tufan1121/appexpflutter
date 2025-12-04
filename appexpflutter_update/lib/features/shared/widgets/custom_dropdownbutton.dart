import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';

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
      height: 56,
      width: 330,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colores.dividerColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colores.primaryColor.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: DropdownButtonFormField<T>(
            decoration: InputDecoration(
              prefixIcon: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colores.primaryColor.withValues(alpha: 0.08),
                      Colores.accentColor.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: prefixIcon,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
            initialValue: value,
            items: items,
            onChanged: onChanged,
            hint: AutoSizeText(
              hint ?? '',
              style: styleHint ?? Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colores.textTertiary,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            icon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: icon ?? Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colores.primaryColor,
                size: 24,
              ),
            ),
            iconEnabledColor: Colores.primaryColor,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colores.textPrimary,
            ),
            dropdownColor: Colors.white,
            isExpanded: true,
            borderRadius: BorderRadius.circular(16),
            elevation: 8,
          ),
        ),
      ),
    );
  }
}
