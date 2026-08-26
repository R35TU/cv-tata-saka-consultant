import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/logo_widget.dart';
import '../../../widgets/bottom_wave_painter.dart';
import '../../../widgets/custom_text_field.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _rememberMe = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan isi username dan password terlebih dahulu.')),
      );
      return;
    }

    await ref.read(authControllerProvider.notifier).login(username, password, rememberMe: _rememberMe);

    if (!mounted) return;
    final state = ref.read(authControllerProvider);
    state.whenOrNull(
      data: (user) {
        if (user != null) {
          if (mounted) {
            context.go('/dashboard');
          }
        }
      },
      error: (error, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      },
    );
  }

  Widget _buildQuickLoginChip(String label, String username) {
    return ActionChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
          color: _usernameController.text == username ? const Color(0xFF001AFF) : Colors.grey.shade700,
        ),
      ),
      backgroundColor: _usernameController.text == username ? const Color(0xFFE5EAFF) : Colors.grey.shade100,
      side: BorderSide(
        color: _usernameController.text == username ? const Color(0xFF001AFF) : Colors.transparent,
        width: 1.0,
      ),
      onPressed: () {
        setState(() {
          _usernameController.text = username;
          _passwordController.text = '123456';
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: screenHeight * 0.12),
                              LogoWidget(size: screenWidth * 0.38),
                              SizedBox(height: screenHeight * 0.04),
                              const Text(
                                'Selamat Datang',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E1E1E),
                                  fontFamily: 'Inter',
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Silahkan masuk ke akun anda\nuntuk melanjutkan.',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Color(0xFF757575),
                                  height: 1.4,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Inter',
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: screenHeight * 0.035),
                              // Role helper chips
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildQuickLoginChip('Konsultan', 'konsultan'),
                                    const SizedBox(width: 8),
                                    _buildQuickLoginChip('Kontraktor', 'kontraktor'),
                                    const SizedBox(width: 8),
                                    _buildQuickLoginChip('Dinas', 'dinas'),
                                    const SizedBox(width: 8),
                                    _buildQuickLoginChip('Eksternal', 'eksternal'),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(hintText: 'Username', controller: _usernameController),
                              const SizedBox(height: 16),
                              CustomTextField(hintText: 'Password', obscureText: true, controller: _passwordController),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Theme(
                                    data: ThemeData(unselectedWidgetColor: const Color(0xFFCCCCCC)),
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        onChanged: (value) {
                                          setState(() {
                                            _rememberMe = value ?? false;
                                          });
                                        },
                                        activeColor: const Color(0xFF001AFF),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Ingat saya',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF1E1E1E),
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.03),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: authState.isLoading ? null : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF001AFF),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                    elevation: 0,
                                  ),
                                  child: authState.isLoading
                                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                      : const Text(
                                          'Masuk',
                                          style: TextStyle(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                      BottomWaveWidget(
                        height: 200,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'Akses lokal siap untuk role Konsultan, Kontraktor, Dinas, dan Eksternal',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 11.5, fontFamily: 'Inter'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
