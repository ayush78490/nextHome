import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/auth/domain/entities/user_entity.dart';

import '../../../../features/property/domain/entities/property.dart';
import '../../../../features/property/domain/entities/reservation.dart';
import '../../../../features/property/presentation/providers/property_provider.dart';
import '../../../../features/property/presentation/widgets/property_card.dart';
import '../../../../features/property/presentation/pages/list_property_page.dart';
import 'edit_profile_page.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1B2B), // Match dark theme
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1B2B),
        elevation: 0,
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              ref.read(authProvider.notifier).signOut();
              context.go(AppRoutes.welcome);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Profile Header
          userAsync.when(
            data: (user) {
              if (user == null) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: Text('Not logged in', style: TextStyle(color: Colors.white))),
                );
              }
              return _buildProfileHeader(user);
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
          ),
          
          const SizedBox(height: 16),
          
          TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFF42898E),
            labelColor: const Color(0xFF42898E),
            unselectedLabelColor: Colors.white54,
            tabs: const [
              Tab(text: 'Interested'),
              Tab(text: 'My Listings'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInterestedTab(context, ref),
                _buildMyListingsTab(context, ref),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UserEntity user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white10,
            backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                ? CachedNetworkImageProvider(user.avatarUrl!)
                : null,
            child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                ? const Icon(Icons.person, size: 36, color: Colors.white54)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                if (user.email != null && user.email!.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.email, size: 14, color: Colors.white54),
                      const SizedBox(width: 6),
                      Text(
                        user.email!,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  )
                else if (user.username != null && user.username!.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.alternate_email, size: 14, color: Colors.white54),
                      const SizedBox(width: 6),
                      Text(
                        user.username!,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                if (user.phone != null && user.phone!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 14, color: Colors.white54),
                      const SizedBox(width: 6),
                      Text(
                        user.phone!,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF42898E).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    user.role.toUpperCase(),
                    style: const TextStyle(color: Color(0xFF42898E), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFFC78842)),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (context) => EditProfilePage(user: user),
              ));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInterestedTab(BuildContext context, WidgetRef ref) {
    final interestedProperties = ref.watch(interestedPropertiesProvider);

    if (interestedProperties.isEmpty) {
      return const Center(
        child: Text(
          'No interested properties yet.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: interestedProperties.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: SizedBox(
            height: 380, // Same height as Home Page
            child: PropertyCard(property: interestedProperties[index]),
          ),
        );
      },
    );
  }

  Widget _buildMyListingsTab(BuildContext context, WidgetRef ref) {
    final myListings = ref.watch(myListingsProvider);

    if (myListings.isEmpty) {
      return const Center(
        child: Text(
          'You have no property listings.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myListings.length,
      itemBuilder: (context, index) {
        return _MyListingCard(property: myListings[index]);
      },
    );
  }
}

class _MyListingCard extends ConsumerWidget {
  final Property property;

  const _MyListingCard({Key? key, required this.property}) : super(key: key);

  void _showRescheduleDialog(BuildContext context, WidgetRef ref, Reservation reservation) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B365D),
          title: const Text('Reschedule', style: TextStyle(color: Colors.white)),
          content: Text(
            'Reschedule appointment for ${reservation.name}?',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC78842)),
              onPressed: () {
                // In a real app, this would open a DatePicker
                final newTime = reservation.visitingTime.add(const Duration(days: 1));
                ref.read(propertyProvider.notifier).updateReservationStatus(
                  property.id, 
                  reservation.id, 
                  ReservationStatus.rescheduled,
                  newTime: newTime,
                );
                Navigator.of(context).pop();
              },
              child: const Text('Confirm (+1 Day)'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: const Color(0xFF1B365D).withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Listing Header
          ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: property.imageUrls.isNotEmpty ? property.imageUrls.first : '',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => const Icon(Icons.home, color: Colors.white),
              ),
            ),
            title: Text(property.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text(property.address, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            trailing: Switch(
              value: property.isAvailable,
              activeColor: const Color(0xFF42898E),
              onChanged: (val) {
                ref.read(propertyProvider.notifier).toggleAvailability(property.id);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  property.isAvailable ? 'Status: Available' : 'Status: Sold Out',
                  style: TextStyle(
                    color: property.isAvailable ? const Color(0xFF42898E) : Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ListPropertyPage(existingProperty: property),
                    ));
                  },
                  icon: const Icon(Icons.edit, size: 16, color: Color(0xFFC78842)),
                  label: const Text('Edit Property', style: TextStyle(color: Color(0xFFC78842))),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Reservations Dropdown
          ExpansionTile(
            iconColor: Colors.white,
            collapsedIconColor: Colors.white54,
            title: Text(
              'Reserved Users (${property.reservations.length})',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            children: property.reservations.map((res) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(res.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        _buildStatusBadge(res.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.phone, color: Colors.white54, size: 14),
                        const SizedBox(width: 8),
                        Text(res.phone, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.email, color: Colors.white54, size: 14),
                        const SizedBox(width: 8),
                        Text(res.email, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.white54, size: 14),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('MMM dd, yyyy - hh:mm a').format(res.visitingTime),
                          style: const TextStyle(color: const Color(0xFFC78842), fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Actions
                    if (res.status == ReservationStatus.pending || res.status == ReservationStatus.rescheduled)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white24),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () => _showRescheduleDialog(context, ref, res),
                              child: const Text('Reschedule', style: TextStyle(fontSize: 12)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF42898E),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {
                                ref.read(propertyProvider.notifier).updateReservationStatus(
                                  property.id, 
                                  res.id, 
                                  ReservationStatus.accepted,
                                );
                              },
                              child: const Text('Accept', style: TextStyle(fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ReservationStatus status) {
    Color bgColor;
    String text;

    switch (status) {
      case ReservationStatus.accepted:
        bgColor = Colors.green;
        text = 'Accepted';
        break;
      case ReservationStatus.declined:
        bgColor = Colors.redAccent;
        text = 'Declined';
        break;
      case ReservationStatus.rescheduled:
        bgColor = Colors.orange;
        text = 'Rescheduled';
        break;
      case ReservationStatus.pending:
      default:
        bgColor = Colors.grey;
        text = 'Pending';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: bgColor.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(color: bgColor, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
