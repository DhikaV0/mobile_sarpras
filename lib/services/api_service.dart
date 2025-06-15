import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api'; // ← Ganti dengan IP lokal kamu
  final Dio dio = Dio();

  // LOGIN
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await dio.post('$baseUrl/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final token = response.data['access_token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        return {
          'success': true,
          'user': User.fromJson(response.data['user']),
        };
      } else {
        return {'success': false, 'message': 'Gagal login'};
      }
    } on DioException catch (e) {
      return {'success': false, 'message': e.response?.data['message'] ?? 'Terjadi kesalahan'};
    }
  }

  // GET USER
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await dio.get(
        '$baseUrl/user',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return User.fromJson(response.data);
    } catch (_) {
      return null;
    }
  }

  // UPDATE PROFILE
  Future<Map<String, dynamic>> updateProfile({required String email, required String password}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await dio.put(
        '$baseUrl/user/profile',
        data: {
          'email': email,
          'password': password,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return {
        'success': true,
        'message': 'Profil berhasil diperbarui',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Terjadi kesalahan saat update',
      };
    }
  }

  // LOGOUT
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      await dio.post(
        '$baseUrl/logout',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } finally {
      await prefs.remove('token');
    }
  }
}
