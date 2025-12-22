import 'package:flutter/material.dart';
import 'package:project_hub/lib_client/core/constant/responsive.dart';

class ProjectCard extends StatelessWidget {
  final String title;
  final String company;
  final String description;
  final double progress;
  final String startDate;
  final String endDate;
  final int teamMembers;
  final String status;
  final VoidCallback? onTap;

  const ProjectCard({
    super.key,
    required this.title,
    required this.company,
    required this.description,
    required this.progress,
    required this.startDate,
    required this.endDate,
    required this.teamMembers,
    required this.status,
    this.onTap,
  });

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF2196F3);
      case 'completed':
        return const Color(0xFF4CAF50);
      case 'planned':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF2196F3);
    }
  }

  Color _getStatusBackgroundColor() {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFFE0F2F7);
      case 'completed':
        return const Color(0xFFE8F5E8);
      case 'planned':
        return const Color(0xFFFFF3E0);
      default:
        return const Color(0xFFE0F2F7);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.spacing(context, mobile: 16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          Responsive.borderRadius(context, mobile: 12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            Responsive.borderRadius(context, mobile: 12),
          ),
          child: Padding(
            padding: Responsive.padding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: Responsive.size(context, mobile: 40),
                      height: Responsive.size(context, mobile: 40),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8E8FF),
                        borderRadius: BorderRadius.circular(
                          Responsive.borderRadius(context, mobile: 8),
                        ),
                      ),
                      child: Icon(
                        Icons.folder_outlined,
                        color: const Color(0xFF4285F4),
                        size: Responsive.iconSize(context, mobile: 20),
                      ),
                    ),
                    SizedBox(width: Responsive.spacing(context, mobile: 12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: Responsive.fontSize(
                                context,
                                mobile: 16,
                              ),
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF333333),
                            ),
                          ),
                          SizedBox(
                            height: Responsive.spacing(context, mobile: 2),
                          ),
                          Text(
                            company,
                            style: TextStyle(
                              fontSize: Responsive.fontSize(
                                context,
                                mobile: 14,
                              ),
                              color: const Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.spacing(context, mobile: 16)),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, mobile: 14),
                    color: const Color(0xFF666666),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: Responsive.spacing(context, mobile: 20)),
                Row(
                  children: [
                    Text(
                      'Progress',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, mobile: 14),
                        color: const Color(0xFF666666),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${(progress * 100).round()}%',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, mobile: 14),
                        color: const Color(0xFF333333),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.spacing(context, mobile: 8)),
                Container(
                  height: Responsive.size(context, mobile: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      Responsive.borderRadius(context, mobile: 3),
                    ),
                    color: const Color(0xFFE0E0E0),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          Responsive.borderRadius(context, mobile: 3),
                        ),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4285F4), Color(0xFF8A2BE2)],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: Responsive.spacing(context, mobile: 20)),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: Responsive.iconSize(context, mobile: 16),
                      color: const Color(0xFF666666),
                    ),
                    SizedBox(width: Responsive.spacing(context, mobile: 8)),
                    Flexible(
                      child: Text(
                        '$startDate - $endDate',
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, mobile: 14),
                          color: const Color(0xFF666666),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.spacing(context, mobile: 8)),
                Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: Responsive.iconSize(context, mobile: 16),
                      color: const Color(0xFF666666),
                    ),
                    SizedBox(width: Responsive.spacing(context, mobile: 8)),
                    Text(
                      '$teamMembers team members',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, mobile: 14),
                        color: const Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.spacing(context, mobile: 20)),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.spacing(context, mobile: 12),
                        vertical: Responsive.spacing(context, mobile: 6),
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusBackgroundColor(),
                        borderRadius: BorderRadius.circular(
                          Responsive.borderRadius(context, mobile: 16),
                        ),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, mobile: 12),
                          color: _getStatusColor(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: Responsive.iconSize(context, mobile: 16),
                      color: _getStatusColor(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
