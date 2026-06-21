import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexthome/core/router/app_router.dart';

import '../../../../core/widgets/next_home_logo.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/property/domain/entities/property.dart';
import '../../../../features/property/presentation/providers/property_provider.dart';
import '../../../../features/property/presentation/widgets/mini_property_card.dart';
import '../../../../features/property/presentation/widgets/property_card.dart';

/// Checks if the user is authenticated before navigating to List Property.
/// If not logged in, shows a dialog prompting the user to sign in first.
Future<void> _guardedNavToListProperty(BuildContext context, WidgetRef ref) async {
  final repo = ref.read(authRepositoryProvider);
  final isLoggedIn = await repo.isAuthenticated();

  if (!context.mounted) return;

  if (isLoggedIn) {
    context.push(AppRoutes.listProperty);
  } else {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B2D42),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF42898E).withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.lock_outline_rounded, color: Color(0xFF42898E), size: 32),
        ),
        title: const Text(
          'Login Required',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: const Text(
          'You need to be logged in to list a property.\nSign in to get started!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Maybe Later', style: TextStyle(color: Colors.white54)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              final router = GoRouter.of(ctx);
              Navigator.pop(ctx);
              router.push('${AppRoutes.welcome}?next=${AppRoutes.listProperty}');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF42898E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1B2B),
      endDrawer: const _HomeDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(context, ref),
            const SizedBox(height: 20),
            _buildFeaturedProperties(context, ref),
            const SizedBox(height: 30),
            _buildCategoryGrids(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, WidgetRef ref) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // Background Gradient & Image
        Padding(
          padding: const EdgeInsets.only(bottom: 25.0),
          child: Container(
            height: 460,
            width: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
              gradient: LinearGradient(
                colors: [Color(0xFF2E6B75), Color(0xFF1B365D)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
              child: Opacity(
                opacity: 0.15,
                child: CachedNetworkImage(
                  imageUrl:
                      'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&w=800&q=80',
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(color: Colors.transparent),
                ),
              ),
            ),
          ),
        ),

        SafeArea(
          child: Column(
            children: [
              // Top Nav Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    // Logo
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/hero_logo.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Links
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (MediaQuery.of(context).size.width >= 600) {
                          return Row(
                            children: [
                              const Text('Rent',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () => _guardedNavToListProperty(context, ref),
                                child: const Text('List Your Home',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600)),
                              ),
                              const SizedBox(width: 12),
                              const Text('About',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(width: 16),
                              // Login Button
                              GestureDetector(
                                onTap: () => context.push(AppRoutes.welcome),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF42898E),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text('Login/Sign Up',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Builder(
                            builder: (context) => IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(Icons.menu, color: Colors.white),
                              onPressed: () {
                                Scaffold.of(context).openEndDrawer();
                              },
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Title
              const Text(
                'Find Your Perfect\nHome. Today.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),

              // Subtitle
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  'Seamless home rentals across the country.\nSimple, transparent, and always Next.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Search city, address, or neighborhood',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),

        // Overlapping Filter Cards
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildCategoryChip(context, 'Flats', Icons.apartment, true),
                _buildCategoryChip(context, 'Single Room', Icons.meeting_room, false),
                _buildCategoryChip(context, 'Kothi', Icons.house_siding, false),
                _buildCategoryChip(context, 'Villas', Icons.villa, false),
                _buildCategoryChip(context, 'Penthouse', Icons.business, false),
                _buildCategoryChip(context, 'Studio', Icons.deck, false),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(BuildContext context, String title, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () {
        context.push('/category/${title.replaceAll(' ', '-').toLowerCase()}', extra: title);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFC78842) : const Color(0xFF1B365D),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
              color: isSelected ? Colors.transparent : const Color(0xFF42898E), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style:
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrids(BuildContext context, WidgetRef ref) {
    final categoriesMap = ref.watch(propertiesByCategoryProvider);

    return Column(
      children: categoriesMap.entries.map((entry) {
        final categoryName = entry.key;
        final properties = entry.value.take(12).toList(); // Up to 12 items for 3x4 grid

        if (properties.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                categoryName,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                padding: EdgeInsets.zero, // Remove default padding
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.75, // Adjust based on MiniPropertyCard
                ),
                itemCount: properties.length,
                itemBuilder: (context, index) {
                  return MiniPropertyCard(property: properties[index]);
                },
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    context.push('/category/${categoryName.replaceAll(' ', '-').toLowerCase()}',
                        extra: categoryName);
                  },
                  icon: const Text('Explore More', style: TextStyle(color: Color(0xFFC78842))),
                  label: const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFFC78842)),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFeaturedProperties(BuildContext context, WidgetRef ref) {
    final properties = ref.watch(approvedPropertiesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            'Featured Properties',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 380,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: properties.length,
            itemBuilder: (context, index) {
              return PropertyCard(property: properties[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHowItWorksSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2B42),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF42898E).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How It Works',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepItem('1. Search', 'Search yours\nsearch for liatting.'),
              const SizedBox(width: 8),
              _buildStepItem('2. Book Tour', 'Book your ness tour\ntour this meeting.'),
              const SizedBox(width: 8),
              _buildStepItem('3. Rent', 'Rent sent your home\nwith any payment.'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(String title, String subtitle) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: Colors.white70, height: 1.3),
          ),
        ],
      ),
    );
  }
}

class _HomeDrawer extends ConsumerStatefulWidget {
  const _HomeDrawer({super.key});

  @override
  ConsumerState<_HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends ConsumerState<_HomeDrawer> {
  String _selectedMenu = '';

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap) {
    final isSelected = _selectedMenu == title;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedMenu = title;
          });
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF42898E) : const Color(0xFF1B365D).withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFF42898E) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.white70, size: 20),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);
    final isLoggedIn = userAsync.valueOrNull != null;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.65,
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          bottomLeft: Radius.circular(40),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            color: const Color(0xFF0F1B2B).withValues(alpha: 0.85),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: [
                        Icon(Icons.home_outlined, color: Colors.white, size: 28),
                        SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Next',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    height: 1.0)),
                            Text('Home',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    height: 1.0)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildMenuItem('Rent', Icons.search, () {
                    Future.delayed(const Duration(milliseconds: 200), () {
                      if (context.mounted) context.pop();
                    });
                  }),
                  if (userAsync.valueOrNull?.isAdmin != true)
                    _buildMenuItem('List Your Home', Icons.add_home_work_outlined, () {
                      Future.delayed(const Duration(milliseconds: 200), () {
                        if (context.mounted) {
                          context.pop();
                          _guardedNavToListProperty(context, ref);
                        }
                      });
                    }),
                  _buildMenuItem('Profile', Icons.person_outline, () {
                    Future.delayed(const Duration(milliseconds: 200), () {
                      if (context.mounted) {
                        context.pop();
                        if (userAsync.valueOrNull?.isAdmin == true) {
                          context.push(AppRoutes.admin);
                        } else {
                          context.push(AppRoutes.profile);
                        }
                      }
                    });
                  }),
                  _buildMenuItem('About', Icons.info_outline, () {
                    Future.delayed(const Duration(milliseconds: 200), () {
                      if (context.mounted) context.pop();
                    });
                  }),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: InkWell(
                      onTap: () {
                        context.pop(); // close drawer
                        if (isLoggedIn) {
                          ref.read(authProvider.notifier).signOut();
                        } else {
                          context.push(AppRoutes.welcome);
                        }
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: isLoggedIn ? Colors.redAccent : const Color(0xFFC78842),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: (isLoggedIn ? Colors.redAccent : const Color(0xFFC78842)).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(isLoggedIn ? 'Logout' : 'Login / Sign Up',
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
