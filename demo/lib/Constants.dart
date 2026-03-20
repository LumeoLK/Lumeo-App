
class Constants{


  


  // The base address of the server
  static String baseUrl = 'https://lumeo-app.onrender.com';
  static String get sellerUri => '$baseUrl/api/seller';

  // Specific API routes
  static String authUri = '$baseUrl/api/auth';

  // ML backend
  static const String mlUri = 'https://lumeocs14-lumeo-ml.hf.space';

  static String cartUri = '$baseUrl/api/cart';
  static String productsUri = '$baseUrl/api/products';
  static String chatUri = '$baseUrl/api/chat';

}
