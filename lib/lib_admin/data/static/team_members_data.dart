import 'package:flutter/material.dart';
import '../../core/constant/color.dart';
class TeamMember {
  final String name;
  final String position;
  final String status;
  final Color statusColor;
  final IconData icon;
  final String? email;
  final String? phone;
  final String? location;
  final int? activeProjects;
  final String? department;
  final String? joinDate;
  final String? bio;
  final List<String>? skills;
  final String? linkedin;
  final String? github;
  final int? completedProjects;
  final double? rating;
  final String? id; // Add ID field for API compatibility
  TeamMember({
    required this.name,
    required this.position,
    required this.status,
    required this.statusColor,
    required this.icon,
    this.email,
    this.phone,
    this.location,
    this.activeProjects,
    this.department,
    this.joinDate,
    this.bio,
    this.skills,
    this.linkedin,
    this.github,
    this.completedProjects,
    this.rating,
    this.id,
  });
}
List<TeamMember> teamMembers = [
  TeamMember(
    name: "John Doe",
    position: "Project Manager",
    status: "Active",
    statusColor: AppColor.successColor,
    icon: Icons.person,
    email: "john@acme.com",
    phone: "+1 (555) 123-4567",
    location: "San Francisco, CA",
    activeProjects: 3,
    department: "Engineering",
    joinDate: "January 2022",
    bio:
        "Experienced project manager with 8+ years in software development. Passionate about delivering high-quality products and leading cross-functional teams.",
    skills: [
      "Project Management",
      "Agile",
      "Scrum",
      "Team Leadership",
      "Risk Management",
    ],
    linkedin: "linkedin.com/in/johndoe",
    github: "github.com/johndoe",
    completedProjects: 15,
    rating: 4.8,
  ),
  TeamMember(
    name: "Sarah Wilson",
    position: "UI/UX Designer",
    status: "Active",
    statusColor: AppColor.successColor,
    icon: Icons.design_services,
    email: "sarah@acme.com",
    phone: "+1 (555) 234-5678",
    location: "New York, NY",
    activeProjects: 2,
  ),
  TeamMember(
    name: "Mike Johnson",
    position: "Backend Developer",
    status: "Busy",
    statusColor: AppColor.warningColor,
    icon: Icons.code,
    email: "mike@acme.com",
    phone: "+1 (555) 345-6789",
    location: "Seattle, WA",
    activeProjects: 4,
  ),
  TeamMember(
    name: "Emily Davis",
    position: "Frontend Developer",
    status: "Active",
    statusColor: AppColor.successColor,
    icon: Icons.web,
    email: "emily@acme.com",
    phone: "+1 (555) 456-7890",
    location: "Austin, TX",
    activeProjects: 2,
  ),
  TeamMember(
    name: "David Brown",
    position: "DevOps Engineer",
    status: "Away",
    statusColor: AppColor.textSecondaryColor,
    icon: Icons.cloud,
    email: "david@acme.com",
    phone: "+1 (555) 567-8901",
    location: "Denver, CO",
    activeProjects: 1,
  ),
  TeamMember(
    name: "Lisa Garcia",
    position: "QA Tester",
    status: "Active",
    statusColor: AppColor.successColor,
    icon: Icons.bug_report,
    email: "lisa@acme.com",
    phone: "+1 (555) 678-9012",
    location: "Miami, FL",
    activeProjects: 3,
  ),
  TeamMember(
    name: "Alex Chen",
    position: "Data Analyst",
    status: "Busy",
    statusColor: AppColor.warningColor,
    icon: Icons.analytics,
    email: "alex@acme.com",
    phone: "+1 (555) 789-0123",
    location: "Boston, MA",
    activeProjects: 2,
  ),
  TeamMember(
    name: "Maria Rodriguez",
    position: "Product Owner",
    status: "Active",
    statusColor: AppColor.successColor,
    icon: Icons.business,
    email: "maria@acme.com",
    phone: "+1 (555) 890-1234",
    location: "Los Angeles, CA",
    activeProjects: 5,
  ),
];
