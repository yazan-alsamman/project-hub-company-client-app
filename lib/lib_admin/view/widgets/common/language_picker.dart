import 'package:flutter/material.dart';
import '../../../core/constant/color.dart';
class LanguagePicker extends StatelessWidget {
  final String? selectedLanguage;
  final Function(String) onLanguageSelected;
  const LanguagePicker({
    super.key,
    this.selectedLanguage,
    required this.onLanguageSelected,
  });
  final List<Map<String, String>> languages = const [
    {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
    {'code': 'ar', 'name': 'العربية', 'flag': '🇸🇦'},
    {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
    {'code': 'de', 'name': 'Deutsch', 'flag': '🇩🇪'},
    {'code': 'it', 'name': 'Italiano', 'flag': '🇮🇹'},
    {'code': 'pt', 'name': 'Português', 'flag': '🇵🇹'},
    {'code': 'ru', 'name': 'Русский', 'flag': '🇷🇺'},
    {'code': 'zh', 'name': '中文', 'flag': '🇨🇳'},
    {'code': 'ja', 'name': '日本語', 'flag': '🇯🇵'},
    {'code': 'ko', 'name': '한국어', 'flag': '🇰🇷'},
    {'code': 'hi', 'name': 'हिन्दी', 'flag': '🇮🇳'},
    {'code': 'tr', 'name': 'Türkçe', 'flag': '🇹🇷'},
    {'code': 'pl', 'name': 'Polski', 'flag': '🇵🇱'},
    {'code': 'nl', 'name': 'Nederlands', 'flag': '🇳🇱'},
    {'code': 'sv', 'name': 'Svenska', 'flag': '🇸🇪'},
    {'code': 'da', 'name': 'Dansk', 'flag': '🇩🇰'},
    {'code': 'no', 'name': 'Norsk', 'flag': '🇳🇴'},
    {'code': 'fi', 'name': 'Suomi', 'flag': '🇫🇮'},
    {'code': 'cs', 'name': 'Čeština', 'flag': '🇨🇿'},
    {'code': 'sk', 'name': 'Slovenčina', 'flag': '🇸🇰'},
    {'code': 'el', 'name': 'Ελληνικά', 'flag': '🇬🇷'},
    {'code': 'he', 'name': 'עברית', 'flag': '🇮🇱'},
    {'code': 'th', 'name': 'ไทย', 'flag': '🇹🇭'},
    {'code': 'vi', 'name': 'Tiếng Việt', 'flag': '🇻🇳'},
    {'code': 'id', 'name': 'Bahasa Indonesia', 'flag': '🇮🇩'},
    {'code': 'ms', 'name': 'Bahasa Melayu', 'flag': '🇲🇾'},
    {'code': 'sw', 'name': 'Kiswahili', 'flag': '🇰🇪'},
    {'code': 'af', 'name': 'Afrikaans', 'flag': '🇿🇦'},
    {'code': 'bg', 'name': 'Български', 'flag': '🇧🇬'},
    {'code': 'ro', 'name': 'Română', 'flag': '🇷🇴'},
    {'code': 'hu', 'name': 'Magyar', 'flag': '🇭🇺'},
    {'code': 'hr', 'name': 'Hrvatski', 'flag': '🇭🇷'},
    {'code': 'sr', 'name': 'Српски', 'flag': '🇷🇸'},
    {'code': 'uk', 'name': 'Українська', 'flag': '🇺🇦'},
    {'code': 'bn', 'name': 'বাংলা', 'flag': '🇧🇩'},
    {'code': 'ur', 'name': 'اردو', 'flag': '🇵🇰'},
    {'code': 'fa', 'name': 'فارسی', 'flag': '🇮🇷'},
    {'code': 'ta', 'name': 'தமிழ்', 'flag': '🇱🇰'},
    {'code': 'te', 'name': 'తెలుగు', 'flag': '🇮🇳'},
    {'code': 'ml', 'name': 'മലയാളം', 'flag': '🇮🇳'},
    {'code': 'kn', 'name': 'ಕನ್ನಡ', 'flag': '🇮🇳'},
    {'code': 'gu', 'name': 'ગુજરાતી', 'flag': '🇮🇳'},
    {'code': 'pa', 'name': 'ਪੰਜਾਬੀ', 'flag': '🇮🇳'},
    {'code': 'mr', 'name': 'मराठी', 'flag': '🇮🇳'},
    {'code': 'ne', 'name': 'नेपाली', 'flag': '🇳🇵'},
    {'code': 'si', 'name': 'සිංහල', 'flag': '🇱🇰'},
    {'code': 'my', 'name': 'မြန်မာ', 'flag': '🇲🇲'},
    {'code': 'ka', 'name': 'ქართული', 'flag': '🇬🇪'},
    {'code': 'am', 'name': 'አማርኛ', 'flag': '🇪🇹'},
    {'code': 'ny', 'name': 'Chichewa', 'flag': '🇲🇼'},
    {'code': 'zu', 'name': 'isiZulu', 'flag': '🇿🇦'},
    {'code': 'xh', 'name': 'isiXhosa', 'flag': '🇿🇦'},
    {'code': 'et', 'name': 'Eesti', 'flag': '🇪🇪'},
    {'code': 'lv', 'name': 'Latviešu', 'flag': '🇱🇻'},
    {'code': 'lt', 'name': 'Lietuvių', 'flag': '🇱🇹'},
    {'code': 'mt', 'name': 'Malti', 'flag': '🇲🇹'},
    {'code': 'ga', 'name': 'Gaeilge', 'flag': '🇮🇪'},
    {'code': 'cy', 'name': 'Cymraeg', 'flag': '🇬🇧'},
    {'code': 'eu', 'name': 'Euskara', 'flag': '🇪🇸'},
    {'code': 'ca', 'name': 'Català', 'flag': '🇪🇸'},
    {'code': 'gl', 'name': 'Galego', 'flag': '🇪🇸'},
    {'code': 'mk', 'name': 'Македонски', 'flag': '🇲🇰'},
    {'code': 'sq', 'name': 'Shqip', 'flag': '🇦🇱'},
    {'code': 'is', 'name': 'Íslenska', 'flag': '🇮🇸'},
    {'code': 'fo', 'name': 'Føroyskt', 'flag': '🇫🇴'},
  ];
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showLanguagePicker(context);
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
              selectedLanguage ?? 'Select language',
              style: TextStyle(
                fontSize: 14,
                color: selectedLanguage != null
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
  void _showLanguagePicker(BuildContext context) {
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
                    'Select Language',
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
                itemCount: languages.length,
                itemBuilder: (context, index) {
                  final language = languages[index];
                  final isSelected = selectedLanguage == language['name'];
                  return ListTile(
                    leading: Text(
                      language['flag']!,
                      style: TextStyle(fontSize: 24),
                    ),
                    title: Text(
                      language['name']!,
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
                      onLanguageSelected(language['name']!);
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
