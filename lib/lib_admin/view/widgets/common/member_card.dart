import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../core/constant/color.dart';
import '../../../core/constant/responsive.dart';
class MemberCard extends StatelessWidget {
  final String name;
  final String position;
  final String status;
  final Color statusColor;
  final IconData? icon;
  final VoidCallback? onTap;
  final String? email;
  final String? phone;
  final String? location;
  final int? activeProjects;
  final VoidCallback? onViewProjects;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  const MemberCard({
    super.key,
    required this.name,
    required this.position,
    required this.status,
    this.statusColor = AppColor.successColor,
    this.icon,
    this.onTap,
    this.email,
    this.phone,
    this.location,
    this.activeProjects,
    this.onViewProjects,
    this.onEdit,
    this.onDelete,
  });
  @override
  Widget build(BuildContext context) {
    final cardContent = GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            Responsive.borderRadius(context, mobile: 12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: _buildCardContent(context),
      ),
    );
    if (onEdit != null || onDelete != null) {
      return Slidable(
        key: Key('member_${name}_$position'),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.3, // Limit swipe to 30% of card width
          children: [
            if (onEdit != null)
              SlidableAction(
                onPressed: (_) => onEdit!(),
                backgroundColor: AppColor.primaryColor,
                foregroundColor: Colors.white,
                icon: Icons.edit,
                label: 'Edit',
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(
                    Responsive.borderRadius(context, mobile: 12),
                  ),
                  bottomRight: Radius.circular(
                    Responsive.borderRadius(context, mobile: 12),
                  ),
                ),
              ),
            if (onDelete != null)
              SlidableAction(
                onPressed: (_) => onDelete!(),
                backgroundColor: AppColor.errorColor,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(
                    Responsive.borderRadius(context, mobile: 12),
                  ),
                  bottomRight: Radius.circular(
                    Responsive.borderRadius(context, mobile: 12),
                  ),
                ),
              ),
          ],
        ),
        child: cardContent,
      );
    }
    return cardContent;
  }
  Widget _buildCardContent(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: Responsive.padding(context),
          child: Row(
            children: [
              Container(
                width: Responsive.size(context, mobile: 40),
                height: Responsive.size(context, mobile: 40),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    Responsive.size(context, mobile: 40),
                  ),
                  gradient: LinearGradient(
                    colors: [AppColor.primaryColor, AppColor.secondaryColor],
                  ),
                ),
                child: Icon(
                  icon ?? Icons.person,
                  color: Colors.white,
                  size: Responsive.size(context, mobile: 40),
                ),
              ),
              SizedBox(width: Responsive.spacing(context, mobile: 16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, mobile: 18),
                        fontWeight: FontWeight.bold,
                        color: AppColor.textColor,
                      ),
                    ),
                    SizedBox(height: Responsive.spacing(context, mobile: 4)),
                    Text(
                      position,
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, mobile: 14),
                        color: AppColor.textSecondaryColor,
                      ),
                    ),
                    SizedBox(height: Responsive.spacing(context, mobile: 8)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.spacing(context, mobile: 8),
                        vertical: Responsive.spacing(context, mobile: 4),
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          Responsive.borderRadius(context, mobile: 12),
                        ),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, mobile: 12),
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColor.textSecondaryColor,
                  size: Responsive.iconSize(context, mobile: 16),
                ),
            ],
          ),
        ),
        if (email != null ||
            phone != null ||
            location != null ||
            activeProjects != null)
          Divider(color: AppColor.borderColor, height: 1, thickness: 1),
        if (email != null ||
            phone != null ||
            location != null ||
            activeProjects != null)
          Padding(
            padding: Responsive.padding(context),
            child: Column(
              children: [
                if (email != null || phone != null || location != null)
                  Column(
                    children: [
                      if (email != null)
                        _buildContactInfo(context, Icons.email, email!),
                      if (phone != null)
                        _buildContactInfo(context, Icons.phone, phone!),
                      if (location != null)
                        _buildContactInfo(
                          context,
                          Icons.location_on,
                          location!,
                        ),
                    ],
                  ),
                if ((email != null || phone != null || location != null) &&
                    activeProjects != null)
                  Divider(
                    color: AppColor.borderColor,
                    height: 20,
                    thickness: 1,
                  ),
                if (activeProjects != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "$activeProjects active projects",
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, mobile: 14),
                          color: AppColor.textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (onViewProjects != null)
                        GestureDetector(
                          onTap: onViewProjects,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: Responsive.spacing(
                                context,
                                mobile: 12,
                              ),
                              vertical: Responsive.spacing(context, mobile: 6),
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.backgroundColor,
                              borderRadius: BorderRadius.circular(
                                Responsive.borderRadius(context, mobile: 6),
                              ),
                              border: Border.all(
                                color: AppColor.borderColor,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              "View",
                              style: TextStyle(
                                fontSize: Responsive.fontSize(
                                  context,
                                  mobile: 12,
                                ),
                                color: AppColor.textColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
      ],
    );
  }
  Widget _buildContactInfo(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.spacing(context, mobile: 8)),
      child: Row(
        children: [
          Icon(
            icon,
            size: Responsive.iconSize(context, mobile: 16),
            color: AppColor.textSecondaryColor,
          ),
          SizedBox(width: Responsive.spacing(context, mobile: 8)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: Responsive.fontSize(context, mobile: 14),
                color: AppColor.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
