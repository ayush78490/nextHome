import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/property.dart';

class MiniPropertyCard extends StatelessWidget {
  final Property property;

  const MiniPropertyCard({Key? key, required this.property}) : super(key: key);

  void _navigateToDetails(BuildContext context) {
    context.push(
      '/home/properties/${property.title.replaceAll(' ', '-').toLowerCase()}',
      extra: {
        'title': property.title,
        'address': property.address,
        'price': property.price,
        'beds': property.beds,
        'baths': property.baths,
        'sqft': property.sqft,
        'imageUrls': property.imageUrls,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToDetails(context),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1B365D).withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: property.imageUrls.isNotEmpty ? property.imageUrls.first : '',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => const Icon(Icons.home, color: Colors.white54),
                ),
              ),
            ),
            // Details
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.price,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    property.title,
                    style: const TextStyle(color: Colors.white70, fontSize: 9),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
