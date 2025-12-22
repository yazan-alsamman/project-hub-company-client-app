import 'package:flutter/material.dart';
import 'package:project_hub/lib_client/core/constant/color.dart';

class TimezonePicker extends StatelessWidget {
  final String? selectedTimezone;
  final Function(String) onTimezoneSelected;

  const TimezonePicker({
    super.key,
    this.selectedTimezone,
    required this.onTimezoneSelected,
  });

  final List<String> timezones = const [
    'UTC',
    'America/New_York',
    'America/Chicago',
    'America/Denver',
    'America/Los_Angeles',
    'Europe/London',
    'Europe/Paris',
    'Europe/Berlin',
    'Europe/Rome',
    'Europe/Madrid',
    'Asia/Dubai',
    'Asia/Riyadh',
    'Asia/Kuwait',
    'Asia/Doha',
    'Asia/Bahrain',
    'Asia/Tokyo',
    'Asia/Shanghai',
    'Asia/Hong_Kong',
    'Asia/Singapore',
    'Australia/Sydney',
    'Africa/Cairo',
    'Africa/Johannesburg',
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showTimezonePicker(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColor.backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColor.borderColor, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedTimezone ?? 'Select timezone',
              style: TextStyle(
                fontSize: 14,
                color: selectedTimezone != null
                    ? AppColor.textColor
                    : AppColor.textSecondaryColor,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: AppColor.textSecondaryColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showTimezonePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColor.borderColor, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Timezone',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                    color: AppColor.textSecondaryColor,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: timezones.length,
                itemBuilder: (context, index) {
                  final timezone = timezones[index];
                  final isSelected = selectedTimezone == timezone;
                  return ListTile(
                    title: Text(
                      timezone,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColor.textColor,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check,
                            color: AppColor.primaryColor,
                            size: 20,
                          )
                        : null,
                    onTap: () {
                      onTimezoneSelected(timezone);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

