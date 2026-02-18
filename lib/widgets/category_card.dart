import 'package:flutter/material.dart';
import '../models/category.dart';
import 'category_progress_bar.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final bool isGrid;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final int? subCategoryCount;
  final int? douaaCount;
  /// Number of douaa in this category with read_count > 0 (for progress).
  final int? invokedCount;

  const CategoryCard({
    super.key,
    required this.category,
    required this.isGrid,
    required this.onTap,
    this.onLongPress,
    this.subCategoryCount,
    this.douaaCount,
    this.invokedCount,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isGrid) {
      final total = douaaCount ?? 0;
      final invoked = invokedCount ?? 0;
      final showProgressHint = total > 0;
      return Card(
        clipBehavior: Clip.antiAlias,
        color: const Color(0xFF84E6DD),
        surfaceTintColor: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF84E6DD),
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
                              fontSize: 14,
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
                                  fontSize: 10,
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
                                  fontSize: 10,
                                ),
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ],
                  ),
                ),
              ),
              if (showProgressHint)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Text(
                    '$invoked/$total',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.onPrimaryContainer.withAlpha(180),
                          fontSize: 11,
                        ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    // List mode
    final hasCounts = (subCategoryCount != null && subCategoryCount! > 0) ||
        (douaaCount != null && douaaCount! > 0);
    final total = douaaCount ?? 0;
    final invoked = invokedCount ?? 0;
    final showProgress = total > 0;

    return Card(
      color: const Color(0xFF84E6DD),
      surfaceTintColor: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          category.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        if (hasCounts) ...[
                          const SizedBox(height: 4),
                          if (subCategoryCount != null &&
                              subCategoryCount! > 0)
                            Text(
                              '$subCategoryCount sous-catégorie${subCategoryCount! > 1 ? 's' : ''}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                            ),
                          if (douaaCount != null && douaaCount! > 0)
                            Text(
                              '$douaaCount invocation${douaaCount! > 1 ? 's' : ''}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                            ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              if (showProgress) ...[
                const SizedBox(height: 10),
                CategoryProgressBar(
                  invoked: invoked,
                  total: total,
                  height: 18,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
