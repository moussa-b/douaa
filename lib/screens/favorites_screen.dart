import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/category_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/category_card.dart';
import 'category_detail_screen.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
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
    final favCategoriesAsync = ref.watch(favoriteCategoriesProvider);
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
            : const Text('Favoris'),
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
        child: favCategoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Erreur : $error'),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => ref.invalidate(favoriteCategoriesProvider),
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
                        : Icons.favorite_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isSearchNoResults
                        ? 'Aucun résultat'
                        : 'Aucun favori pour l\'instant',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isSearchNoResults
                        ? 'Aucune catégorie ne correspond à « ${_searchController.text.trim()} »'
                        : 'Marquez des invocations en favori pour les voir ici',
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
                  invokedCount: c?.invokedCount,
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
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final category = filtered[index];
              final c = category.id != null ? counts[category.id] : null;
              return CategoryCard(
                category: category,
                isGrid: false,
                subCategoryCount: c?.subCount,
                douaaCount: c?.douaaCount,
                invokedCount: c?.invokedCount,
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
