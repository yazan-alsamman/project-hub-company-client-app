import 'package:flutter/material.dart';
class ProjectStatusCard extends StatelessWidget {
  final String title;
  final List<ProjectStatus> statuses;
  const ProjectStatusCard({
    super.key,
    required this.title,
    required this.statuses,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 20),
          ...statuses
              .map((status) => _buildStatusItem(context, status))
              ,
        ],
      ),
    );
  }
  Widget _buildStatusItem(BuildContext context, ProjectStatus status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                status.label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF718096),
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                status.count.toString(),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2D3748),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: status.percentage / 100,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: status.color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class ProjectStatus {
  final String label;
  final int count;
  final double percentage;
  final Color color;
  ProjectStatus({
    required this.label,
    required this.count,
    required this.percentage,
    required this.color,
  });
}
