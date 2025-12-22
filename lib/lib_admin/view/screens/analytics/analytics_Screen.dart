import 'package:flutter/material.dart';
import '../../../controller/common/customDrawer_controller.dart';
import 'package:get/get.dart';
import '../../../core/constant/color.dart';
import '../../../controller/common/analytics_controller.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_drawer.dart';
import '../../widgets/common/header.dart';
import '../../widgets/common/analytics_card.dart';
import '../../widgets/common/project_status_card.dart';
import '../../widgets/common/productivity_card.dart';
import '../../widgets/common/upcoming_card.dart';
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final CustomDrawerControllerImp customDrawerController =
        Get.find<CustomDrawerControllerImp>();
    return Scaffold(
      drawer: CustomDrawer(
        onItemTap: (item) {
          customDrawerController.onMenuItemTap(item);
        },
      ),
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: AppColor.backgroundColor,
              child: GetBuilder<AnalyticsControllerImp>(
                builder: (controller) => Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Header(
                        title: "Analytics",
                        subtitle: "Track your project metrics and performance",
                        haveButton: false,
                      ),
                      const SizedBox(height: 20),
                      AnalyticsCard(
                        title: "On-Time Delivery",
                        value: "94%",
                        subtitle: "+2.5% from last month",
                        icon: Icons.check_circle_outline,
                        gradientColors: [
                          const Color(0xFF4CAF50),
                          const Color(0xFF2E7D32),
                        ],
                        iconBackgroundColor: const Color(0xFF66BB6A),
                      ),
                      AnalyticsCard(
                        title: "Project Completion",
                        value: "87%",
                        subtitle: "+5.2% from last quarter",
                        icon: Icons.trending_up,
                        gradientColors: [
                          const Color(0xFF2196F3),
                          const Color(0xFF1565C0),
                        ],
                        iconBackgroundColor: const Color(0xFF42A5F5),
                      ),
                      AnalyticsCard(
                        title: "Team Productivity",
                        value: "92%",
                        subtitle: "+3.1% from last week",
                        icon: Icons.people,
                        gradientColors: [
                          const Color(0xFF9C27B0),
                          const Color(0xFF6A1B9A),
                        ],
                        iconBackgroundColor: const Color(0xFFBA68C8),
                      ),
                      AnalyticsCard(
                        title: "Budget Utilization",
                        value: "78%",
                        subtitle: "-1.2% from last month",
                        icon: Icons.account_balance_wallet,
                        gradientColors: [
                          const Color(0xFFFF9800),
                          const Color(0xFFE65100),
                        ],
                        iconBackgroundColor: const Color(0xFFFFB74D),
                      ),
                      AnalyticsCard(
                        title: "Client Satisfaction",
                        value: "96%",
                        subtitle: "+4.8% from last quarter",
                        icon: Icons.star,
                        gradientColors: [
                          const Color(0xFF4CAF50),
                          const Color(0xFF1B5E20),
                        ],
                        iconBackgroundColor: const Color(0xFF81C784),
                      ),
                      AnalyticsCard(
                        title: "Code Quality",
                        value: "89%",
                        subtitle: "+2.3% from last sprint",
                        icon: Icons.code,
                        gradientColors: [
                          const Color(0xFF607D8B),
                          const Color(0xFF37474F),
                        ],
                        iconBackgroundColor: const Color(0xFF90A4AE),
                      ),
                      const SizedBox(height: 30),
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        child: ProjectStatusCard(
                          title: "Projects by Status",
                          statuses: [
                            ProjectStatus(
                              label: "Completed",
                              count: 8,
                              percentage: 32.0,
                              color: const Color(0xFF4CAF50),
                            ),
                            ProjectStatus(
                              label: "In Progress",
                              count: 12,
                              percentage: 48.0,
                              color: const Color(0xFF2196F3),
                            ),
                            ProjectStatus(
                              label: "On Hold",
                              count: 3,
                              percentage: 12.0,
                              color: const Color(0xFFFF9800),
                            ),
                            ProjectStatus(
                              label: "Not Started",
                              count: 2,
                              percentage: 8.0,
                              color: const Color(0xFF9E9E9E),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        child: ProductivityCard(
                          title: "Team Productivity",
                          teamMembers: [
                            TeamMember(
                              name: "John Dev",
                              score: "18/24",
                              percentage: 75.0,
                            ),
                            TeamMember(
                              name: "Sarah Design",
                              score: "14/16",
                              percentage: 87.5,
                            ),
                            TeamMember(
                              name: "Alex Backend",
                              score: "22/28",
                              percentage: 78.5,
                            ),
                            TeamMember(
                              name: "Lisa QA",
                              score: "15/20",
                              percentage: 75.0,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        child: UpcomingCard(
                          title: "Upcoming Milestones",
                          milestones: [
                            Milestone(
                              name: "E-Commerce Platform Launch",
                              date: "Dec 15, 2024",
                              status: "critical",
                              icon: Icons.warning,
                              iconColor: const Color(0xFFE53E3E),
                              statusColor: const Color(0xFFFED7D7),
                              statusTextColor: const Color(0xFFC53030),
                            ),
                            Milestone(
                              name: "API Integration Completion",
                              date: "Dec 31, 2024",
                              status: "on-track",
                              icon: Icons.check,
                              iconColor: const Color(0xFF38A169),
                              statusColor: const Color(0xFFC6F6D5),
                              statusTextColor: const Color(0xFF2F855A),
                            ),
                            Milestone(
                              name: "Dashboard System Release",
                              date: "Jan 20, 2025",
                              status: "on-track",
                              icon: Icons.check,
                              iconColor: const Color(0xFF38A169),
                              statusColor: const Color(0xFFC6F6D5),
                              statusTextColor: const Color(0xFF2F855A),
                            ),
                            Milestone(
                              name: "Blockchain Integration Launch",
                              date: "Feb 28, 2025",
                              status: "planning",
                              icon: Icons.check,
                              iconColor: const Color(0xFF38A169),
                              statusColor: const Color(0xFFBEE3F8),
                              statusTextColor: const Color(0xFF2B6CB0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
