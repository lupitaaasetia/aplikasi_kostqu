// services/auth_service.dart
import '../models/user.dart';

class AuthService {
  User? _currentUser;

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Mock user database
  final Map<String, String> _users = {
    'admin@gmail.com': 'admin123',
    'user@gmail.com': 'user123',
    'test@gmail.com': 'password',
    'mahasiswa@unesa.ac.id': '123456',
    'student@unesa.ac.id': 'student123',
  };

  // Getter for current user
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  // Login method
  Future<bool> login(String email, String password) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 1500));

    if (_users.containsKey(email) && _users[email] == password) {
      _currentUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _getNameFromEmail(email),
        email: email,
      );
      return true;
    }
    return false;
  }

  // Register method
  Future<bool> register(String name, String email, String password) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 2000));

    if (_users.containsKey(email)) {
      return false; // User already exists
    }

    _users[email] = password;
    return true;
  }

  // Logout method
  void logout() {
    _currentUser = null;
  }

  // Forgot password method
  Future<bool> forgotPassword(String email) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 1500));

    return _users.containsKey(email);
  }

  // Helper method to get name from email
  String _getNameFromEmail(String email) {
    if (email.contains('admin')) return 'Administrator';
    if (email.contains('mahasiswa') || email.contains('student')) {
      return 'Mahasiswa UNESA';
    }
    return email.split('@')[0].replaceAll(RegExp(r'[^a-zA-Z]'), ' ');
  }

  // Validate credentials
  Map<String, String> getValidCredentials() {
    return Map.from(_users);
  }
}
