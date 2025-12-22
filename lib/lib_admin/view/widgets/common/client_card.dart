import 'package:flutter/material.dart';
import '../../../core/constant/color.dart';
import '../../../core/constant/responsive.dart';
import '../../../data/Models/client_model.dart';

class ClientCard extends StatelessWidget {
  final ClientModel client;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ClientCard({
    super.key,
    required this.client,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(
          bottom: Responsive.spacing(context, mobile: 16),
        ),
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
        child: Padding(
          padding: EdgeInsets.all(Responsive.spacing(context, mobile: 16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(
                      Icons.person,
                      color: AppColor.primaryColor,
                      size: 28,
                    ),
                  ),
                  SizedBox(width: Responsive.spacing(context, mobile: 12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          client.username,
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, mobile: 18),
                            fontWeight: FontWeight.bold,
                            color: AppColor.textColor,
                          ),
                        ),
                        SizedBox(
                          height: Responsive.spacing(context, mobile: 4),
                        ),
                        Text(
                          client.email,
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, mobile: 14),
                            color: AppColor.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.spacing(context, mobile: 12),
                      vertical: Responsive.spacing(context, mobile: 6),
                    ),
                    decoration: BoxDecoration(
                      color: client.isActive
                          ? AppColor.successColor.withOpacity(0.1)
                          : AppColor.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      client.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, mobile: 12),
                        fontWeight: FontWeight.w500,
                        color: client.isActive
                            ? AppColor.successColor
                            : AppColor.errorColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: Responsive.spacing(context, mobile: 16)),
              Divider(color: AppColor.borderColor, height: 1),
              SizedBox(height: Responsive.spacing(context, mobile: 12)),
              Row(
                children: [
                  _buildInfoItem(
                    context,
                    icon: Icons.business,
                    label: 'Company',
                    value: client.companyId?['name']?.toString() ?? 'N/A',
                  ),
                  SizedBox(width: Responsive.spacing(context, mobile: 16)),
                  _buildInfoItem(
                    context,
                    icon: Icons.badge,
                    label: 'Role',
                    value: client.role?['name']?.toString() ?? 'N/A',
                  ),
                ],
              ),
              if (client.createdAt != null) ...[
                SizedBox(height: Responsive.spacing(context, mobile: 12)),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppColor.textSecondaryColor,
                    ),
                    SizedBox(width: Responsive.spacing(context, mobile: 8)),
                    Text(
                      'Created: ${_formatDate(client.createdAt!)}',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, mobile: 12),
                        color: AppColor.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColor.textSecondaryColor,
          ),
          SizedBox(width: Responsive.spacing(context, mobile: 8)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, mobile: 11),
                    color: AppColor.textSecondaryColor,
                  ),
                ),
                SizedBox(height: Responsive.spacing(context, mobile: 2)),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, mobile: 13),
                    fontWeight: FontWeight.w500,
                    color: AppColor.textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}

