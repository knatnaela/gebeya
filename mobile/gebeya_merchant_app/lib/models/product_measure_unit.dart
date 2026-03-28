import 'package:json_annotation/json_annotation.dart';

/// Matches backend [ProductMeasureUnit] (size label semantics; stock qty stays unit count).
@JsonEnum(alwaysCreate: true)
enum ProductMeasureUnit {
  PCS,
  ML,
  L,
  G,
  KG,
  IN,
  CM,
  MM,
  M,
  FT,
  YD,
  OZ,
  LB,
  GAL,
  FL_OZ,
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
      case ProductMeasureUnit.IN:
        return 'in';
      case ProductMeasureUnit.CM:
        return 'cm';
      case ProductMeasureUnit.MM:
        return 'mm';
      case ProductMeasureUnit.M:
        return 'm';
      case ProductMeasureUnit.FT:
        return 'ft';
      case ProductMeasureUnit.YD:
        return 'yd';
      case ProductMeasureUnit.OZ:
        return 'oz';
      case ProductMeasureUnit.LB:
        return 'lb';
      case ProductMeasureUnit.GAL:
        return 'gal';
      case ProductMeasureUnit.FL_OZ:
        return 'fl oz';
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
      case ProductMeasureUnit.IN:
        return 'Inches (in)';
      case ProductMeasureUnit.CM:
        return 'Centimeters (cm)';
      case ProductMeasureUnit.MM:
        return 'Millimeters (mm)';
      case ProductMeasureUnit.M:
        return 'Meters (m)';
      case ProductMeasureUnit.FT:
        return 'Feet (ft)';
      case ProductMeasureUnit.YD:
        return 'Yards (yd)';
      case ProductMeasureUnit.OZ:
        return 'Ounces (oz)';
      case ProductMeasureUnit.LB:
        return 'Pounds (lb)';
      case ProductMeasureUnit.GAL:
        return 'Gallons (gal)';
      case ProductMeasureUnit.FL_OZ:
        return 'Fluid ounces (fl oz)';
    }
  }
}

/// Formats [size] with measure unit for display (e.g. "100 ml").
String formatProductSizeLabel(String? size, ProductMeasureUnit measureUnit) {
  final s = (size ?? '').trim();
  if (s.isEmpty) return measureUnit.shortLabel;
  return '$s ${measureUnit.shortLabel}';
}
