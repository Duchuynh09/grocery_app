import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/customer_repository.dart';
import '../../models/customer.dart';

class CustomerFormScreen extends StatefulWidget {
  const CustomerFormScreen({super.key});

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final repo = context.read<CustomerRepository>();
    final customer = Customer(
      id: 'kh_${DateTime.now().millisecondsSinceEpoch}',
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      address: _address.text.trim(),
    );
    await repo.add(customer);
    if (mounted) Navigator.pop(context, true);
  }

  String? _requiredValidator(String? v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc nhập' : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Khách hàng mới')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Họ và tên'), validator: _requiredValidator),
            const SizedBox(height: 12),
            TextFormField(controller: _phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Số điện thoại'), validator: _requiredValidator),
            const SizedBox(height: 12),
            TextFormField(controller: _address, decoration: const InputDecoration(labelText: 'Địa chỉ')),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              child: const Text('Lưu khách hàng'),
            ),
          ],
        ),
      ),
    );
  }
}
