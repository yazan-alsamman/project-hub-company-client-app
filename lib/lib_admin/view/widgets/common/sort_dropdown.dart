import 'package:flutter/material.dart';
enum SortOption { deadline, projectStatus }
class SortDropdown extends StatefulWidget {
  final SortOption selectedOption;
  final ValueChanged<SortOption> onChanged;
  const SortDropdown({
    super.key,
    required this.selectedOption,
    required this.onChanged,
  });
  @override
  State<SortDropdown> createState() => _SortDropdownState();
}
class _SortDropdownState extends State<SortDropdown> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SortOption>(
          value: widget.selectedOption,
          isExpanded: false,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Color(0xFF666666),
            size: 20,
          ),
          style: const TextStyle(
            color: Color(0xFF333333),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          items: [
            DropdownMenuItem<SortOption>(
              value: SortOption.deadline,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Color(0xFF666666),
                  ),
                  const SizedBox(width: 8),
                  const Text("Deadline"),
                ],
              ),
            ),
            DropdownMenuItem<SortOption>(
              value: SortOption.projectStatus,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.flag, size: 16, color: Color(0xFF666666)),
                  const SizedBox(width: 8),
                  const Text("Project Status"),
                ],
              ),
            ),
          ],
          onChanged: (SortOption? newValue) {
            if (newValue != null) {
              widget.onChanged(newValue);
            }
          },
        ),
      ),
    );
  }
}
