import 'package:flutter/material.dart';
import 'package:mario/screens/auth/register_screen.dart';
import 'package:provider/provider.dart';

import '../../../services/auth_service.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  bool _obscure = true;

  String? _error;

  static const marioRed = Color(0xFFC0392B);
  static const marioRedDark = Color(0xFFA82F23);

  static const marioCream = Color(0xFFFFFBF5);
  static const marioBg = Color(0xFFF6F2EA);

  static const marioCard = Color(0xFFFFFFFF);

  static const marioBorder = Color(0xFFE9E1D3);

  static const marioText = Color(0xFF201D1A);
  static const marioSub = Color(0xFF7B746B);

  static const marioLight = Color(0xFFFAE6DE);

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: marioBg,

      body: SafeArea(
        bottom: false,

        child: SingleChildScrollView(

          physics:
          const BouncingScrollPhysics(),

          child: Column(
            children: [

              _buildHeader(),

              Transform.translate(

                offset: const Offset(0, -24),

                child: Padding(
                  padding:
                  const EdgeInsets.fromLTRB(
                      16, 0, 16, 24),

                  child: _buildLoginCard(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── HEADER ──────────────────────────────────────────────
  Widget _buildHeader() {

    return Container(

      width: double.infinity,

      padding:
      const EdgeInsets.fromLTRB(
          24, 28, 24, 54),

      decoration: const BoxDecoration(

        gradient: LinearGradient(
          colors: [
            marioRed,
            marioRedDark,
          ],

          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(34),
        ),
      ),

      child: Column(
        children: [

          const SizedBox(height: 6),

          Container(
            width: 82,
            height: 82,

            decoration: BoxDecoration(
              color:
              Colors.white.withOpacity(0.12),

              shape: BoxShape.circle,

              border: Border.all(
                color: Colors.white24,
                width: 1,
              ),
            ),

            child: const Icon(
              Icons.storefront_rounded,
              color: Colors.white,
              size: 38,
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
            'Smena boshqaruvi',

            style: TextStyle(
              color:
              Colors.white.withOpacity(0.82),

              fontSize: 13,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 18),

          Container(
            padding:
            const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8),

            decoration: BoxDecoration(
              color:
              Colors.white.withOpacity(0.12),

              borderRadius:
              BorderRadius.circular(999),

              border: Border.all(
                color:
                Colors.white.withOpacity(0.14),
              ),
            ),

            child: const Row(
              mainAxisSize: MainAxisSize.min,

              children: [

                Icon(
                  Icons.lock_outline_rounded,
                  color: Colors.white,
                  size: 15,
                ),

                SizedBox(width: 6),

                Text(
                  'Xavfsiz tizimga kirish',

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

  // ── LOGIN CARD ──────────────────────────────────────────
  Widget _buildLoginCard() {

    return Container(

      width: double.infinity,

      padding:
      const EdgeInsets.fromLTRB(
          18, 18, 18, 20),

      decoration: BoxDecoration(
        color: marioCard,

        borderRadius:
        BorderRadius.circular(24),

        border: Border.all(
          color: marioBorder,
        ),

        boxShadow: [

          BoxShadow(
            color:
            Colors.black.withOpacity(0.05),

            blurRadius: 22,

            offset: const Offset(0, 10),
          ),
        ],
      ),

      child: Column(

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          const Center(
            child: Text(
              'Xush kelibsiz',

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
              'Hisobingizga kirib ish jarayonini davom ettiring',

              textAlign: TextAlign.center,

              style: TextStyle(
                color: marioSub,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),

          const SizedBox(height: 22),

          // EMAIL
          const Text(
            'Email',

            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: marioSub,
            ),
          ),

          const SizedBox(height: 8),

          _buildInput(
            controller: _emailController,
            hint: 'ism@mario.lv',
            icon: Icons.mail_outline_rounded,
            keyboardType:
            TextInputType.emailAddress,
          ),

          const SizedBox(height: 16),

          // PASSWORD
          const Text(
            'Parol',

            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: marioSub,
            ),
          ),

          const SizedBox(height: 8),

          _buildInput(
            controller: _passwordController,
            hint: '••••••••',
            icon: Icons.lock_outline_rounded,

            obscureText: _obscure,

            suffix: IconButton(

              icon: Icon(

                _obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,

                color: marioSub,
                size: 20,
              ),

              onPressed: () {

                setState(() {
                  _obscure = !_obscure;
                });
              },
            ),
          ),

          // ERROR
          if (_error != null) ...[

            const SizedBox(height: 14),

            Container(

              width: double.infinity,

              padding:
              const EdgeInsets.all(12),

              decoration: BoxDecoration(
                color:
                const Color(0xFFFFF2F1),

                borderRadius:
                BorderRadius.circular(14),

                border: Border.all(
                  color:
                  const Color(0xFFF0C9C4),
                ),
              ),

              child: Row(

                crossAxisAlignment:
                CrossAxisAlignment.start,

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
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // LOGIN BUTTON
          SizedBox(
            width: double.infinity,
            height: 54,

            child: ElevatedButton(

              onPressed:
              _loading ? null : _login,

              style:
              ElevatedButton.styleFrom(

                backgroundColor:
                marioRed,

                foregroundColor:
                Colors.white,

                disabledBackgroundColor:
                marioRed.withOpacity(0.7),

                elevation: 0,

                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(16),
                ),
              ),

              child: _loading

                  ? const SizedBox(
                width: 22,
                height: 22,

                child:
                CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.2,
                ),
              )

                  : const Text(
                'Kirish',

                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // FORGOT PASSWORD
          Center(
            child: GestureDetector(

              onTap: () => Navigator.push(
                context,

                MaterialPageRoute(
                  builder: (_) =>
                  const ForgotPasswordScreen(),
                ),
              ),

              child: const Text(
                'Parolni unutdingizmi?',

                style: TextStyle(
                  color: marioRed,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // DIVIDER
          Row(
            children: [

              const Expanded(
                child: Divider(
                  color: Color(0xFFD3D1C7),
                ),
              ),

              Padding(
                padding:
                const EdgeInsets.symmetric(
                    horizontal: 12),

                child: Text(
                  'yoki',

                  style: TextStyle(
                    color:
                    Colors.grey.shade500,

                    fontSize: 12,
                  ),
                ),
              ),

              const Expanded(
                child: Divider(
                  color: Color(0xFFD3D1C7),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // REGISTER BUTTON
          SizedBox(
            width: double.infinity,
            height: 52,

            child: OutlinedButton(

              onPressed: () => Navigator.push(
                context,

                MaterialPageRoute(
                  builder: (_) =>
                  const RegisterScreen(),
                ),
              ),

              style:
              OutlinedButton.styleFrom(

                foregroundColor:
                marioRed,

                side: const BorderSide(
                  color: marioRed,
                  width: 1.5,
                ),

                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),

              child: const Text(
                'Yangi hisob yaratish',

                style: TextStyle(
                  fontSize: 15,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // INFO BOX
          Container(

            width: double.infinity,

            padding:
            const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12),

            decoration: BoxDecoration(
              color: marioCream,

              borderRadius:
              BorderRadius.circular(14),
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
                    'Admin va ishchi akkauntlari shu yerdan kiradi.',

                    style: TextStyle(
                      fontSize: 12,
                      color: marioSub,
                      height: 1.4,
                      fontWeight:
                      FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // VERSION
          const Center(
            child: Text(
              'Mario Konditorejas fabrika v1.0',

              style: TextStyle(
                fontSize: 11,
                color: Color(0xFFB4B2A9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── INPUT ───────────────────────────────────────────────
  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffix,
  }) {

    return TextField(

      controller: controller,

      keyboardType: keyboardType,

      obscureText: obscureText,

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

        prefixIcon:
        Icon(icon,
            color: marioRed,
            size: 20),

        suffixIcon: suffix,

        filled: true,
        fillColor: marioCream,

        contentPadding:
        const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 16),

        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(16),

          borderSide:
          BorderSide(color: marioBorder),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(16),

          borderSide:
          BorderSide(color: marioBorder),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(16),

          borderSide: const BorderSide(
            color: marioRed,
            width: 1.3,
          ),
        ),
      ),
    );
  }

  // ── LOGIN ───────────────────────────────────────────────
  Future<void> _login() async {

    setState(() {
      _loading = true;
      _error = null;
    });

    final auth =
    Provider.of<AuthService>(
      context,
      listen: false,
    );

    final error = await auth.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (mounted) {

      setState(() {

        _loading = false;

        _error = error;
      });
    }
  }

  @override
  void dispose() {

    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }
}