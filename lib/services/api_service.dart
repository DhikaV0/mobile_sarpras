import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/item_model.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
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
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Terjadi kesalahan'
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

  // GET CURRENT USER
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
  Future<Map<String, dynamic>> updateProfile({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      await dio.put(
        '$baseUrl/user/profile',
        data: {
          'email': email,
          'password': password,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return {'success': true, 'message': 'Profil berhasil diperbarui'};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Terjadi kesalahan saat update',
      };
    }
  }

  // GET ITEMS
  Future<List<Item>> getItems() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await dio.get(
        '$baseUrl/items',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      List data = response.data;
      return data.map((json) => Item.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // AJUKAN PEMINJAMAN
  Future<bool> ajukanPeminjaman({
    required int itemId,
    required int jumlah,
    required String tanggal,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      await dio.post(
        '$baseUrl/peminjaman',
        data: {
          'items_id': itemId,
          'jumlah_pinjam': jumlah,
          'tanggal_pinjam': tanggal,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // GET LIST PEMINJAMAN
  Future<List<dynamic>> getPeminjamanSaya() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await dio.get(
        '$baseUrl/peminjaman/saya',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } catch (e) {
      return [];
    }
  }

  // AJUKAN PENGEMBALIAN
  Future<bool> ajukanPengembalian(int peminjamanId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      await dio.post(
        '$baseUrl/peminjaman/$peminjamanId/return',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
