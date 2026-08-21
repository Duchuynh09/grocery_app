class Customer {
  final String id;
  String name;
  String phone;
  String address;
  double totalDebt; // tổng công nợ hiện tại

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.address = '',
    this.totalDebt = 0,
  });

  factory Customer.fromMap(Map<String, dynamic> map) => Customer(
        id: map['id'] as String,
        name: map['name'] as String,
        phone: map['phone'] as String,
        address: map['address'] as String? ?? '',
        totalDebt: (map['total_debt'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phone': phone,
        'address': address,
        'total_debt': totalDebt,
      };
}
