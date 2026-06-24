import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

class PropertyDetailsPage extends StatefulWidget {
  final Map<String, dynamic> propertyData;

  const PropertyDetailsPage({super.key, required this.propertyData});

  @override
  State<PropertyDetailsPage> createState() => _PropertyDetailsPageState();
}

class _PropertyDetailsPageState extends State<PropertyDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openFullScreenGallery(BuildContext context, int initialIndex, List<String> imageUrls) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Gallery',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(color: Colors.black.withOpacity(0.2)),
                ),
              ),
              Positioned(
                top: 50,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: PageView.builder(
                      controller: PageController(initialPage: initialIndex),
                      itemCount: imageUrls.length,
                      itemBuilder: (context, index) {
                        return CachedNetworkImage(
                          imageUrl: imageUrls[index],
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator(color: Colors.white)),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[800],
                            child: const Icon(Icons.broken_image, color: Colors.white54),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.propertyData['title']?.toString() ?? 'Unknown';
    final address = widget.propertyData['address']?.toString() ?? 'Unknown Location';
    final price = widget.propertyData['price']?.toString() ?? '\$0/mo';
    final beds = widget.propertyData['beds']?.toString() ?? '';
    final baths = widget.propertyData['baths']?.toString() ?? '';
    final sqft = widget.propertyData['sqft']?.toString() ?? '';
    final imageUrls =
        (widget.propertyData['imageUrls'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
            [];
    final description =
        widget.propertyData['description']?.toString() ?? 'No description provided.';
    final facilities =
        (widget.propertyData['facilities'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
            [];
    final locality = widget.propertyData['locality']?.toString() ?? 'Unknown locality.';

    return Scaffold(
      backgroundColor: const Color(0xFF0F1B2B), // Dark theme
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Hero Image Section
              SliverToBoxAdapter(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 350,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
                        child: imageUrls.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: imageUrls[_selectedImageIndex],
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[800],
                                  child: const Icon(Icons.image_not_supported,
                                      color: Colors.white54, size: 50),
                                ),
                              )
                            : Container(color: Colors.grey),
                      ),
                    ),

                    // Top App Bar Icons
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildCircularIconButton(Icons.arrow_back, () => context.pop()),
                            Row(
                              children: [
                                _buildCircularIconButton(Icons.share_outlined, () {}),
                                const SizedBox(width: 12),
                                _buildCircularIconButton(Icons.favorite_border, () {}),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Overlapping Gallery Thumbnails
                    Positioned(
                      bottom: -35,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(
                                  imageUrls.length > 5 ? 5 : imageUrls.length,
                                  (index) {
                                    bool isLast = index == 4 && imageUrls.length > 5;
                                    return GestureDetector(
                                      onTap: () {
                                        if (index < imageUrls.length) {
                                          setState(() {
                                            _selectedImageIndex = index;
                                          });
                                        }
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 4),
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          border: _selectedImageIndex == index
                                              ? Border.all(color: const Color(0xFF42898E), width: 2)
                                              : null,
                                          image: DecorationImage(
                                            image: CachedNetworkImageProvider(
                                              imageUrls[index],
                                              errorListener: (err) {},
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        child: isLast
                                            ? Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.black.withOpacity(0.5),
                                                  borderRadius: BorderRadius.circular(
                                                      10), // inner radius slightly smaller
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  '+${imageUrls.length - 4}',
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold),
                                                ),
                                              )
                                            : null,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Spacer for thumbnails
              const SliverToBoxAdapter(child: SizedBox(height: 50)),

              // Title and Details Section
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC78842).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '20% Off',
                          style: TextStyle(
                              color: Color(0xFFC78842), fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Title & Location Button
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  address,
                                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Color(0xFF42898E),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.near_me, color: Colors.white, size: 24),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Tabs
                      TabBar(
                        controller: _tabController,
                        indicatorColor: const Color(0xFF42898E),
                        labelColor: const Color(0xFF42898E),
                        unselectedLabelColor: Colors.white54,
                        dividerColor: Colors.white10,
                        tabs: const [
                          Tab(text: 'About'),
                          Tab(text: 'Gallery'),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // About Content
                      if (_tabController.index == 0) ...[
                        // Quick Stats
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildQuickStat(Icons.bed, beds),
                            _buildQuickStat(Icons.bathtub, baths),
                            _buildQuickStat(Icons.square_foot, sqft),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Description
                        const Text(
                          'Description',
                          style: TextStyle(
                              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          description,
                          style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                        ),
                        const SizedBox(height: 24),

                        // Facilities
                        if (facilities.isNotEmpty) ...[
                          const Text(
                            'Facilities',
                            style: TextStyle(
                                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: facilities
                                .map((f) => _buildFacilityChip(Icons.check_circle_outline, f))
                                .toList(),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Locality
                        if (locality.isNotEmpty) ...[
                          const Text(
                            'Locality',
                            style: TextStyle(
                                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          _buildLocalityItem(Icons.place, locality, ''),
                          const SizedBox(height: 100), // Bottom padding for fixed action bar
                        ],
                      ] else ...[
                        // Gallery Tab
                        SizedBox(
                          height: 300,
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: imageUrls.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () => _openFullScreenGallery(context, index, imageUrls),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl: imageUrls[index],
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) => Container(
                                      color: Colors.grey[800],
                                      child: const Icon(Icons.broken_image, color: Colors.white54),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom Action Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2B42), // Darker bottom bar
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, -5)),
                ],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Total Price',
                            style: TextStyle(color: Colors.white54, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(price,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Spacer(),

                    // Chat Button
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                        onPressed: () {},
                      ),
                    ),

                    // Action Buttons
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.1),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                elevation: 0,
                              ),
                              onPressed: () {},
                              child: const Text('Visit',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF42898E),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                elevation: 0,
                              ),
                              onPressed: () {},
                              child: const Text('Book',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white.withOpacity(0.2),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStat(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF42898E), size: 20),
        const SizedBox(width: 8),
        Text(value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildFacilityChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFC78842), size: 18),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildLocalityItem(IconData icon, String title, String distance) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF42898E), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(distance, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
