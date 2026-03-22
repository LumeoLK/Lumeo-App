class Constants {
  // The base address of the server
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  // Specific API routes
  static String authUri = '$baseUrl/api/auth';

  // ML backend
  static const String mlUri = 'https://lumeocs14-lumeo-ml.hf.space';

  static String cartUri = '$baseUrl/api/cart';
  static String productsUri = '$baseUrl/api/products';
  static String requestsUri = '$baseUrl/api/requests';
  static String chatUri = '$baseUrl/api/chat';
  static String wishlistUri = '$baseUrl/api/wishlist';
  static String ordersUri = '$baseUrl/api/orders';
  static String sellersUri = '$baseUrl/api/seller';
}
