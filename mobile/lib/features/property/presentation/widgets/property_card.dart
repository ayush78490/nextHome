import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/property.dart';
import '../providers/property_provider.dart';

class PropertyCard extends ConsumerStatefulWidget {
  final Property property;

  const PropertyCard({
    Key? key,
    required this.property,
  }) : super(key: key);

  @override
  ConsumerState<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends ConsumerState<PropertyCard> {
  int _currentIndex = 0;

  void _navigateToDetails(BuildContext context) {
    context.push(
      '/home/properties/${widget.property.title.replaceAll(' ', '-').toLowerCase()}',
      extra: {
        'title': widget.property.title,
        'address': widget.property.address,
        'price': widget.property.price,
        'beds': widget.property.beds,
        'baths': widget.property.baths,
        'sqft': widget.property.sqft,
        'imageUrls': widget.property.imageUrls,
      },
    );
  }

  Widget _buildAmenity(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 14),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToDetails(context),
      child: Container(
        width: 280,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background Image Carousel
            PageView.builder(
              itemCount: widget.property.imageUrls.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                  imageUrl: widget.property.imageUrls[index],
                  height: 380,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => const Center(child: Icon(Icons.error, color: Colors.white)),
                );
              },
            ),
            
            // Top Left Price
            Positioned(
              top: 16,
              left: 16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.white.withOpacity(0.2),
                    child: Text(
                      widget.property.price,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
              ),
            ),
            
            // Top Right Favorite Icon
            Positioned(
              top: 16,
              right: 16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: GestureDetector(
                    onTap: () {
                      ref.read(propertyProvider.notifier).toggleInterest(widget.property.id);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.white.withOpacity(0.2),
                      child: Icon(
                        widget.property.isInterested ? Icons.favorite : Icons.favorite_border, 
                        color: widget.property.isInterested ? Colors.red : Colors.white, 
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Bottom Glass Container
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.9),
                      Colors.black.withOpacity(0.6),
                      Colors.black.withOpacity(0.0),
                    ],
                  ),
                ),
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      color: Colors.white.withOpacity(0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Dots indicator mock
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(
                                  widget.property.imageUrls.length,
                                  (index) => Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 2),
                                    width: _currentIndex == index ? 12 : 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: _currentIndex == index ? Colors.white : Colors.white54,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Title
                          Text(
                            widget.property.title,
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          
                          // Location
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, color: Colors.white70, size: 14),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.property.address,
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          // Amenities
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildAmenity(Icons.bed_outlined, widget.property.beds),
                              _buildAmenity(Icons.bathtub_outlined, widget.property.baths),
                              _buildAmenity(Icons.crop_square, widget.property.sqft),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Reserve Button
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.edit_note, color: Colors.black, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Reserve',
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
