import 'package:flutter/material.dart';
import '../../../core/constant/color.dart';
import '../../../core/constant/imageassets.dart';
class BuildHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const BuildHeader({super.key, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    return Column(
      children: [
        Container(
          width: isTablet ? 80 : 60,
          height: isTablet ? 80 : 60,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.asset(
            AppImageAsset.appIcon,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.business_center,
                color: AppColor.primaryColor,
                size: isTablet ? 40 : 30,
              );
            },
          ),
        ),
        SizedBox(height: isTablet ? 32 : 24),
        Text(
          title,
          style: TextStyle(
            fontSize: isTablet ? 32 : 28,
            fontWeight: FontWeight.bold,
            color: AppColor.textColor,
          ),
        ),
        SizedBox(height: isTablet ? 12 : 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: isTablet ? 18 : 16,
            color: AppColor.textSecondaryColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
