import 'base_entity.dart';

class User extends BaseEntity implements Searchable {
  String _name;
  String _email;
  String? _profileImage;
  bool _isActive;

  User({
    required super.id,
    required String name,
    required String email,
    String? profileImage,
    bool isActive = true,
  }) : _name = name,
       _email = email,
       _profileImage = profileImage,
       _isActive = isActive {
    _validateEmail(email);
    _validateName(name);
  }

  // Getters (Encapsulation)
  String get name => _name;
  String get email => _email;
  String? get profileImage => _profileImage;
  bool get isActive => _isActive;
  String get displayName => _name.split(' ').first;

  // Setters with validation (Encapsulation)
  set name(String value) {
    _validateName(value);
    _name = value.trim();
    updatedAt = DateTime.now();
  }

  set email(String value) {
    _validateEmail(value);
    _email = value.toLowerCase();
    updatedAt = DateTime.now();
  }

  set profileImage(String? value) {
    _profileImage = value;
    updatedAt = DateTime.now();
  }

  set isActive(bool value) {
    _isActive = value;
    updatedAt = DateTime.now();
  }

  // Private validation methods
  void _validateName(String name) {
    if (name.trim().isEmpty) {
      throw ArgumentError('Name cannot be empty');
    }
    if (name.trim().length < 2) {
      throw ArgumentError('Name must be at least 2 characters');
    }
  }

  void _validateEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      throw ArgumentError('Invalid email format');
    }
  }

  // Override abstract methods (Polymorphism)
  @override
  String getDisplayName() => _name;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': _name,
      'email': _email,
      'profileImage': _profileImage,
      'isActive': _isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Implement Searchable interface
  @override
  bool matchesQuery(String query) {
    final lowerQuery = query.toLowerCase();
    return _name.toLowerCase().contains(lowerQuery) ||
        _email.toLowerCase().contains(lowerQuery);
  }

  @override
  List<String> getSearchableFields() {
    return [_name, _email];
  }

  // Factory constructor
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profileImage: json['profileImage'],
      isActive: json['isActive'] ?? true,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $_name, email: $_email)';
  }
}

// models/admin_user.dart - Inheritance example
class AdminUser extends User {
  final List<String> _permissions;
  String _role;

  AdminUser({
    required super.id,
    required super.name,
    required super.email,
    super.profileImage,
    super.isActive,
    required List<String> permissions,
    required String role,
  }) : _permissions = List.from(permissions),
       _role = role;

  // Additional getters for admin functionality
  List<String> get permissions => List.unmodifiable(_permissions);
  String get role => _role;

  // Setter with validation
  set role(String value) {
    if (value.trim().isEmpty) {
      throw ArgumentError('Role cannot be empty');
    }
    _role = value;
    updatedAt = DateTime.now();
  }

  // Permission management methods
  void addPermission(String permission) {
    if (!_permissions.contains(permission)) {
      _permissions.add(permission);
      updatedAt = DateTime.now();
    }
  }

  void removePermission(String permission) {
    if (_permissions.remove(permission)) {
      updatedAt = DateTime.now();
    }
  }

  bool hasPermission(String permission) => _permissions.contains(permission);

  // Override parent method (Polymorphism)
  @override
  String getDisplayName() => '$_role - ${super.getDisplayName()}';

  // Override toJson to include admin fields
  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'permissions': _permissions,
      'role': _role,
      'userType': 'admin',
    });
    return json;
  }

  @override
  String toString() {
    return 'AdminUser(id: $id, name: $name, role: $_role, permissions: ${_permissions.length})';
  }
}
