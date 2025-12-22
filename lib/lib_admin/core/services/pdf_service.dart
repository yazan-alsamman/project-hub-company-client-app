import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/Models/project_model.dart';
import '../../data/static/team_members_data.dart';
class PDFService {
  static Future<File?> generateProjectPDF(ProjectModel project) async {
    try {
      debugPrint('=== STARTING PDF GENERATION ===');
      debugPrint('Project: ${project.title}');
      debugPrint('Team members required: ${project.teamMembers}');
      debugPrint('Team members length: ${teamMembers.length}');
      if (teamMembers.isNotEmpty) {
        debugPrint('First team member: ${teamMembers.first.name}');
        for (int i = 0; i < teamMembers.length && i < 3; i++) {
          debugPrint(
            'Team member $i: ${teamMembers[i].name} - ${teamMembers[i].status}',
          );
        }
      } else {
        debugPrint('ERROR: teamMembers is empty!');
      }
      if (Platform.isAndroid) {
        await _requestStoragePermissions();
      }
      final pdf = pw.Document();
      debugPrint('PDF document created');
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(30),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeader(project),
                pw.SizedBox(height: 25),
                _buildProjectOverview(project),
                pw.SizedBox(height: 20),
                _buildProgressSection(project),
                pw.SizedBox(height: 20),
                _buildProjectDetails(project),
                pw.SizedBox(height: 20),
                _buildTeamInformation(project),
                pw.SizedBox(height: 20),
                _buildFooter(),
              ],
            );
          },
        ),
      );
      debugPrint('PDF page added');
      Directory output;
      try {
        output = await getApplicationDocumentsDirectory();
        debugPrint('Using application documents directory: ${output.path}');
        if (!await output.exists()) {
          await output.create(recursive: true);
        }
      } catch (e) {
        debugPrint('Failed to get application documents directory: $e');
        try {
          if (Platform.isAndroid) {
            final externalDir = await getExternalStorageDirectory();
            if (externalDir != null) {
              output = externalDir;
              debugPrint('Using external storage directory: ${output.path}');
            } else {
              throw Exception('External storage directory is null');
            }
          } else {
            throw Exception('Not Android platform');
          }
        } catch (e2) {
          debugPrint('Failed to get external storage directory: $e2');
          try {
            if (Platform.isAndroid) {
              final downloadsDir = await getDownloadsDirectory();
              if (downloadsDir != null) {
                output = downloadsDir;
                debugPrint('Using downloads directory: ${output.path}');
              } else {
                throw Exception('Downloads directory is null');
              }
            } else {
              throw Exception('Not Android platform');
            }
          } catch (e3) {
            debugPrint('Failed to get downloads directory: $e3');
            output = Directory.systemTemp;
            debugPrint('Using system temp directory: ${output.path}');
            if (!await output.exists()) {
              await output.create(recursive: true);
            }
          }
        }
      }
      final safeFileName = project.id
          .replaceAll(RegExp(r'[^\w\s-]'), '_')
          .replaceAll(RegExp(r'[-\s]+'), '_');
      final fileName =
          'project_${safeFileName}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${output.path}/$fileName');
      debugPrint('Saving PDF to: ${file.path}');
      final pdfBytes = await pdf.save();
      await file.writeAsBytes(pdfBytes, flush: true);
      if (await file.exists()) {
        final fileSize = await file.length();
        debugPrint('PDF saved successfully. File size: $fileSize bytes');
        return file;
      } else {
        throw Exception('File was not created successfully');
      }
    } catch (e, stackTrace) {
      debugPrint('Error generating PDF: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }
  static Future<void> _requestStoragePermissions() async {
    if (!Platform.isAndroid) return;
    try {
      final status = await Permission.storage.request();
      if (status.isGranted) {
        debugPrint('Storage permission granted');
      } else if (status.isPermanentlyDenied) {
        debugPrint('Storage permission permanently denied');
      } else {
        debugPrint('Storage permission denied: $status');
        await Permission.manageExternalStorage.request();
      }
    } catch (e) {
      debugPrint('Error requesting storage permissions: $e');
    }
  }
  static pw.Widget _buildHeader(ProjectModel project) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(25),
      decoration: pw.BoxDecoration(
        gradient: const pw.LinearGradient(
          colors: [PdfColors.blue600, PdfColors.purple600],
          begin: pw.Alignment.topLeft,
          end: pw.Alignment.bottomRight,
        ),
        borderRadius: pw.BorderRadius.circular(15),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(
                width: 60,
                height: 60,
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Center(
                  child: pw.Text(
                    'P',
                    style: pw.TextStyle(
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue600,
                    ),
                  ),
                ),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'PROJECT REPORT',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      project.title,
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      project.company,
                      style: pw.TextStyle(
                        fontSize: 16,
                        color: PdfColors.blue100,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: pw.BoxDecoration(
                  color: _getStatusColor(project.status),
                  borderRadius: pw.BorderRadius.circular(20),
                ),
                child: pw.Text(
                  project.status.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  static pw.Widget _buildProjectOverview(ProjectModel project) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: PdfColors.grey200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Project Overview',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
          pw.SizedBox(height: 15),
          pw.Text(
            project.description,
            style: pw.TextStyle(
              fontSize: 14,
              color: PdfColors.grey700,
              lineSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
  static pw.Widget _buildProgressSection(ProjectModel project) {
    final progress = (project.progress * 100).round();
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: PdfColors.grey200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Project Progress',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey800,
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: pw.BorderRadius.circular(15),
                ),
                child: pw.Text(
                  '$progress%',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue700,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 15),
          pw.Container(
            height: 12,
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Stack(
              children: [
                pw.Container(
                  width: (progress / 100) * 400, // عرض نسبي
                  height: 12,
                  decoration: pw.BoxDecoration(
                    gradient: const pw.LinearGradient(
                      colors: [PdfColors.blue400, PdfColors.purple400],
                    ),
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  static pw.Widget _buildProjectDetails(ProjectModel project) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: PdfColors.grey200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Project Details',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildDetailItem('Start Date', project.startDate, '📅'),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: _buildDetailItem('End Date', project.endDate, '📅'),
              ),
            ],
          ),
          pw.SizedBox(height: 15),
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildDetailItem(
                  'Duration',
                  _calculateDuration(project),
                  '⏱️',
                ),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: _buildDetailItem(
                  'Team Size',
                  '${project.teamMembers} members',
                  '👥',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  static pw.Widget _buildTeamInformation(ProjectModel project) {
    debugPrint('=== BUILDING TEAM INFORMATION ===');
    debugPrint('Project: ${project.title}');
    debugPrint('Required team members: ${project.teamMembers}');
    if (teamMembers.isEmpty) {
      debugPrint('ERROR: teamMembers is empty!');
      return pw.Container(
        padding: const pw.EdgeInsets.all(20),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          borderRadius: pw.BorderRadius.circular(12),
          border: pw.Border.all(color: PdfColors.grey200),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Team Members',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey800,
              ),
            ),
            pw.SizedBox(height: 15),
            pw.Text(
              'No team members available',
              style: pw.TextStyle(fontSize: 14, color: PdfColors.grey600),
            ),
          ],
        ),
      );
    }
    final List<Map<String, String>> teamMembersList = teamMembers
        .map(
          (member) => {
            'name': member.name,
            'position': member.position,
            'status': member.status,
            'email': member.email ?? '',
          },
        )
        .toList();
    var activeTeamMembers = teamMembersList
        .where(
          (member) =>
              member['status'] == 'Active' || member['status'] == 'Busy',
        )
        .take(project.teamMembers)
        .toList();
    if (activeTeamMembers.isEmpty) {
      activeTeamMembers = teamMembersList.take(project.teamMembers).toList();
    }
    debugPrint('Available team members: ${teamMembersList.length}');
    debugPrint('Active team members found: ${activeTeamMembers.length}');
    for (var member in activeTeamMembers) {
      debugPrint(
        'Team member: ${member['name']} - ${member['position']} - ${member['status']}',
      );
    }
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: PdfColors.grey200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Team Members',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
          pw.SizedBox(height: 15),
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildTeamStat(
                  'Total Members',
                  '${project.teamMembers}',
                  '👥',
                ),
              ),
              pw.SizedBox(width: 15),
              pw.Expanded(
                child: _buildTeamStat(
                  'Active Members',
                  '${activeTeamMembers.length}',
                  '✅',
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Team Members Details:',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
          pw.SizedBox(height: 12),
          ...activeTeamMembers.map(
            (member) => _buildTeamMemberCardFromMap(member),
          ),
          if (activeTeamMembers.length < project.teamMembers)
            pw.Container(
              margin: const pw.EdgeInsets.only(top: 10),
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.orange50,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: PdfColors.orange200),
              ),
              child: pw.Row(
                children: [
                  pw.Text(
                    'i',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.orange600,
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Expanded(
                    child: pw.Text(
                      'Additional team members will be assigned as the project progresses.',
                      style: pw.TextStyle(
                        fontSize: 11,
                        color: PdfColors.orange700,
                        fontStyle: pw.FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  static pw.Widget _buildDetailItem(String label, String value, String icon) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Text(
                _getIconText(icon),
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey600,
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Text(
                label,
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
        ],
      ),
    );
  }
  static pw.Widget _buildFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        gradient: const pw.LinearGradient(
          colors: [PdfColors.grey100, PdfColors.grey200],
          begin: pw.Alignment.topLeft,
          end: pw.Alignment.bottomRight,
        ),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Generated by ProjectHub',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'Professional Project Management',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Generated on: ${DateTime.now().toString().split(' ')[0]}',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'Version 1.0',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
              ),
            ],
          ),
        ],
      ),
    );
  }
  static PdfColor _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return PdfColors.green600;
      case 'completed':
        return PdfColors.blue600;
      case 'planned':
        return PdfColors.orange600;
      default:
        return PdfColors.blue600;
    }
  }
  static String _calculateDuration(ProjectModel project) {
    return '3 months';
  }
  static String _getIconText(String icon) {
    switch (icon) {
      case '👥':
        return 'TEAM';
      case '✅':
        return 'OK';
      case '📅':
        return 'DATE';
      case '⏱️':
        return 'TIME';
      default:
        return icon;
    }
  }
  static pw.Widget _buildTeamStat(String label, String value, String icon) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            _getIconText(icon),
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue600,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue700,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            label,
            style: pw.TextStyle(fontSize: 10, color: PdfColors.blue600),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }
  static pw.Widget _buildTeamMemberCardFromMap(Map<String, String> member) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: PdfColors.grey200),
      ),
      child: pw.Row(
        children: [
          pw.Container(
            width: 40,
            height: 40,
            decoration: pw.BoxDecoration(
              color: _getStatusColor(member['status'] ?? 'Active'),
              borderRadius: pw.BorderRadius.circular(20),
            ),
            child: pw.Center(
              child: pw.Text(
                member['name']?.substring(0, 1).toUpperCase() ?? 'U',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
            ),
          ),
          pw.SizedBox(width: 15),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  member['name'] ?? 'Unknown',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey800,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  member['position'] ?? 'Unknown Position',
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                ),
                pw.SizedBox(height: 6),
                pw.Row(
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: pw.BoxDecoration(
                        color: _getStatusColor(member['status'] ?? 'Active'),
                        borderRadius: pw.BorderRadius.circular(12),
                      ),
                      child: pw.Text(
                        member['status'] ?? 'Unknown',
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                    if (member['email'] != null) ...[
                      pw.SizedBox(width: 8),
                      pw.Text(
                        '@ ${member['email']}',
                        style: pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.grey500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                '2 projects',
                style: pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text(
                    '★',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.orange600,
                    ),
                  ),
                  pw.SizedBox(width: 2),
                  pw.Text(
                    '4.8',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.orange600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
