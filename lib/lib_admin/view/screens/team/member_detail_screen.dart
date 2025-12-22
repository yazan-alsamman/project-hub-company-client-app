import 'package:flutter/material.dart';
import '../../../core/constant/color.dart';
import '../../../data/static/team_members_data.dart';
import '../../widgets/common/custom_app_bar.dart';
class MemberDetailScreen extends StatelessWidget {
  final TeamMember member;
  const MemberDetailScreen({super.key, required this.member});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        showBackButton: true,
        title: member.name,
        showSearch: false,
        showNotifications: false,
        showUserProfile: false,
        showHamburgerMenu: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColor.primaryColor.withOpacity(0.1),
                    AppColor.secondaryColor.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(60),
                        gradient: LinearGradient(
                          colors: [
                            AppColor.primaryColor,
                            AppColor.secondaryColor,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.primaryColor.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(member.icon, color: Colors.white, size: 60),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      member.name,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColor.textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      member.position,
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColor.textSecondaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: member.statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: member.statusColor, width: 1),
                      ),
                      child: Text(
                        member.status,
                        style: TextStyle(
                          fontSize: 14,
                          color: member.statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoSection("Basic Information", Icons.info_outline, [
                    if (member.department != null)
                      _buildInfoRow("Department", member.department!),
                    if (member.joinDate != null)
                      _buildInfoRow("Join Date", member.joinDate!),
                    if (member.location != null)
                      _buildInfoRow("Location", member.location!),
                    if (member.rating != null)
                      _buildInfoRow("Rating", "${member.rating}/5.0 ⭐"),
                  ]),
                  const SizedBox(height: 24),
                  _buildInfoSection("Contact Information", Icons.contact_phone, [
                    if (member.email != null)
                      _buildContactRow(Icons.email, "Email", member.email!),
                    if (member.phone != null)
                      _buildContactRow(Icons.phone, "Phone", member.phone!),
                    if (member.linkedin != null)
                      _buildContactRow(
                        Icons
                            .link, // Use a generic "link" icon as LinkedIn isn't available in Icons
                        "LinkedIn",
                        member.linkedin!,
                      ),
                    if (member.github != null)
                      _buildContactRow(Icons.code, "GitHub", member.github!),
                  ]),
                  const SizedBox(height: 24),
                  _buildInfoSection("Project Statistics", Icons.analytics, [
                    if (member.activeProjects != null)
                      _buildInfoRow(
                        "Active Projects",
                        "${member.activeProjects}",
                      ),
                    if (member.completedProjects != null)
                      _buildInfoRow(
                        "Completed Projects",
                        "${member.completedProjects}",
                      ),
                  ]),
                  const SizedBox(height: 24),
                  if (member.bio != null)
                    _buildInfoSection("About", Icons.person_outline, [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
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
                        child: Text(
                          member.bio!,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColor.textColor,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ]),
                  const SizedBox(height: 24),
                  if (member.skills != null && member.skills!.isNotEmpty)
                    _buildInfoSection("Skills", Icons.star_outline, [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: member.skills!
                            .map(
                              (skill) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColor.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColor.primaryColor.withOpacity(
                                      0.3,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  skill,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColor.primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ]),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
  Widget _buildInfoSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColor.primaryColor, size: 24),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColor.textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColor.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: AppColor.textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildContactRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColor.primaryColor),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColor.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: AppColor.textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
  