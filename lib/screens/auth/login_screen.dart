import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/auth/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _username = TextEditingController(text: 'admin');
  final _password = TextEditingController();
  String? _error;
  bool _loading = false;

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final auth = context.read<AuthService>();
    final ok = await auth.login(_username.text.trim(), _password.text);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (!ok) _error = 'Sai tên đăng nhập hoặc mật khẩu';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.storefront_outlined, color: AppColors.primaryDark, size: 32),
                ),
                const SizedBox(height: 16),
                const Text('Tạp hóa', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                const Text('Đăng nhập để tiếp tục', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: 24),
                TextField(controller: _username, decoration: const InputDecoration(labelText: 'Tên đăng nhập')),
                const SizedBox(height: 12),
                TextField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'Mật khẩu'), onSubmitted: (_) => _submit()),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 12)),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Đăng nhập'),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Tài khoản mặc định: admin / admin123', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
