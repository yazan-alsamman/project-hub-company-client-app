import 'package:flutter/material.dart';

class UpcomingCard extends StatelessWidget {
  final String title;
  final List<Milestone> milestones;

  const UpcomingCard({
    super.key,
    required this.title,
    required this.milestones,
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
            color: Colors.grey.withValues(alpha: 0.1),
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
          ...milestones.asMap().entries.map((entry) {
            int index = entry.key;
            Milestone milestone = entry.value;
            bool isLast = index == milestones.length - 1;
            return Column(
              children: [
                _buildMilestoneItem(milestone),
                if (!isLast)
                  const Divider(
                    color: Color(0xFFE2E8F0),
                    height: 1,
                    thickness: 1,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMilestoneItem(Milestone milestone) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: milestone.iconColor,
              shape: BoxShape.circle,
            ),
            child: Icon(milestone.icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone.name,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2D3748),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  milestone.date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF718096),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: milestone.statusColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              milestone.status,
              style: TextStyle(
                fontSize: 10,
                color: milestone.statusTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Milestone {
  final String name;
  final String date;
  final String status;
  final IconData icon;
  final Color iconColor;
  final Color statusColor;
  final Color statusTextColor;

  Milestone({
    required this.name,
    required this.date,
    required this.status,
    required this.icon,
    required this.iconColor,
    required this.statusColor,
    required this.statusTextColor,
  });
}

