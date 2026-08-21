enum PaymentMethod { cash, debt } // tiền mặt / ghi nợ
enum InvoiceStatus { paid, unpaid } // đã trả / còn nợ

// class InvoiceItem: đại diện cho một mặt hàng trong hóa đơn
class InvoiceItem {
  final String productId;
  final String productName; // lưu lại tên lúc bán, phòng khi sản phẩm bị đổi tên sau này
  final int quantity;
  final double unitPrice; // đơn giá lúc bán (không lấy giá hiện tại của sản phẩm)

  InvoiceItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => quantity * unitPrice;

  factory InvoiceItem.fromMap(Map<String, dynamic> map) => InvoiceItem(
        productId: map['product_id'] as String,
        productName: map['product_name'] as String,
        quantity: map['quantity'] as int,
        unitPrice: (map['unit_price'] as num).toDouble(),
      );

  Map<String, dynamic> toMap(String invoiceId) => {
        'invoice_id': invoiceId,
        'product_id': productId,
        'product_name': productName,
        'quantity': quantity,
        'unit_price': unitPrice,
      };
}
// class Invoice: đại diện cho một hóa đơn bán hàng, có thể là tiền mặt hoặc ghi nợ
class Invoice {
  final String id;
  final String? customerId; // null nếu khách vãng lai
  final DateTime dateTime;
  final List<InvoiceItem> items;
  final PaymentMethod paymentMethod;
  final InvoiceStatus status;
  final String? createdByUserId; // ai đã bán hóa đơn này
  final String? createdByName;

  Invoice({
    required this.id,
    this.customerId,
    required this.dateTime,
    required this.items,
    required this.paymentMethod,
    required this.status,
    this.createdByUserId,
    this.createdByName,
  });

  double get total => items.fold(0, (sum, item) => sum + item.total);
}
