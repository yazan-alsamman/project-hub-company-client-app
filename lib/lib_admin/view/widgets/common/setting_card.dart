import 'package:flutter/material.dart';
import '../../../core/constant/color.dart';
class SettingCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String settingTitle;
  final String description;
  final bool value;
  final ValueChanged<bool>? onChanged;
  const SettingCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.settingTitle,
    required this.description,
    this.value = false,
    this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(color: AppColor.borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      settingTitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColor.textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColor.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Checkbox(
                value: value,
                onChanged: onChanged != null
                    ? (bool? newValue) => onChanged!(newValue ?? false)
                    : null,
                activeColor: AppColor.gradientMiddle,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
