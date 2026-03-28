import 'package:json_annotation/json_annotation.dart';

/// Matches backend [ProductMeasureUnit] (size label semantics; stock qty stays unit count).
@JsonEnum(alwaysCreate: true)
enum ProductMeasureUnit {
  PCS,
  ML,
  L,
  G,
  KG,
}

extension ProductMeasureUnitDisplay on ProductMeasureUnit {
  String get shortLabel {
    switch (this) {
      case ProductMeasureUnit.PCS:
        return 'pcs';
      case ProductMeasureUnit.ML:
        return 'ml';
      case ProductMeasureUnit.L:
        return 'L';
      case ProductMeasureUnit.G:
        return 'g';
      case ProductMeasureUnit.KG:
        return 'kg';
    }
  }

  /// Long label for dropdowns and forms.
  String get formLabel {
    switch (this) {
      case ProductMeasureUnit.PCS:
        return 'Pieces (pcs)';
      case ProductMeasureUnit.ML:
        return 'Milliliters (ml)';
      case ProductMeasureUnit.L:
        return 'Liters (L)';
      case ProductMeasureUnit.G:
        return 'Grams (g)';
      case ProductMeasureUnit.KG:
        return 'Kilograms (kg)';
    }
  }
}

/// Formats [size] with measure unit for display (e.g. "100 ml").
String formatProductSizeLabel(String? size, ProductMeasureUnit measureUnit) {
  final s = size?.trim();
  if (s == null || s.isEmpty) return '';
  return '$s ${measureUnit.shortLabel}';
}
