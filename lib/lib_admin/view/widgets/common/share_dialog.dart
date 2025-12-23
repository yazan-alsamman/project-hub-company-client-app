import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/constant/color.dart';
import '../../../data/Models/project_model.dart';
import '../../../core/services/pdf_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';
class ShareDialog extends StatefulWidget {
  final ProjectModel project;
  const ShareDialog({super.key, required this.project});
  @override
  State<ShareDialog> createState() => _ShareDialogState();
}
class _ShareDialogState extends State<ShareDialog> {
  bool _isGeneratingPDF = false;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.share_outlined,
                    color: AppColor.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Share Project',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColor.textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.project.title,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColor.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                  color: AppColor.textSecondaryColor,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildShareOption(
              icon: Icons.picture_as_pdf_outlined,
              title: 'Share as PDF',
              subtitle: 'Generate and share project details as PDF',
              onTap: _shareAsPDF,
              isLoading: _isGeneratingPDF,
            ),
            const SizedBox(height: 12),
            _buildShareOption(
              icon: Icons.text_snippet_outlined,
              title: 'Share as Text',
              subtitle: 'Share project information as text',
              onTap: _shareAsText,
            ),
            const SizedBox(height: 12),
            _buildShareOption(
              icon: Icons.link_outlined,
              title: 'Copy Project Link',
              subtitle: 'Copy a shareable link to clipboard',
              onTap: _copyProjectLink,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColor.textSecondaryColor,
                  side: const BorderSide(color: AppColor.borderColor),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildShareOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColor.primaryColor,
                            ),
                          ),
                        )
                      : Icon(icon, color: AppColor.primaryColor, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColor.textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColor.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLoading)
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColor.textSecondaryColor,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Future<void> _shareAsPDF() async {
    if (!mounted) return;
    setState(() {
      _isGeneratingPDF = true;
    });
    try {
      print('Starting PDF generation...');
      final file = await PDFService.generateProjectPDF(widget.project).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('PDF generation timed out after 30 seconds');
          return null;
        },
      );
      print('PDF generation result: ${file != null ? 'Success' : 'Failed'}');
      if (!mounted) return;
      if (file != null) {
        print('PDF file created at: ${file.path}');
        print('File exists: ${await file.exists()}');
        print('File size: ${await file.length()} bytes');
        try {
          print('Attempting to share PDF file...');
          if (!await file.exists()) {
            throw Exception('PDF file does not exist at path: ${file.path}');
          }
          final fileSize = await file.length();
          if (fileSize == 0) {
            throw Exception('PDF file is empty');
          }
          print('PDF file exists and size is: $fileSize bytes');
          await Share.shareXFiles(
            [XFile(file.path, mimeType: 'application/pdf')],
            text: 'Project Details: ${widget.project.title}',
            subject: 'Project Report - ${widget.project.title}',
          );
          print('PDF shared successfully with shareXFiles');
        } catch (shareError) {
          print('ShareXFiles error: $shareError');
          try {
            print('Trying alternative share method...');
            await Share.share(
              'Project Details: ${widget.project.title}\n\nFile saved at: ${file.path}',
              subject: 'Project Report - ${widget.project.title}',
            );
            print('PDF shared successfully with Share.share');
          } catch (alternativeError) {
            print('Alternative share error: $alternativeError');
            try {
              print('Trying to open file with open_file...');
              final result = await OpenFile.open(file.path);
              if (result.type == ResultType.done) {
                print('File opened successfully');
                Get.snackbar(
                  'PDF Opened',
                  'PDF opened successfully in default app',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColor.successColor,
                  colorText: AppColor.white,
                  borderRadius: 12,
                  margin: const EdgeInsets.all(16),
                );
              } else {
                throw Exception('Failed to open file: ${result.message}');
              }
            } catch (openError) {
              print('Open file error: $openError');
              if (await file.exists()) {
                Get.snackbar(
                  'PDF Generated Successfully!',
                  'PDF saved at: ${file.path}\n\nTap to copy path',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColor.successColor,
                  colorText: AppColor.white,
                  duration: const Duration(seconds: 8),
                  borderRadius: 12,
                  margin: const EdgeInsets.all(16),
                  onTap: (snack) {
                    Clipboard.setData(ClipboardData(text: file.path));
                    Get.snackbar(
                      'Path Copied',
                      'File path copied to clipboard',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: AppColor.primaryColor,
                      colorText: AppColor.white,
                      borderRadius: 12,
                      margin: const EdgeInsets.all(16),
                    );
                  },
                );
              } else {
                throw Exception('File was created but does not exist');
              }
            }
          }
        }
        if (mounted) {
          setState(() {
            _isGeneratingPDF = false;
          });
        }
        Get.back();
        Get.snackbar(
          'Success',
          'Project PDF generated and shared successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColor.successColor,
          colorText: AppColor.white,
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
        );
      } else {
        throw Exception('Failed to generate PDF - file is null');
      }
    } catch (e, stackTrace) {
      print('Error in _shareAsPDF: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _isGeneratingPDF = false;
        });
      }
      String errorMessage = 'Failed to generate PDF';
      if (e.toString().contains('TimeoutException')) {
        errorMessage = 'PDF generation timed out. Please try again.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'PDF generation timed out. Please try again.';
      } else {
        errorMessage = 'Failed to generate PDF: ${e.toString()}';
      }
      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.errorColor,
        colorText: AppColor.white,
        duration: const Duration(seconds: 5),
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingPDF = false;
        });
      }
    }
  }
  Future<void> _shareAsText() async {
    final text = _generateProjectText();
    await Share.share(
      text,
      subject: 'Project Details - ${widget.project.title}',
    );
    Get.back();
  }
  Future<void> _copyProjectLink() async {
    final projectLink = 'https://projecthub.app/project/${widget.project.id}';
    Get.back();
    Get.snackbar(
      'Copied',
      'Project link copied to clipboard: $projectLink',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColor.primaryColor,
      colorText: AppColor.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
    );
  }
  String _generateProjectText() {
    return '''
Project Details Report
=====================
Project Name: ${widget.project.title}
Company: ${widget.project.company}
Status: ${widget.project.status}
Progress: ${widget.project.progress > 1.0 ? widget.project.progress.round() : (widget.project.progress * 100).round()}%
Description:
${widget.project.description}
Timeline:
Start Date: ${widget.project.startDate}
End Date: ${widget.project.endDate}
Team:
Total Members: ${widget.project.teamMembers}
Generated on: ${DateTime.now().toString().split(' ')[0]}
Generated by: ProjectHub
''';
  }
}
