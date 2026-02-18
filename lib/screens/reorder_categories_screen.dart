import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../providers/category_provider.dart';

class ReorderCategoriesScreen extends ConsumerWidget {
  const ReorderCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ordre des catégories'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Erreur : $error'),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => ref.invalidate(categoryListProvider),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
        data: (categories) {
          if (categories.isEmpty) {
            return Center(
              child: Text(
                'Aucune catégorie',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            );
          }

          return ReorderableListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            buildDefaultDragHandles: true,
            itemCount: categories.length,
            onReorder: (oldIndex, newIndex) {
              final newList = List<Category>.from(categories);
              final item = newList.removeAt(oldIndex);
              if (newIndex > oldIndex) newIndex--;
              newList.insert(newIndex, item);
              ref
                  .read(categoryListProvider.notifier)
                  .reorderCategories(newList);
            },
            itemBuilder: (context, index) {
              final category = categories[index];
              return ListTile(
                key: ValueKey(category.id),
                leading: ReorderableDragStartListener(
                  index: index,
                  child: Icon(
                    Icons.drag_handle,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                title: Text(
                  category.name,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
