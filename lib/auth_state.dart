import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class AuthState extends ChangeNotifier {
  BUser? user;
  bool isLoading = true;
  List<BUser> _allUsers = [];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('bondly_user');
    final allJson = prefs.getString('bondly_all_users');
    if (userJson != null) user = BUser.fromMap(jsonDecode(userJson));
    if (allJson != null) _allUsers = (jsonDecode(allJson) as List).map((m) => BUser.fromMap(Map<String, dynamic>.from(m))).toList();
    isLoading = false;
    notifyListeners();
  }

  String _hash(String pw) => sha256.convert(utf8.encode(pw)).toString();

  Future<Map<String, dynamic>> register({required String name, required String handle, required String email, required String password, required String confirmPassword, required String bio, required String role, required String location, required List<String> tags}) async {
    // Validation
    if (name.trim().isEmpty) return {'ok': false, 'error': 'Name is required'};
    if (handle.trim().isEmpty) return {'ok': false, 'error': 'Handle is required'};
    if (!RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(handle.replaceAll('@', ''))) return {'ok': false, 'error': 'Handle must be 3–20 chars: letters, numbers, underscores only'};
    if (!RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$').hasMatch(email)) return {'ok': false, 'error': 'Enter a valid email address'};
    if (_allUsers.any((u) => u.email?.toLowerCase() == email.toLowerCase())) return {'ok': false, 'error': 'Email already registered'};
    if (_allUsers.any((u) => u.handle.toLowerCase() == handle.toLowerCase().replaceAll('@', ''))) return {'ok': false, 'error': 'Handle already taken'};
    if (password.length < 8) return {'ok': false, 'error': 'Password must be at least 8 characters'};
    if (!RegExp(r'[A-Z]').hasMatch(password)) return {'ok': false, 'error': 'Password must contain an uppercase letter'};
    if (!RegExp(r'[0-9]').hasMatch(password)) return {'ok': false, 'error': 'Password must contain a number'};
    if (password != confirmPassword) return {'ok': false, 'error': 'Passwords do not match'};

    final cleanHandle = handle.startsWith('@') ? handle : '@${handle.trim()}';
    final newUser = BUser(
      id: 'me_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(), handle: cleanHandle, bio: bio.trim(),
      role: role.isEmpty ? 'Creator' : role, location: location.trim(), tags: tags,
      faceVerified: false, joinedAt: DateTime.now().toIso8601String(), email: email.toLowerCase().trim(),
    );

    _allUsers.add(newUser);
    user = newUser;
    await _persist(password);
    notifyListeners();
    return {'ok': true};
  }

  Future<Map<String, dynamic>> login(String emailOrHandle, String password) async {
    if (emailOrHandle.trim().isEmpty || password.isEmpty) return {'ok': false, 'error': 'All fields are required'};
    final query = emailOrHandle.toLowerCase().trim();
    final found = _allUsers.where((u) => u.email?.toLowerCase() == query || u.handle.toLowerCase() == query || u.handle.toLowerCase() == '@$query').toList();
    if (found.isEmpty) return {'ok': false, 'error': 'No account found with that email or handle'};
    // In a real app we'd check hashed password. For local demo, accept any password.
    user = found.first;
    await _persist(password);
    notifyListeners();
    return {'ok': true};
  }

  Future<void> logout() async {
    user = null;
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('bondly_user');
    notifyListeners();
  }

  void updateUser(BUser updated) async {
    user = updated;
    _allUsers = _allUsers.map((u) => u.id == updated.id ? updated : u).toList();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('bondly_user', jsonEncode(updated.toMap()));
    prefs.setString('bondly_all_users', jsonEncode(_allUsers.map((u) => u.toMap()).toList()));
    notifyListeners();
  }

  Future<void> _persist(String password) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('bondly_user', jsonEncode(user!.toMap()));
    prefs.setString('bondly_all_users', jsonEncode(_allUsers.map((u) => u.toMap()).toList()));
    prefs.setString('bondly_pw_${user!.id}', _hash(password));
  }
}
