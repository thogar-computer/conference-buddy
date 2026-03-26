import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _api = ApiService();

  Future<User> register(String email, String password, String fullName) async {
    final response = await _api.post('/auth/register', {
      'email': email,
      'password': password,
      'fullName': fullName,
    });

    await _api.saveToken(response['token']);
    return User.fromJson(response['user']);
  }

  Future<User> login(String email, String password) async {
    final response = await _api.post('/auth/login', {
      'email': email,
      'password': password,
    });

    await _api.saveToken(response['token']);
    return User.fromJson(response['user']);
  }

  Future<User> getProfile() async {
    await _api.loadToken();
    final response = await _api.get('/auth/profile');
    return User.fromJson(response);
  }

  Future<void> logout() async {
    await _api.clearToken();
  }

  bool get isAuthenticated => _api.hasToken;
}