import 'package:flutter/material.dart';
import '../models/douaa.dart';

class DouaaCard extends StatelessWidget {
  final Douaa douaa;
  final bool showReference;
  final bool showTranslation;
  final VoidCallback onFavoriteToggle;
  final VoidCallback? onEditTap;
  final VoidCallback? onTap;
  final VoidCallback? onDismissed;

  const DouaaCard({
    super.key,
    required this.douaa,
    required this.showReference,
    required this.showTranslation,
    required this.onFavoriteToggle,
    this.onEditTap,
    this.onTap,
    this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final card = Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: const Color(0xFF84E6DD),
      surfaceTintColor: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sub-category badge
              if (douaa.subCategoryName != null &&
                  douaa.subCategoryName!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        douaa.subCategoryName!,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                  ),
                ),

              // Arabic text (RTL)
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  douaa.douaaAr,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 20,
                        height: 1.8,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'ScheherazadeNew',
                      ),
                ),
              ),

              // French translation
              if (showTranslation &&
                  douaa.douaaFr != null &&
                  douaa.douaaFr!.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Text(
                  douaa.douaaFr!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                ),
              ],

              // Reference
              if (showReference &&
                  douaa.reference != null &&
                  douaa.reference!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  douaa.reference!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                ),
              ],

              const SizedBox(height: 8),

              // Edit (left) and Favorite (right) buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (onEditTap != null)
                    IconButton(
                      icon: Icon(
                        Icons.edit_outlined,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onPressed: onEditTap,
                      tooltip: 'Modifier',
                    )
                  else
                    const SizedBox.shrink(),
                  IconButton(
                    icon: Icon(
                      douaa.isFavorite ? Icons.favorite : Icons.favorite_outline,
                      color: douaa.isFavorite
                          ? Colors.red
                          : colorScheme.onSurfaceVariant,
                    ),
                    onPressed: onFavoriteToggle,
                    tooltip: douaa.isFavorite
                        ? 'Retirer des favoris'
                        : 'Ajouter aux favoris',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (onDismissed != null) {
      return Dismissible(
        key: ValueKey(douaa.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.error,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.delete, color: colorScheme.onError),
        ),
        confirmDismiss: (direction) async {
          return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Supprimer l\'invocation'),
              content: const Text('Êtes-vous sûr de vouloir supprimer cette invocation ?'),
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
        },
        onDismissed: (_) => onDismissed!(),
        child: card,
      );
    }

    return card;
  }
}
