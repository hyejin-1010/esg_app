import 'package:flutter/material.dart' as material;
import 'package:shadcn_flutter/shadcn_flutter.dart';

class CustomTextFormField extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final TextEditingController? controller;
  final bool? enabled;
  final bool obscureText;
  final String? errorText;
  final void Function(String)? onChanged;
  final void Function()? onFieldSubmitted;

  const CustomTextFormField({
    super.key,
    required this.label,
    this.icon,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.controller,
    this.enabled = true,
    this.obscureText = false,
    this.errorText,
    this.onChanged,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return material.TextFormField(
      validator: validator,
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      enabled: enabled,
      obscureText: obscureText,
      onChanged: onChanged,
      onFieldSubmitted: (_) {
        if (onFieldSubmitted != null) {
          onFieldSubmitted!();
        }
      },
      style: material.Theme.of(context).textTheme.bodyLarge,
      autocorrect: false,
      decoration: material.InputDecoration(
        labelText: label,
        errorText: errorText,
        prefixIcon: icon != null ? Icon(icon, color: Colors.green) : null,
        labelStyle: const TextStyle(color: Colors.black),
        focusedBorder: material.OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(
            width: 1,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        disabledBorder: material.OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(width: 0, color: Colors.green),
        ),
        enabledBorder: const material.OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(width: 0),
        ),
        errorBorder: const material.OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(width: 0, color: Colors.red),
        ),
        focusedErrorBorder: const material.OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(width: 0, color: Colors.red),
        ),
      ),
    );
  }
}
