class Product {
  final String id;
  String name;
  String barcode;
  String category;
  double costPrice; // giá nhập
  double sellPrice; // giá bán
  int stock; // tồn kho
  String unit; // đơn vị: chai, gói, hộp...
  String supplier; // nhà cung cấp / nguồn nhập
  bool isActive; // còn bán hay đã ngừng bán

  Product({
    required this.id,
    required this.name,
    required this.barcode,
    required this.category,
    required this.costPrice,
    required this.sellPrice,
    required this.stock,
    required this.unit,
    required this.supplier,
    this.isActive = true,
  });

  /// Chỉ những sản phẩm còn hàng và đang bán mới được chọn ở màn Bán hàng.
  bool get isSellable => isActive && stock > 0;

  factory Product.fromMap(Map<String, dynamic> map) => Product(
        id: map['id'] as String,
        name: map['name'] as String,
        barcode: map['barcode'] as String? ?? '',
        category: map['category'] as String? ?? '',
        costPrice: (map['cost_price'] as num).toDouble(),
        sellPrice: (map['sell_price'] as num).toDouble(),
        stock: map['stock'] as int,
        unit: map['unit'] as String? ?? '',
        supplier: map['supplier'] as String? ?? '',
        isActive: (map['is_active'] as int? ?? 1) == 1,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'barcode': barcode,
        'category': category,
        'cost_price': costPrice,
        'sell_price': sellPrice,
        'stock': stock,
        'unit': unit,
        'supplier': supplier,
        'is_active': isActive ? 1 : 0,
      };
}
