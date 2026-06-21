import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/next_home_logo.dart';
import '../widgets/auth_background.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  final String? nextRoute;
  
  const LoginPage({super.key, this.nextRoute});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _usernameOrEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameOrEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(authProvider, (previous, next) {
      next.when(
        data: (_) {
          if (previous?.isLoading == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login successful!', style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            final user = ref.read(userProvider).valueOrNull;
            if (user != null && user.isAdmin) {
              context.go(AppRoutes.admin);
            } else if (widget.nextRoute != null && widget.nextRoute!.isNotEmpty) {
              context.go(widget.nextRoute!);
            } else {
              context.go(AppRoutes.home);
            }
          }
        },
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(error.toString(), style: const TextStyle(color: Colors.white)),
                backgroundColor: Colors.red),
          );
        },
        loading: () {},
      );
    });

    final isLoading = ref.watch(authProvider).isLoading;

    return AuthBackground(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // Back Button
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF0F1B2B)),
                      onPressed: () => context.pop(),
                    ),
                    const Spacer(),
                    // Main Form Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Center(child: NextHomeLogo(size: 60)),
                          const SizedBox(height: 24),
                          Text(
                            'Welcome back',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: const Color(0xFF4B81E1),
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 32),

                          // Email or Username Field
                          _buildTextField('Email or Username', _usernameOrEmailController, false),
                          const SizedBox(height: 16),

                          // Password Field
                          _buildTextField('Password', _passwordController, true),
                          const SizedBox(height: 16),

                          // Remember me & Forgot Password
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      activeColor: const Color(0xFF4B81E1),
                                      onChanged: (val) {
                                        setState(() {
                                          _rememberMe = val ?? false;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Remember me',
                                    style: TextStyle(color: Colors.black54, fontSize: 13),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () => context.push(AppRoutes.forgotPassword),
                                child: const Text(
                                  'Forgot password?',
                                  style: TextStyle(
                                    color: Color(0xFF4B81E1),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Sign In Button
                          ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    final usernameOrEmail = _usernameOrEmailController.text.trim();
                                    final password = _passwordController.text.trim();
                                    if (usernameOrEmail.isEmpty || password.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Please enter your email/username and password.')),
                                      );
                                      return;
                                    }
                                    await ref.read(authProvider.notifier).loginWithUsernameOrEmail(usernameOrEmail, password);
                                    ref.invalidate(userProvider);
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4B81E1),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Sign in',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Divider
                          Row(
                            children: const [
                              Expanded(child: Divider(color: Colors.black12)),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text('Sign in with',
                                    style: TextStyle(color: Colors.black38, fontSize: 12)),
                              ),
                              Expanded(child: Divider(color: Colors.black12)),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Social Buttons (Only Google and Apple as requested)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildSocialButton(
                                'assets/icons/google.png',
                                Icons.g_mobiledata,
                                onTap: isLoading
                                    ? null
                                    : () => ref.read(authProvider.notifier).loginWithGoogle(),
                              ),
                              const SizedBox(width: 24),
                              _buildSocialButton('assets/icons/apple.png', Icons.apple),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Sign Up link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have an account? ",
                                  style: TextStyle(color: Colors.black54, fontSize: 13)),
                              GestureDetector(
                                onTap: () => context.pushReplacement(AppRoutes.register),
                                child: const Text(
                                  'Sign up',
                                  style: TextStyle(
                                    color: Color(0xFF4B81E1),
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, bool isPassword) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword ? _obscurePassword : false,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          decoration: InputDecoration(
            hintText: isPassword ? '••••••••••' : 'username or email',
            hintStyle: const TextStyle(color: Colors.black26),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.black54,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  )
                : null,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4B81E1)),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton(String asset, IconData fallbackIcon, {VoidCallback? onTap}) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(fallbackIcon, size: 28, color: Colors.black87),
        ));
  }
}
