abstract final class Endpoints {
  static const String login = '/auth/login';
  static const String me = '/auth/me';
  static const String changePassword = '/auth/change-password';

  static const String merchantRegister = '/merchants/register';
  static const String subscriptionStatus = '/subscriptions/status';

  static const String inventorySummary = '/inventory/summary';
  static const String salesAnalytics = '/sales/analytics';
  static const String sales = '/sales';
  static String sale(String id) => '/sales/$id';

  static const String products = '/products';
  static const String productsLowStock = '/products/low-stock';
  static const String locationsDefault = '/locations/default';
  static const String locations = '/locations';
  static String inventoryStock(String productId) => '/inventory/stock/$productId';
  static const String inventoryStockBatch = '/inventory/stock/batch';
  static const String inventoryTransactions = '/inventory/transactions';
  static String inventoryTransaction(String id) => '/inventory/transactions/$id';
  static const String inventoryEntries = '/inventory/entries';
  static const String addStock = '/inventory/stock';
  static const String transferStock = '/inventory/transfer';
}

