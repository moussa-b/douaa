import 'package:flutter/material.dart';

/// A classic progress bar with percentage displayed inside the bar.
/// [value] should be between 0.0 and 1.0 (or use [invoked] and [total] for automatic calculation).
class CategoryProgressBar extends StatelessWidget {
  /// Progress from 0.0 to 1.0. If null, [invoked] and [total] are used.
  final double? value;

  /// Number of items with progress (e.g. douaa with count > 0).
  final int? invoked;

  /// Total number of items.
  final int? total;

  final double height;
  final Color? backgroundColor;
  final Color? valueColor;

  const CategoryProgressBar({
    super.key,
    this.value,
    this.invoked,
    this.total,
    this.height = 20,
    this.backgroundColor,
    this.valueColor,
  }) : assert(value == null || (invoked == null && total == null),
            'Provide either value or (invoked, total), not both'),
       assert(value != null || (invoked != null && total != null),
            'Provide either value or both invoked and total');

  double get _progress {
    if (value != null) return value!.clamp(0.0, 1.0);
    final t = total ?? 0;
    if (t <= 0) return 0.0;
    final i = invoked ?? 0;
    return (i / t).clamp(0.0, 1.0);
  }

  int get _percent => (_progress * 100).round();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = backgroundColor ?? theme.colorScheme.surfaceContainerHighest;
    final fill = valueColor ?? theme.colorScheme.primary;

    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: Stack(
              children: [
                // Background
                Container(
                  width: double.infinity,
                  height: height,
                  color: bg,
                ),
                // Filled portion
                FractionallySizedBox(
                  widthFactor: _progress,
                  child: Container(
                    height: height,
                    color: fill,
                  ),
                ),
                // Percentage label centered inside the bar
                Center(
                  child: Text(
                    '$_percent%',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: _progress > 0.5
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A widget that sizes its child to a fraction of the parent's width.
class FractionallySizedBox extends StatelessWidget {
  final double widthFactor;
  final Widget child;

  const FractionallySizedBox({
    super.key,
    required this.widthFactor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth * widthFactor.clamp(0.0, 1.0);
        return SizedBox(width: w, child: child);
      },
    );
  }
}
