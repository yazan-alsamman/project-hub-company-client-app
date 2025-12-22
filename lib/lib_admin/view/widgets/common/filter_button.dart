import 'package:flutter/material.dart';
import '../../../core/constant/color.dart';
class FilterButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isSelected;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;
  const FilterButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isSelected = false,
    this.selectedColor,
    this.unselectedColor,
    this.selectedTextColor,
    this.unselectedTextColor,
  });
  @override
  Widget build(BuildContext context) {
    final selectedColor = this.selectedColor ?? AppColor.primaryColor;
    final unselectedColor = this.unselectedColor ?? AppColor.backgroundColor;
    final selectedTextColor = this.selectedTextColor ?? Colors.white;
    final unselectedTextColor = this.unselectedTextColor ?? AppColor.textColor;
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? selectedColor : unselectedColor,
        foregroundColor: isSelected ? selectedTextColor : unselectedTextColor,
        elevation: isSelected ? 2 : 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
          side: BorderSide(
            color: isSelected ? selectedColor : AppColor.borderColor,
            width: 1,
          ),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}
