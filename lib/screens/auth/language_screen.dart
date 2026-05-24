import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/language_provider.dart';
import 'login_screen.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  static const marioRed = Color(0xFFC0392B);
  static const marioRedDark = Color(0xFFA82F23);
  static const marioCream = Color(0xFFFFFBF5);
  static const marioBg = Color(0xFFF6F2EA);
  static const marioCard = Color(0xFFFFFFFF);
  static const marioBorder = Color(0xFFE9E1D3);
  static const marioText = Color(0xFF201D1A);
  static const marioSub = Color(0xFF7B746B);
  static const marioLight = Color(0xFFFAE6DE);

  String _selectedCode = 'uz';

  final List<Map<String, String>> _languages = const [
    {
      'code': 'uz',
      'name': 'O\'zbek',
      'nativeName': 'O\'zbek tili',
      'flag': '🇺🇿',
      'short': 'UZ',
    },
    {
      'code': 'ru',
      'name': 'Русский',
      'nativeName': 'Русский язык',
      'flag': '🇷🇺',
      'short': 'RU',
    },
    {
      'code': 'en',
      'name': 'English',
      'nativeName': 'English language',
      'flag': '🇬🇧',
      'short': 'EN',
    },
    {
      'code': 'lv',
      'name': 'Latviešu',
      'nativeName': 'Latviešu valoda',
      'flag': '🇱🇻',
      'short': 'LV',
    },
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    _selectedCode = langProvider.locale.languageCode;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: marioBg,
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildHeader(t),
                Transform.translate(
                  offset: const Offset(0, -24),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                      decoration: BoxDecoration(
                        color: marioCard,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: marioBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 22,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            t.languageSelectTitle,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: marioText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            t.languageSelectSubtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: marioSub,
                              fontSize: 13,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 22),
                          ..._languages.map(_langCard),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: marioCream,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.translate_rounded,
                                  color: marioRed,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    t.languageSelectHint,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: marioSub,
                                      height: 1.4,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _continue,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: marioRed,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    t.continueButton,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 18,
                                  ),
                                ],
                              ),
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
      ),
    );
  }

  Widget _buildHeader(AppLocalizations t) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 56),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [marioRed, marioRedDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(34),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: const Icon(
              Icons.language_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'MARIO',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: 5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            t.languageHeaderSubtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.82),
              fontSize: 13,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: Colors.white.withOpacity(0.14),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.public_rounded,
                  color: Colors.white,
                  size: 15,
                ),
                const SizedBox(width: 6),
                Text(
                  t.languageAvailableCount,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _langCard(Map<String, String> lang) {
    final selected = _selectedCode == lang['code'];

    Color accent;
    Color bg;

    switch (lang['code']) {
      case 'ru':
        accent = const Color(0xFF2456A6);
        bg = const Color(0xFFE8F0FF);
        break;
      case 'en':
        accent = const Color(0xFF2E7D32);
        bg = const Color(0xFFEAF7EB);
        break;
      case 'lv':
        accent = const Color(0xFF8B1E2D);
        bg = const Color(0xFFFFEEF1);
        break;
      default:
        accent = marioRed;
        bg = marioLight;
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedCode = lang['code']!);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? bg : marioCream,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? accent : marioBorder,
            width: selected ? 1.3 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  lang['flag']!,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang['name']!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: selected ? accent : marioText,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    lang['nativeName']!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: marioSub,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? accent.withOpacity(0.12) : Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    lang['short']!,
                    style: TextStyle(
                      color: accent,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? accent : Colors.transparent,
                    border: Border.all(
                      color: selected ? accent : marioBorder,
                      width: 1.5,
                    ),
                  ),
                  child: selected
                      ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 14,
                  )
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _continue() async {
    final langProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    await langProvider.setLanguage(Locale(_selectedCode));
    await langProvider.completeFirstTime();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }
}