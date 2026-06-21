import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/next_home_logo.dart';
import '../widgets/auth_background.dart';

class WelcomePage extends StatelessWidget {
  final String? nextRoute;
  
  const WelcomePage({super.key, this.nextRoute});

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 100),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.0),
            child: NextHomeLogo(size: 80),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'Welcome Back!',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: const Color(0xFF0F1B2B),
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'Enter personal details to access your account',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF4A5568),
                    height: 1.5,
                  ),
            ),
          ),
          const Spacer(),
          // Bottom action row matching the screenshot
          Container(
            padding: const EdgeInsets.only(left: 32.0, right: 0, bottom: 0),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      final url = nextRoute != null ? '${AppRoutes.login}?next=$nextRoute' : AppRoutes.login;
                      context.push(url);
                    },
                    child: Container(
                      height: 80,
                      color: Colors.transparent, // expand tap area
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Sign in',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF0F1B2B),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      final url = nextRoute != null ? '${AppRoutes.register}?next=$nextRoute' : AppRoutes.register;
                      context.push(url);
                    },
                    child: Container(
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Sign up',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF4B81E1),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
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
}
