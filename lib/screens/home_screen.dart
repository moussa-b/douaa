import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/category_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/category_card.dart';
import '../widgets/add_category_dialog.dart';
import 'category_detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isSearching = false;
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
      _searchController.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  void _endSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryListProvider);
    final countsAsync = ref.watch(categoryCountsProvider);
    final isGrid = ref.watch(viewModeProvider);
    final counts = countsAsync.value ?? {};
    final searchQuery = _searchController.text.trim().toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Rechercher une catégorie…',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                onChanged: (_) => setState(() {}),
              )
            : const Text('Douaa'),
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _endSearch,
                tooltip: 'Fermer la recherche',
              )
            : null,
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _searchController.clear();
                setState(() {});
              },
              tooltip: 'Effacer',
            )
          else
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'Rechercher par catégorie',
              onPressed: _startSearch,
            ),
          if (!_isSearching)
            IconButton(
              icon: Icon(isGrid ? Icons.view_list : Icons.grid_view),
              tooltip: isGrid ? 'Passer en liste' : 'Passer en grille',
              onPressed: () {
                ref.read(viewModeProvider.notifier).toggle();
              },
            ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEBFFFD), Colors.white],
          ),
        ),
        child: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
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
          final filtered = searchQuery.isEmpty
              ? categories
              : categories
                  .where((c) =>
                      c.name.toLowerCase().contains(searchQuery))
                  .toList();

          if (filtered.isEmpty) {
            final isSearchNoResults =
                searchQuery.isNotEmpty && categories.isNotEmpty;
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSearchNoResults
                        ? Icons.search_off
                        : Icons.category_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isSearchNoResults
                        ? 'Aucun résultat'
                        : 'Aucune catégorie pour l\'instant',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isSearchNoResults
                        ? 'Aucune catégorie ne correspond à « ${_searchController.text.trim()} »'
                        : 'Appuyez sur + pour créer votre première catégorie',
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
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final category = filtered[index];
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
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final category = filtered[index];
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
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'home_fab',
        onPressed: () => _showAddCategoryDialog(context, ref),
        tooltip: 'Ajouter une catégorie',
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
        title: const Text('Supprimer la catégorie'),
        content: Text(
          'Supprimer « $name » et toutes ses invocations ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(categoryListProvider.notifier).deleteCategory(id);
    }
  }
}
