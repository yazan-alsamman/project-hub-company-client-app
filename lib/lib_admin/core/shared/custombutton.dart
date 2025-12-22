import 'package:flutter/material.dart';
import '../constant/color.dart';
class CustomBotton extends StatelessWidget {
  final String text;
  final void Function()? onPressed;
  const CustomBotton({super.key, required this.text, this.onPressed});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10, right: 20, left: 20),
      child: MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(vertical: 5),
        onPressed: onPressed,
        color: AppColor.primaryColor,
        textColor: Colors.white,
        child: Text(text),
      ),
    );
  }
}
