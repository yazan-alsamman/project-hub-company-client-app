import 'package:flutter/material.dart';
import '../../../core/constant/color.dart';
import '../../../core/constant/responsive.dart';
import 'main_button.dart';
class Header extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? buttonText;
  final bool haveButton;
  final IconData? buttonIcon;
  final void Function()? onPressed;
  const Header({
    super.key,
    required this.title,
    required this.subtitle,
    this.haveButton = true,
    this.buttonText,
    this.buttonIcon,
    this.onPressed,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: Responsive.fontSize(context, mobile: 25),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: Responsive.spacing(context, mobile: 4)),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: Responsive.fontSize(context, mobile: 14),
            color: AppColor.textSecondaryColor,
          ),
        ),
        SizedBox(height: Responsive.spacing(context, mobile: 20)),
        haveButton
            ? MainButton(
                onPressed: onPressed,
                text: buttonText!,
                icon: buttonIcon!,
                width: double.infinity,
                height: Responsive.size(context, mobile: 50),
              )
            : Container(),
        SizedBox(height: Responsive.spacing(context, mobile: 30)),
      ],
    );
  }
}
