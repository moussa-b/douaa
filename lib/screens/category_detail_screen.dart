import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_helper.dart';
import '../models/douaa.dart';
import '../providers/douaa_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/douaa_card.dart';
import 'douaa_form_screen.dart';

class CategoryDetailScreen extends ConsumerStatefulWidget {
  final int categoryId;
  final String categoryName;
  final bool favoritesOnly;

  const CategoryDetailScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    this.favoritesOnly = false,
  });

  @override
  ConsumerState<CategoryDetailScreen> createState() =>
      _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends ConsumerState<CategoryDetailScreen> {
  List<Douaa>? _favoriteDouaaList;
  bool _loadingFavorites = true;

  @override
  void initState() {
    super.initState();
    if (widget.favoritesOnly) {
      _loadFavorites();
    }
  }

  Future<void> _loadFavorites() async {
    final db = DatabaseHelper();
    final list = await db.getFavoriteDouaaByCategory(widget.categoryId);
    if (mounted) {
      setState(() {
        _favoriteDouaaList = list;
        _loadingFavorites = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
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
        child: widget.favoritesOnly
            ? _buildFavoritesBody(settings)
            : _buildAllBody(settings),
      ),
      floatingActionButton: widget.favoritesOnly
          ? null
          : FloatingActionButton(
              heroTag: 'detail_fab',
              onPressed: () => _openDouaaForm(context),
              tooltip: 'Ajouter une invocation',
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _buildAllBody(AppSettings settings) {
    final douaaAsync = ref.watch(douaaListProvider(widget.categoryId));

    return douaaAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Erreur : $error')),
      data: (douaaList) {
        if (douaaList.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.menu_book_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucune invocation pour l\'instant',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Appuyez sur + pour ajouter votre première invocation',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ],
            ),
          );
        }

        return _buildDouaaList(douaaList, settings);
      },
    );
  }

  Widget _buildFavoritesBody(AppSettings settings) {
    if (_loadingFavorites) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_favoriteDouaaList == null || _favoriteDouaaList!.isEmpty) {
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
              'Aucune invocation favorite dans cette catégorie',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      );
    }

    return _buildDouaaList(_favoriteDouaaList!, settings);
  }

  Widget _buildDouaaList(List<Douaa> douaaList, AppSettings settings) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: douaaList.length,
      itemBuilder: (context, index) {
        final douaa = douaaList[index];
        final notifier = ref.read(douaaListProvider(widget.categoryId).notifier);
        return DouaaCard(
          douaa: douaa,
          showReference: settings.showReference,
          showTranslation: settings.showTranslation,
          onFavoriteToggle: () async {
            await notifier.toggleFavorite(douaa.id!, !douaa.isFavorite);
            if (widget.favoritesOnly) {
              await _loadFavorites();
            }
          },
          onEditTap: () => _openDouaaForm(context, douaa: douaa),
          onDecrementCount: () async {
            final newCount = (douaa.readCount - 1).clamp(0, 0x7FFFFFFF);
            await notifier.updateReadCount(douaa.id!, newCount);
            if (widget.favoritesOnly) {
              await _loadFavorites();
            }
          },
          onIncrementCount: () async {
            await notifier.updateReadCount(douaa.id!, douaa.readCount + 1);
            if (widget.favoritesOnly) {
              await _loadFavorites();
            }
          },
          onDismissed: () async {
            await notifier.deleteDouaa(douaa.id!);
            if (widget.favoritesOnly) {
              await _loadFavorites();
            }
          },
        );
      },
    );
  }

  Future<void> _openDouaaForm(BuildContext context, {Douaa? douaa}) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => DouaaFormScreen(
          categoryId: widget.categoryId,
          douaa: douaa,
        ),
      ),
    );
    if (result == true) {
      ref.invalidate(douaaListProvider(widget.categoryId));
      ref.invalidate(favoriteCategoriesProvider);
      if (widget.favoritesOnly) {
        await _loadFavorites();
      }
    }
  }
}
