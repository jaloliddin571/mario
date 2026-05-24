import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState
    extends State<LanguageSelectionScreen> {
  static const marioRed = Color(0xFFC0392B);
  static const marioRedDark = Color(0xFFA82F23);
  static const marioCream = Color(0xFFFFFBF5);
  static const marioBg = Color(0xFFF6F2EA);
  static const marioCard = Color(0xFFFFFFFF);
  static const marioBorder = Color(0xFFE9E1D3);
  static const marioText = Color(0xFF201D1A);
  static const marioSub = Color(0xFF7B746B);
  static const marioLight = Color(0xFFFAE6DE);

  String _selectedLanguage = 'uz';

  @override
  Widget build(BuildContext context) {
    final languages = [
      {
        'key': 'uz',
        'title': 'O\'zbekcha',
        'subtitle': 'Asosiy til',
        'short': 'UZ',
        'color': marioRed,
        'bg': marioLight,
      },
      {
        'key': 'ru',
        'title': 'Русский',
        'subtitle': 'Русский интерфейс',
        'short': 'RU',
        'color': const Color(0xFF2456A6),
        'bg': const Color(0xFFE8F0FF),
      },
      {
        'key': 'en',
        'title': 'English',
        'subtitle': 'English interface',
        'short': 'EN',
        'color': const Color(0xFF2E7D32),
        'bg': const Color(0xFFEAF7EB),
      },
    ];

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
                _buildHeader(),
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
                          const Text(
                            'Tilni tanlang',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: marioText,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Davom etishdan oldin interfeys tilini tanlang',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: marioSub,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 22),
                          ...languages.map((lang) {
                            final selected =
                                _selectedLanguage == lang['key'];

                            final color = lang['color'] as Color;
                            final bg = lang['bg'] as Color;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() {
                                    _selectedLanguage =
                                    lang['key'] as String;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration:
                                  const Duration(milliseconds: 220),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: selected ? bg : marioCream,
                                    borderRadius:
                                    BorderRadius.circular(18),
                                    border: Border.all(
                                      color: selected
                                          ? color
                                          : marioBorder,
                                      width: selected ? 1.3 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                          BorderRadius.circular(14),
                                        ),
                                        child: Center(
                                          child: Text(
                                            lang['short'] as String,
                                            style: TextStyle(
                                              color: color,
                                              fontSize: 14,
                                              fontWeight:
                                              FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              lang['title'] as String,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight:
                                                FontWeight.w700,
                                                color: marioText,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              lang['subtitle']
                                              as String,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: marioSub,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      AnimatedContainer(
                                        duration: const Duration(
                                            milliseconds: 220),
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: selected
                                              ? color
                                              : Colors.transparent,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: selected
                                                ? color
                                                : marioBorder,
                                            width: 1.4,
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
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 10),
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
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.translate_rounded,
                                  color: marioRed,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Til tanlangandan keyin login sahifasiga o‘tasiz.',
                                    style: TextStyle(
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
                              onPressed: _continueToLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: marioRed,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Davom etish',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
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

  Widget _buildHeader() {
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
            'Dastur tilini tanlash',
            style: TextStyle(
              color: Colors.white.withOpacity(0.82),
              fontSize: 13,
              letterSpacing: 1.2,
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
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.public_rounded,
                  color: Colors.white,
                  size: 15,
                ),
                SizedBox(width: 6),
                Text(
                  '3 ta til varianti mavjud',
                  style: TextStyle(
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

  void _continueToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }
}