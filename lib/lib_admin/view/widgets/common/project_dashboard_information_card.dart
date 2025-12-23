import 'package:flutter/material.dart';
import '../../../data/Models/project_model.dart';
class ProjectDashboardInformationCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;
  const ProjectDashboardInformationCard({
    super.key,
    required this.project,
    this.onTap,
    this.onMoreTap,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.folder,
                        color: Color(0xFF1976D2),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            project.company,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: onMoreTap,
                      child: const Icon(
                        Icons.more_vert,
                        color: Color(0xFF666666),
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildStatusChip(project.status),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Progress",
                      style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
                    ),
                    Text(
                      "${project.progress > 1.0 ? project.progress.round() : (project.progress * 100).round()}%",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (project.progress > 1.0 ? project.progress / 100 : project.progress).clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Color(0xFF666666),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatDate(project.endDate),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                    Row(children: _buildTeamAvatars()),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;
    switch (status.toLowerCase()) {
      case 'active':
        backgroundColor = const Color(0xFFFFF3CD);
        textColor = const Color(0xFF856404);
        icon = Icons.access_time;
        break;
      case 'completed':
        backgroundColor = const Color(0xFFD4EDDA);
        textColor = const Color(0xFF155724);
        icon = Icons.check_circle;
        break;
      case 'planned':
        backgroundColor = const Color(0xFFF8D7DA);
        textColor = const Color(0xFF721C24);
        icon = Icons.warning;
        break;
      default:
        backgroundColor = const Color(0xFFF8D7DA);
        textColor = const Color(0xFF721C24);
        icon = Icons.warning;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            _getStatusText(status),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return "In Progress";
      case 'completed':
        return "Completed";
      case 'planned':
        return "Pending";
      default:
        return "Pending";
    }
  }
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return dateString; // Return original string if parsing fails
    }
  }
  List<Widget> _buildTeamAvatars() {
    final avatars = <Widget>[];
    final teamMembersCount = project.teamMembers;
    final mockNames = ['JD', 'SM', 'AR', 'KL', 'RR', 'MC'];
    for (int i = 0; i < teamMembersCount && i < 3; i++) {
      avatars.add(
        Container(
          margin: const EdgeInsets.only(left: 4),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              mockNames[i % mockNames.length],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }
    if (teamMembersCount > 3) {
      avatars.add(
        Container(
          margin: const EdgeInsets.only(left: 4),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              "+${teamMembersCount - 3}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    } else if (teamMembersCount < 3) {
      avatars.add(
        Container(
          margin: const EdgeInsets.only(left: 4),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              "-${3 - teamMembersCount}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }
    return avatars;
  }
}
