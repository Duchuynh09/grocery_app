import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/customer_repository.dart';
import '../../data/repositories/invoice_repository.dart';
import '../../models/customer.dart';
import '../../models/invoice.dart';
import '../../widgets/money_text.dart';

class CustomerDetailScreen extends StatefulWidget {
  final Customer customer;
  const CustomerDetailScreen({super.key, required this.customer});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  late Customer _customer;
  int _refreshKey = 0;

  @override
  void initState() {
    super.initState();
    _customer = widget.customer;
  }

  Future<void> _repayDebt() async {
    final controller = TextEditingController();
    final amount = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ghi nhận trả nợ'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Số tiền khách trả'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              Navigator.pop(context, value);
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
    if (amount == null || amount <= 0) return;

    final repo = context.read<CustomerRepository>();
    await repo.repayDebt(_customer.id, amount);
    setState(() {
      _customer.totalDebt = (_customer.totalDebt - amount).clamp(0, double.infinity);
      _refreshKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final invoiceRepo = context.read<InvoiceRepository>();
    final initials = _customer.name.isNotEmpty
        ? _customer.name.trim().split(' ').map((s) => s[0]).take(2).join().toUpperCase()
        : '?';

    return Scaffold(
      appBar: AppBar(title: const Text('Thông tin khách hàng')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              CircleAvatar(radius: 24, backgroundColor: AppColors.primaryLight, child: Text(initials, style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w600))),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_customer.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  Text(_customer.phone, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
          if (_customer.address.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(children: [
              const Icon(Icons.place_outlined, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Expanded(child: Text(_customer.address, style: const TextStyle(fontSize: 13))),
            ]),
          ],
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.warningBg, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Công nợ hiện tại', style: TextStyle(fontSize: 12, color: AppColors.warning)),
                      MoneyText(_customer.totalDebt, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.warning)),
                    ],
                  ),
                ),
                if (_customer.totalDebt > 0)
                  ElevatedButton(onPressed: _repayDebt, child: const Text('Ghi nhận trả nợ')),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Lịch sử hóa đơn', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          FutureBuilder<List<Invoice>>(
            key: ValueKey(_refreshKey),
            future: invoiceRepo.getByCustomer(_customer.id),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              final invoices = snapshot.data!;
              if (invoices.isEmpty) {
                return const Text('Chưa có giao dịch nào', style: TextStyle(fontSize: 12, color: AppColors.textMuted));
              }
              return Column(
                children: invoices.map((inv) {
                  final dateStr = DateFormat('dd/MM · HH:mm').format(inv.dateTime);
                  return Card(
                    child: ListTile(
                      dense: true,
                      title: MoneyText(inv.total, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('$dateStr · ${inv.paymentMethod == PaymentMethod.cash ? 'Tiền mặt' : 'Ghi nợ'}'),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
