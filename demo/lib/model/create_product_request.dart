import 'dart:io';

class CreateProductRequest {
  const CreateProductRequest({
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.stock,
    required this.length,
    required this.width,
    required this.height,
    required this.images, // only non-null files
  });

  final String title;
  final String description;
  final double price;
  final String category;
  final int stock;
  final double length;
  final double width;
  final double height;
  final List<File> images;
}
