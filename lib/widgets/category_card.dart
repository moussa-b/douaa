import 'package:flutter/material.dart';
import '../models/category.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final bool isGrid;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final int? subCategoryCount;
  final int? douaaCount;

  const CategoryCard({
    super.key,
    required this.category,
    required this.isGrid,
    required this.onTap,
    this.onLongPress,
    this.subCategoryCount,
    this.douaaCount,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isGrid) {
      return Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primaryContainer,
                  colorScheme.primaryContainer.withAlpha(180),
                ],
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    category.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                    textAlign: TextAlign.center,
                  ),
                        if ((subCategoryCount != null &&
                                subCategoryCount! > 0) ||
                            (douaaCount != null && douaaCount! > 0)) ...[
                          const SizedBox(height: 6),
                          if (subCategoryCount != null &&
                              subCategoryCount! > 0)
                            Text(
                              '$subCategoryCount sous-catégorie${subCategoryCount! > 1 ? 's' : ''}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: colorScheme.onPrimaryContainer
                                        .withAlpha(180),
                                    fontSize: 11,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          if (douaaCount != null && douaaCount! > 0)
                            Text(
                              '$douaaCount invocation${douaaCount! > 1 ? 's' : ''}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: colorScheme.onPrimaryContainer
                                        .withAlpha(180),
                                    fontSize: 11,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ],
                    ),
                  ),
          ),
        ),
      );
    }

    // List mode
    final hasCounts = (subCategoryCount != null && subCategoryCount! > 0) ||
        (douaaCount != null && douaaCount! > 0);
    return Card(
      child: ListTile(
        title: Text(
          category.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        subtitle: hasCounts
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (subCategoryCount != null && subCategoryCount! > 0)
                    Text(
                      '$subCategoryCount sous-catégorie${subCategoryCount! > 1 ? 's' : ''}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                    ),
                  if (douaaCount != null && douaaCount! > 0)
                    Text(
                      '$douaaCount invocation${douaaCount! > 1 ? 's' : ''}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                    ),
                ],
              )
            : null,
        trailing: Icon(
          Icons.chevron_right,
          color: colorScheme.onSurfaceVariant,
        ),
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}
