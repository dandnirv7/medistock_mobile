class ApiConstants {
  ApiConstants._();

  static const String apiPrefix = '/api/v1';

  // Auth
  static const String login = '/auth/login';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';

  // Dashboard
  static const String dashboardSummary = '/dashboard/summary';

  // Categories
  static const String categories = '/categories';

  // Suppliers
  static const String suppliers = '/suppliers';

  // Medicines
  static const String medicines = '/medicines';

  // Stock Movements
  static const String stockMovements = '/stock-movements';
  static const String stockIn = '/stock-movements/in';
  static const String stockOut = '/stock-movements/out';
}
