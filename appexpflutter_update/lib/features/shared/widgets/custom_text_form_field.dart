import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactive_forms/reactive_forms.dart';

class CustomReactiveTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? errorMessage;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String formControlName;
  final Map<String, String Function(Object)>? validationMessages;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(FormControl<String>)? onSubmitted;
  final IconData? icon;
  final Widget? suffixIcon;
  final Widget? prefixIcon;

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
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final border = OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.transparent),
        borderRadius: BorderRadius.circular(40));

    const borderRadius = Radius.circular(15);

    return Stack(
      children: [
        Container(
            height: 55,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                    topLeft: borderRadius,
                    bottomLeft: borderRadius,
                    bottomRight: borderRadius),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 5))
                ])),
        SizedBox(
          child: ReactiveTextField<String>(
            obscureText: obscureText,
            keyboardType: keyboardType,
            formControlName: formControlName,
            inputFormatters: inputFormatters,
            onSubmitted: onSubmitted,
            autocorrect: false,
            style: const TextStyle(fontSize: 20, color: Colors.black54),
            validationMessages: validationMessages,
            decoration: InputDecoration(
              floatingLabelStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
              enabledBorder: border,
              focusedBorder: border,
              errorBorder: border.copyWith(
                  borderRadius: const BorderRadius.only(
                      topLeft: borderRadius,
                      bottomLeft: borderRadius,
                      bottomRight: borderRadius),
                  borderSide: BorderSide(color: Colors.red.shade800)),
              focusedErrorBorder: border.copyWith(
                  borderRadius: const BorderRadius.only(
                      topLeft: borderRadius,
                      bottomLeft: borderRadius,
                      bottomRight: borderRadius),
                  borderSide: BorderSide(color: Colors.red.shade800)),
              isDense: true,
              label: label != null ? Text(label!) : null,
              hintText: hint,
              focusColor: colors.primary,
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              // icon: Icon( Icons.supervised_user_circle_outlined, color: colors.primary, )
            ),
          ),
        ),
      ],
    );
  }
}
