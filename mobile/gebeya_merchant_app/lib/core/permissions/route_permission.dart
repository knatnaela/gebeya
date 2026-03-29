import 'merchant_feature_slugs.dart';

/// Returns required feature slug for a path, or `null` if always allowed (dashboard, more).
String? requiredFeatureForMerchantPath(String matchedLocation) {
  final loc = matchedLocation;
  if (loc == '/app/dashboard' || loc == '/app/more' || loc == '/app/account') return null;

  if (loc.startsWith('/app/products')) return MerchantFeatureSlugs.productsView;
  if (loc.startsWith('/app/inventory')) return MerchantFeatureSlugs.inventoryView;
  if (loc.startsWith('/app/locations')) return MerchantFeatureSlugs.inventoryView;
  if (loc.startsWith('/app/sales')) return MerchantFeatureSlugs.salesView;
  if (loc.startsWith('/app/expenses')) return MerchantFeatureSlugs.salesView;

  return null;
}
