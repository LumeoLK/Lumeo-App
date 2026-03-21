class ShippingAddress {
  final String address;
  final String city;
  final String postalCode;
  final String phone;

  ShippingAddress({
    required this.address,
    required this.city,
    required this.postalCode,
    required this.phone,
  });


  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      postalCode: json['postalCode'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  
  Map<String, dynamic> toJson() => {
        'address': address,
        'city': city,
        'postalCode': postalCode,
        'phone': phone,
      };
}