import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _error;

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
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
                  child: Column(
                    children: [
                      _buildRegisterCard(),
                      const SizedBox(height: 18),
                      const Text(
                        'Mario Konditorejas fabrika v1.0',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9B9489),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
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
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 56),
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
            ],
          ),
          const SizedBox(height: 12),
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
              Icons.person_add_alt_1_rounded,
              color: Colors.white,
              size: 38,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'MARIO',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: 5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Yangi ishchi akkaunti yaratish',
            style: TextStyle(
              color: Colors.white.withOpacity(0.82),
              fontSize: 13,
              letterSpacing: 1,
              fontWeight: FontWeight.w500,
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
                  Icons.badge_outlined,
                  color: Colors.white,
                  size: 15,
                ),
                SizedBox(width: 6),
                Text(
                  'Worker role bilan yaratiladi',
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

  Widget _buildRegisterCard() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Ro‘yxatdan o‘tish',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: marioText,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Center(
            child: Text(
              'Yangi hisob yarating va tizimga ulaning',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: marioSub,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 22),
          _fieldLabel('To‘liq ism'),
          const SizedBox(height: 8),
          _textField(
            ctrl: _nameCtrl,
            hint: 'Ali Valiyev',
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 16),
          _fieldLabel('Email'),
          const SizedBox(height: 8),
          _textField(
            ctrl: _emailCtrl,
            hint: 'ali@mario.lv',
            icon: Icons.mail_outline_rounded,
            keyboard: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _fieldLabel('Parol'),
          const SizedBox(height: 8),
          _textField(
            ctrl: _passCtrl,
            hint: 'Kamida 6 belgi',
            icon: Icons.lock_outline_rounded,
            obscure: _obscurePass,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePass
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: marioSub,
                size: 20,
              ),
              onPressed: () {
                setState(() => _obscurePass = !_obscurePass);
              },
            ),
          ),
          const SizedBox(height: 16),
          _fieldLabel('Parolni tasdiqlang'),
          const SizedBox(height: 8),
          _textField(
            ctrl: _confirmCtrl,
            hint: 'Parolni qayta kiriting',
            icon: Icons.lock_outline_rounded,
            obscure: _obscureConfirm,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirm
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: marioSub,
                size: 20,
              ),
              onPressed: () {
                setState(() => _obscureConfirm = !_obscureConfirm);
              },
            ),
          ),
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
              onPressed: _loading ? null : _register,
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
                'Ro‘yxatdan o‘tish',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Hisobingiz bormi? ',
                style: TextStyle(
                  color: marioSub,
                  fontSize: 13,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  'Kirish',
                  style: TextStyle(
                    color: marioRed,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: marioCream,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: marioRed,
                  size: 18,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Yaratilgan akkaunt avtomatik worker sifatida saqlanadi.',
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
        ],
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: marioSub,
      ),
    );
  }

  Widget _textField({
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboard,
      obscureText: obscure,
      style: const TextStyle(
        fontSize: 14,
        color: marioText,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFFAAA397),
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(icon, color: marioRed, size: 20),
        suffixIcon: suffixIcon,
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

  Future<void> _register() async {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Ismingizni kiriting');
      return;
    }

    if (_emailCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Emailni kiriting');
      return;
    }

    if (_passCtrl.text.length < 6) {
      setState(() => _error = 'Parol kamida 6 belgidan iborat bo‘lsin');
      return;
    }

    if (_passCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'Parollar mos kelmadi');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );

      await _db.collection('users').doc(cred.user!.uid).set({
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'role': 'worker',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await cred.user!.updateDisplayName(_nameCtrl.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_nameCtrl.text.trim()}, xush kelibsiz!'),
            backgroundColor: const Color(0xFF3B6D11),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _loading = false;
        _error = _errorMessage(e.code);
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Xatolik yuz berdi: $e';
      });
    }
  }

  String _errorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Bu email allaqachon ro‘yxatdan o‘tgan';
      case 'weak-password':
        return 'Parol juda oddiy, murakkabroq kiriting';
      case 'invalid-email':
        return 'Email noto‘g‘ri formatda';
      case 'network-request-failed':
        return 'Internet aloqasi yo‘q';
      default:
        return 'Xatolik: $code';
    }
  }
}