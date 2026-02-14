import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/category_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/category_card.dart';
import 'category_detail_screen.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favCategoriesAsync = ref.watch(favoriteCategoriesProvider);
    final countsAsync = ref.watch(categoryCountsProvider);
    final isGrid = ref.watch(viewModeProvider);
    final counts = countsAsync.value ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: [
          IconButton(
            icon: Icon(isGrid ? Icons.view_list : Icons.grid_view),
            tooltip: isGrid ? 'Switch to list' : 'Switch to grid',
            onPressed: () {
              ref.read(viewModeProvider.notifier).toggle();
            },
          ),
        ],
      ),
      body: favCategoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error: $error'),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => ref.invalidate(favoriteCategoriesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (categories) {
          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mark douaa as favorites to see them here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ],
              ),
            );
          }

          if (isGrid) {
            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.3,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final c = category.id != null ? counts[category.id] : null;
                return CategoryCard(
                  category: category,
                  isGrid: true,
                  subCategoryCount: c?.subCount,
                  douaaCount: c?.douaaCount,
                  onTap: () => _openCategory(
                    context,
                    category.id!,
                    category.name,
                  ),
                );
              },
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final c = category.id != null ? counts[category.id] : null;
              return CategoryCard(
                category: category,
                isGrid: false,
                subCategoryCount: c?.subCount,
                douaaCount: c?.douaaCount,
                onTap: () => _openCategory(
                  context,
                  category.id!,
                  category.name,
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _openCategory(BuildContext context, int categoryId, String categoryName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CategoryDetailScreen(
          categoryId: categoryId,
          categoryName: categoryName,
          favoritesOnly: true,
        ),
      ),
    );
  }
}
