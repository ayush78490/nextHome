import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../property/domain/entities/property.dart';
import '../../../property/presentation/providers/property_provider.dart';

final totalUsersProvider = FutureProvider<int>((ref) async {
  try {
    final response = await ref.read(dioProvider).get('/admin/users/count');
    return (response.data['count'] as num?)?.toInt() ?? 0;
  } catch (e) {
    return 0;
  }
});

class AdminPage extends ConsumerStatefulWidget {
  const AdminPage({super.key});

  @override
  ConsumerState<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends ConsumerState<AdminPage> with SingleTickerProviderStateMixin {
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
      backgroundColor: const Color(0xFF0F1B2B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('Admin Dashboard', style: TextStyle(color: Colors.white, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go(AppRoutes.home),
        ),
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
      body: userAsync.when(
        data: (user) {
          if (user == null || !user.isAdmin) {
            return const Center(
              child: Text('Unauthorized Access', style: TextStyle(color: Colors.redAccent, fontSize: 18)),
            );
          }
          return Column(
            children: [
              _buildAdminHeader(user),
              const SizedBox(height: 16),
              TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFF42898E),
                labelColor: const Color(0xFF42898E),
                unselectedLabelColor: Colors.white54,
                tabs: const [
                  Tab(text: 'Properties'),
                  Tab(text: 'Statistics'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPropertiesTab(context, ref),
                    _buildStatisticsTab(context, ref),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
      ),
    );
  }

  Widget _buildAdminHeader(UserEntity user) {
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
                const SizedBox(height: 4),
                Text(
                  user.email ?? user.username ?? 'No contact info',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
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
        ],
      ),
    );
  }

  Widget _buildPropertiesTab(BuildContext context, WidgetRef ref) {
    final allProperties = ref.watch(propertyProvider);
    final pendingProperties = allProperties.where((p) => !p.isApproved).toList();
    
    // ignore: avoid_print
    print('DEBUG ADMIN PAGE: allProperties.length = ${allProperties.length}, pendingProperties.length = ${pendingProperties.length}');

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(propertyProvider);
      },
      child: pendingProperties.isEmpty
          ? ListView(
              children: const [
                SizedBox(height: 100),
                Center(
                  child: Text('No pending properties.', style: TextStyle(color: Colors.white54)),
                ),
              ],
            )
          : ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: pendingProperties.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final prop = pendingProperties[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: prop.imageUrls.isNotEmpty ? prop.imageUrls.first : 'https://via.placeholder.com/150',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
                        width: 80, height: 80, color: Colors.white10,
                        child: const Icon(Icons.broken_image, color: Colors.white54),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(prop.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('\$${prop.price}/mo', style: const TextStyle(color: Color(0xFFC78842), fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(prop.address, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.withOpacity(0.2),
                        foregroundColor: Colors.green,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        ref.read(propertyProvider.notifier).approveProperty(prop.id);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Property Approved'), backgroundColor: Colors.green));
                      },
                      child: const Text('Approve'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent.withOpacity(0.2),
                        foregroundColor: Colors.redAccent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        ref.read(propertyProvider.notifier).rejectProperty(prop.id);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Property Rejected'), backgroundColor: Colors.red));
                      },
                      child: const Text('Reject'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ),
  );
}

  Widget _buildStatisticsTab(BuildContext context, WidgetRef ref) {
    final allProperties = ref.watch(propertyProvider);
    final approvedCount = allProperties.where((p) => p.isApproved).length;
    final pendingCount = allProperties.where((p) => !p.isApproved).length;
    final totalUsersAsync = ref.watch(totalUsersProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(propertyProvider);
        ref.invalidate(totalUsersProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Approved Properties',
                    approvedCount.toString(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: totalUsersAsync.when(
                    data: (count) => _buildStatCard(
                      'Total Users',
                      count.toString(),
                    ),
                    loading: () => _buildStatCard('Total Users', '...'),
                    error: (_, __) => _buildStatCard('Total Users', 'Err'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Pending Properties',
                    pendingCount.toString(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Total Properties',
                    allProperties.length.toString(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
