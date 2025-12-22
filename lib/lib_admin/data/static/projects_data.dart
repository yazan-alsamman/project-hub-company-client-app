import '../Models/project_model.dart';
class ProjectsData {
  static List<ProjectModel> projects = [
    ProjectModel(
      id: '1',
      title: 'E-Commerce Platform',
      company: 'Acme Corp',
      description: 'Full-stack e-commerce solution with payment integration',
      progress: 0.65,
      startDate: '2024-10-01',
      endDate: '2024-12-15',
      teamMembers: 4,
      status: 'active',
    ),
    ProjectModel(
      id: '2',
      title: 'Mobile App Redesign',
      company: 'TechStart Inc',
      description: 'Complete redesign of mobile application with modern UI',
      progress: 1.0,
      startDate: '2024-09-01',
      endDate: '2024-11-30',
      teamMembers: 3,
      status: 'completed',
    ),
    ProjectModel(
      id: '3',
      title: 'Dashboard System',
      company: 'DataFlow Ltd',
      description: 'Analytics dashboard for data visualization and reporting',
      progress: 0.45,
      startDate: '2024-11-01',
      endDate: '2025-01-20',
      teamMembers: 5,
      status: 'active',
    ),
    ProjectModel(
      id: '4',
      title: 'API Integration',
      company: 'CloudBase',
      description: 'Third-party API integration for payment processing',
      progress: 0.15,
      startDate: '2024-12-01',
      endDate: '2024-12-31',
      teamMembers: 2,
      status: 'planned',
    ),
  ];
  static List<ProjectModel> getProjectsByStatus(String status) {
    if (status == 'All') {
      return projects;
    }
    String lowerStatus = status.toLowerCase();
    return projects.where((project) => project.status == lowerStatus).toList();
  }
}
