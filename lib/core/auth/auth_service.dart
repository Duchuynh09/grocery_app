import 'package:flutter/foundation.dart';
import '../../models/user.dart';
import '../../data/repositories/user_repository.dart';

/// Giữ trạng thái đăng nhập hiện tại, dùng ChangeNotifier để các màn
/// hình tự cập nhật (ẩn/hiện tab, khóa chức năng) khi đổi tài khoản.
class AuthService extends ChangeNotifier {
  final UserRepository _repo;
  AppUser? _currentUser;

  AuthService(this._repo);

  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  Future<bool> login(String username, String password) async {
    final user = await _repo.login(username, password);
    if (user == null) return false;
    _currentUser = user;
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
