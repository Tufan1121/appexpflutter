import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';

class CustomReactiveTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? errorMessage;
  final String? suffixText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String formControlName;
  final Map<String, String Function(Object)>? validationMessages;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(FormControl<String>)? onSubmitted;
  final IconData? icon;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool readOnly;
  final TextStyle? hintStyle;
  final TextStyle? errorStyle;

  const CustomReactiveTextField({
    super.key,
    this.label,
    this.hint,
    this.errorMessage,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    required this.formControlName,
    this.validationMessages,
    this.inputFormatters,
    this.icon,
    this.suffixIcon,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixText,
    this.readOnly = false,
    this.hintStyle,
    this.errorStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colores.dividerColor.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colores.primaryColor.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ReactiveTextField<String>(
        readOnly: readOnly,
        obscureText: obscureText,
        keyboardType: keyboardType,
        formControlName: formControlName,
        inputFormatters: inputFormatters,
        onSubmitted: onSubmitted,
        autocorrect: false,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Colores.textPrimary,
        ),
        validationMessages: validationMessages,
        decoration: InputDecoration(
          hintText: hint,
          labelText: label,
          hintStyle: hintStyle ?? Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colores.textTertiary,
          ),
          labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colores.textSecondary,
            fontWeight: FontWeight.w500,
          ),
          floatingLabelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colores.primaryColor,
            fontWeight: FontWeight.w600,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colores.primaryColor,
              width: 2,
            ),
          ),
          errorStyle: errorStyle ?? Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colores.errorColor,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colores.errorColor,
              width: 1.5,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colores.errorColor,
              width: 2,
            ),
          ),
          isDense: true,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          suffixText: suffixText,
          suffixStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colores.textSecondary,
          ),
          icon: icon != null
              ? Icon(icon, color: Colores.primaryColor)
              : null,
        ),
      ),
    );
  }
}
