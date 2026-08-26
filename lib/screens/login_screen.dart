import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../widgets/logo_widget.dart';
import '../widgets/bottom_wave_painter.dart';
import '../widgets/custom_text_field.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _rememberMe = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    // ScaffoldMessenger alert feedback for testing the interactive button
    final username = _usernameController.text;
    final password = _passwordController.text;
    
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan isi Username dan Password terlebih dahulu.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Login berhasil untuk: $username'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          children: [
            // Scrollable Content
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Space above logo
                      SizedBox(height: screenHeight * 0.12),
                      
                      Image.asset(
                        'assets/images/LogoRev.png',
                        width: screenWidth * 0.38 * 1.5,
                        fit: BoxFit.contain,
                      ),
                      
                      SizedBox(height: screenHeight * 0.04),
                      
                      // Heading
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
                      
                      // Subtitle
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
                      
                      // Form Fields
                      CustomTextField(
                        hintText: 'Username',
                        controller: _usernameController,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      CustomTextField(
                        hintText: 'Password',
                        obscureText: true,
                        controller: _passwordController,
                      ),
                      
                      const SizedBox(height: 14),
                      
                      // Remember Me Checkbox
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Theme(
                            data: ThemeData(
                              unselectedWidgetColor: const Color(0xFFCCCCCC),
                            ),
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
                                activeColor: const Color(0xFF001AFF), // Blue matching screenshot
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
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
                      
                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF001AFF), // Blue color from screenshot
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
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
                      
                      // Spacer to ensure nothing gets cut off by bottom waves
                      const SizedBox(height: 220),
                    ],
                  ),
                ),
              ),
            ),
            
            // Bottom Wave with "Don't have an account? Contact Us"
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                ignoring: false, // Make sure clicks inside the child are registered
                child: BottomWaveWidget(
                  height: 200,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      children: [
                        const TextSpan(text: "Don't have an account? "),
                        TextSpan(
                          text: 'Contact Us',
                          style: const TextStyle(
                            color: Color(0xFFFF001F), // Red text from screenshot
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Hubungi admin/konsultan untuk pendaftaran.'),
                                ),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
