import 'package:flutter/material.dart';
import '../../../core/constant/color.dart';
class MainButton extends StatelessWidget {
  final void Function()? onPressed;
  final String text;
  final IconData? icon;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  const MainButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.width,
    this.height,
    this.padding,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColor.gradientStart,
              AppColor.gradientMiddle,
              AppColor.gradientEnd,
            ],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: MaterialButton(
          onPressed: onPressed != null
              ? () {
                  print('🔵 MainButton onPressed called');
                  debugPrint('🔵 MainButton onPressed called');
                  onPressed!();
                }
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: padding,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white),
                SizedBox(width: 8),
              ],
              Text(text, style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
