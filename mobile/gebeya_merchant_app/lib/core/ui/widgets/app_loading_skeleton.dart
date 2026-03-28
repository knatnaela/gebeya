import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AppLoadingSkeletonList extends StatelessWidget {
  const AppLoadingSkeletonList({super.key, this.rows = 8});

  final int rows;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = scheme.surfaceContainerHighest;
    final highlight = Color.lerp(base, scheme.onSurface, 0.06) ?? base;
    final block = scheme.surfaceContainerHighest;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      period: const Duration(milliseconds: 1500),
      child: ListView.separated(
        itemCount: rows,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: block,
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: block,
                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FractionallySizedBox(
                      widthFactor: index.isEven ? 0.7 : 0.5,
                      child: Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: block,
                          borderRadius: const BorderRadius.all(Radius.circular(4)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
