import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AppLoadingSkeletonList extends StatelessWidget {
  const AppLoadingSkeletonList({super.key, this.rows = 8});

  final int rows;

  @override
  Widget build(BuildContext context) {
    // Subtle premium shimmer colors
    const baseColor = Color(0xFFF0F0F0); // Very light grey
    const highlightColor = Color(0xFFFDFDFD); // Near white

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: const Duration(milliseconds: 1500),
      child: ListView.separated(
        itemCount: rows,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          // Varying widths for realism
          return Row(
            children: [
              // Avatar placeholder
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title line
                    Container(
                      height: 16,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Subtitle line (randomized width handled by fractional box or fixed)
                    FractionallySizedBox(
                      widthFactor: index.isEven ? 0.7 : 0.5,
                      child: Container(
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
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
