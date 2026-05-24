import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  static const marioRed = Color(0xFFC0392B);
  static const marioRedDark = Color(0xFFA82F23);
  static const marioCream = Color(0xFFFFFBF5);
  static const marioBg = Color(0xFFF6F2EA);
  static const marioCard = Color(0xFFFFFFFF);
  static const marioBorder = Color(0xFFE9E1D3);
  static const marioText = Color(0xFF201D1A);
  static const marioSub = Color(0xFF7B746B);
  static const marioLight = Color(0xFFFAE6DE);
  static const marioGold = Color(0xFFF1B94E);

  final _emailCtrl = TextEditingController();

  bool _loading = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  child: _sent ? _buildSuccessCard() : _buildFormCard(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 56),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [marioRed, marioRedDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(34)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.14),
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Parolni tiklash',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Emailga tiklash havolasini yuboramiz',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white24,
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.lock_reset_rounded,
              color: Colors.white,
              size: 38,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withOpacity(0.14)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.mail_outline_rounded,
                  color: Colors.white,
                  size: 15,
                ),
                SizedBox(width: 6),
                Text(
                  'Tiklash linki emailga yuboriladi',
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

  Widget _buildFormCard() {
    return Container(
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
          Container(
            width: 82,
            height: 82,
            decoration: const BoxDecoration(
              color: marioLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_unread_outlined,
              color: marioRed,
              size: 36,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Parolni unutdingizmi?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: marioText,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Emailingizni kiriting, parolni tiklash uchun havola yuboramiz',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: marioSub,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Email',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: marioSub,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _emailField(),
          if (_error != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF2F1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF0C9C4)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.red,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _loading ? null : _sendReset,
              style: ElevatedButton.styleFrom(
                backgroundColor: marioRed,
                foregroundColor: Colors.white,
                disabledBackgroundColor: marioRed.withOpacity(0.7),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _loading
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.2,
                ),
              )
                  : const Text(
                'Link yuborish',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Loginga qaytish',
              style: TextStyle(
                color: marioRed,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
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
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.85, end: 1),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEAF3DE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_read_outlined,
                    color: Color(0xFF3B6D11),
                    size: 46,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 22),
          const Text(
            'Email yuborildi',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: marioText,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${_emailCtrl.text.trim()} manziliga parolni tiklash havolasi yuborildi. Emailingizni tekshiring.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: marioSub,
              fontSize: 13,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 22),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF6DA),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFE2CC7A),
              ),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFFB8860B),
                  size: 18,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Havola spam papkaga tushgan bo‘lishi mumkin. Spam yoki Promotions bo‘limini ham tekshirib ko‘ring.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8B6914),
                      height: 1.45,
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
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _sent = false;
                  _error = null;
                });
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: marioRed,
                side: const BorderSide(color: marioRed, width: 1.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text(
                'Qayta yuborish',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: marioRed,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Loginga qaytish',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emailField() {
    return TextField(
      controller: _emailCtrl,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(
        fontSize: 14,
        color: marioText,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: 'ali@mario.lv',
        hintStyle: const TextStyle(
          color: Color(0xFFAAA397),
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: const Icon(
          Icons.mail_outline_rounded,
          color: marioRed,
          size: 20,
        ),
        filled: true,
        fillColor: marioCream,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: marioBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: marioBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: marioRed, width: 1.3),
        ),
      ),
    );
  }

  Future<void> _sendReset() async {
    if (_emailCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Emailni kiriting');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailCtrl.text.trim(),
      );

      if (mounted) {
        setState(() {
          _loading = false;
          _sent = true;
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _loading = false;
        _error = _errorMessage(e.code);
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Xatolik: $e';
      });
    }
  }

  String _errorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Bu email bilan hisob topilmadi';
      case 'invalid-email':
        return 'Email noto‘g‘ri formatda';
      case 'network-request-failed':
        return 'Internet aloqasi yo‘q';
      default:
        return 'Xatolik: $code';
    }
  }
}