class Constants {
  // The base address of the server
  // For production: 'https://lumeo-app.onrender.com'
  // For local dev: 'http://10.0.2.2:3000'
  static String baseUrl = 'https://lumeo-app.onrender.com';

  // Specific API routes
  static String authUri = '$baseUrl/api/auth';
  static String cartUri = '$baseUrl/api/cart';
  static String productsUri = '$baseUrl/api/products';
  static String chatUri = '$baseUrl/api/chat';
  static String wishlistUri = '$baseUrl/api/wishlist';
  static String ordersUri = '$baseUrl/api/orders';
  static String sellersUri = '$baseUrl/api/seller';
}
