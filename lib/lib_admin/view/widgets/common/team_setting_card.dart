import 'package:flutter/material.dart';
import '../../../core/constant/color.dart';
class TeamSettingCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final List<TeamItem> items;
  const TeamSettingCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.items,
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
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == items.length - 1 ? 0 : 12,
              ),
              child: _buildSettingOption(
                title: item.title,
                description: item.description,
                onTap: item.onTap,
              ),
            );
          }),
        ],
      ),
    );
  }
  Widget _buildSettingOption({
    required String title,
    required String description,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
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
            Icon(
              Icons.arrow_forward_ios,
              color: AppColor.textSecondaryColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
class TeamItem {
  final String title;
  final String description;
  final VoidCallback? onTap;
  TeamItem({required this.title, required this.description, this.onTap});
}
