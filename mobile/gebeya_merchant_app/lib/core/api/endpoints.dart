abstract final class Endpoints {
  static const String login = '/auth/login';
  static const String authPublicConfig = '/auth/public-config';
  static const String authGatewayStart = '/auth/login/gateway/start';
  static const String authGatewayVerify = '/auth/login/gateway/verify';
  static const String me = '/auth/me';
  static const String changePassword = '/auth/change-password';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String usersMe = '/users/me';

  static const String merchantRegister = '/merchants/register';
  static const String subscriptionStatus = '/subscriptions/status';

  static const String inventorySummary = '/inventory/summary';
  static const String salesAnalytics = '/sales/analytics';
  static const String sales = '/sales';
  static String sale(String id) => '/sales/$id';
  static String saleVoid(String id) => '/sales/$id/void';

  static const String products = '/products';
  static const String productsLowStock = '/products/low-stock';
  static const String locationsDefault = '/locations/default';
  static const String locations = '/locations';
  static String location(String id) => '/locations/$id';
  static String locationSetDefault(String id) => '/locations/$id/set-default';

  static const String expenses = '/expenses';
  static const String expensesAnalytics = '/expenses/analytics';
  static String expense(String id) => '/expenses/$id';
  static String inventoryStock(String productId) =>
      '/inventory/stock/$productId';
  static const String inventoryStockBatch = '/inventory/stock/batch';
  static const String inventoryTransactions = '/inventory/transactions';
  static String inventoryTransaction(String id) =>
      '/inventory/transactions/$id';
  static const String inventoryEntries = '/inventory/entries';
  static const String addStock = '/inventory/stock';
  static const String transferStock = '/inventory/transfer';
}
