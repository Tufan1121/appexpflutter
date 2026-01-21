import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactive_forms/reactive_forms.dart';

class CustomReactiveTextField extends StatefulWidget {
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
  State<CustomReactiveTextField> createState() => _CustomReactiveTextFieldState();
}

class _CustomReactiveTextFieldState extends State<CustomReactiveTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final border = OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.transparent),
        borderRadius: BorderRadius.circular(40));

    const borderRadius = Radius.circular(15);

    return Stack(
      children: [
        AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 55,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                    topLeft: borderRadius,
                    bottomLeft: borderRadius,
                    bottomRight: borderRadius),
                boxShadow: [
                  BoxShadow(
                      color: _hasFocus 
                          ? colors.primary.withOpacity(0.2) 
                          : Colors.black.withOpacity(0.06),
                      blurRadius: _hasFocus ? 16 : 10,
                      offset: const Offset(0, 5))
                ])),
        SizedBox(
          child: ReactiveTextField<String>(
            focusNode: _focusNode,
            readOnly: widget.readOnly,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            formControlName: widget.formControlName,
            inputFormatters: widget.inputFormatters,
            onSubmitted: widget.onSubmitted,
            autocorrect: false,
            style: const TextStyle(fontSize: 20, color: Colors.black54),
            validationMessages: widget.validationMessages,
            decoration: InputDecoration(
                hintStyle: widget.hintStyle,
                floatingLabelStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
                enabledBorder: border,
                focusedBorder: border,
                errorStyle: widget.errorStyle,
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
                label: widget.label != null ? Text(widget.label!) : null,
                hintText: widget.hint,
                focusColor: colors.primary,
                prefixIcon: widget.prefixIcon,
                suffixIcon: widget.suffixIcon,
                border: InputBorder.none,
                suffixText: widget.suffixText
                // icon: Icon( Icons.supervised_user_circle_outlined, color: colors.primary, )
                ),
          ),
        ),
      ],
    );
  }
}
