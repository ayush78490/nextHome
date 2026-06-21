import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/property_provider.dart';
import '../widgets/property_card.dart';

class CategoryPage extends ConsumerWidget {
  final String categoryName;

  const CategoryPage({Key? key, required this.categoryName}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesMap = ref.watch(propertiesByCategoryProvider);
    // Find the category matching the name (case insensitive for safety)
    final actualCategoryKey = categoriesMap.keys.firstWhere(
      (k) => k.toLowerCase() == categoryName.toLowerCase(),
      orElse: () => categoryName,
    );
    
    final properties = categoriesMap[actualCategoryKey] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFF0F1B2B), // Match app theme
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B365D),
        elevation: 0,
        title: Text(
          actualCategoryKey,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          if (properties.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  'No properties available in $actualCategoryKey',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 280 / 380, // Match exact ratio of PropertyCard
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return FittedBox(
                      fit: BoxFit.contain,
                      child: SizedBox(
                        width: 280,
                        height: 380,
                        child: PropertyCard(property: properties[index]),
                      ),
                    );
                  },
                  childCount: properties.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
