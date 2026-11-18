import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/radii.dart';

class FitTextField extends StatelessWidget {
  const FitTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.errorText,
    this.suffixIcon,
  });

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: FitColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
        ],
        SizedBox(
          height: 44,
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: FitColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: FitColors.textSecondary,
              ),
              filled: true,
              fillColor: FitColors.inputBackground,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              suffixIcon: suffixIcon,
              border: OutlineInputBorder(
                borderRadius: FitRadii.inputBorder,
                borderSide: BorderSide(
                  color: errorText != null ? FitColors.error : FitColors.border,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: FitRadii.inputBorder,
                borderSide: BorderSide(
                  color: errorText != null ? FitColors.error : FitColors.border,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: FitRadii.inputBorder,
                borderSide: BorderSide(color: FitColors.primary, width: 2),
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: FitColors.error,
            ),
          ),
        ],
      ],
    );
  }
}
