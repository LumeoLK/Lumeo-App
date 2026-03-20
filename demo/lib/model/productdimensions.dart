class ProductDimensions {
  final double length;
  final double width;
  final double height;
  final String unit;

  ProductDimensions({
    required this.length,
    required this.width,
    required this.height,
    required this.unit,
  });

  factory ProductDimensions.fromJson(Map<String, dynamic> json) {
    return ProductDimensions(
      length: (json['length'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      unit: json['unit'] ?? 'cm',
    );
  }
}
