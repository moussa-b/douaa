import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/category_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/category_card.dart';
import '../widgets/add_category_dialog.dart';
import 'category_detail_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryListProvider);
    final countsAsync = ref.watch(categoryCountsProvider);
    final isGrid = ref.watch(viewModeProvider);
    final counts = countsAsync.value ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Douaa'),
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
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error: $error'),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => ref.invalidate(categoryListProvider),
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
                    Icons.category_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No categories yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to create your first category',
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
                  onTap: () => _openCategory(context, category.id!, category.name),
                  onLongPress: () =>
                      _showDeleteDialog(context, ref, category.id!, category.name),
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
                onTap: () => _openCategory(context, category.id!, category.name),
                onLongPress: () =>
                    _showDeleteDialog(context, ref, category.id!, category.name),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'home_fab',
        onPressed: () => _showAddCategoryDialog(context, ref),
        tooltip: 'Add Category',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openCategory(BuildContext context, int categoryId, String categoryName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CategoryDetailScreen(
          categoryId: categoryId,
          categoryName: categoryName,
        ),
      ),
    );
  }

  Future<void> _showAddCategoryDialog(BuildContext context, WidgetRef ref) async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => const AddCategoryDialog(),
    );
    if (name != null && name.isNotEmpty) {
      await ref.read(categoryListProvider.notifier).addCategory(name);
    }
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    int id,
    String name,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
          'Delete "$name" and all its douaa? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(categoryListProvider.notifier).deleteCategory(id);
    }
  }
}
