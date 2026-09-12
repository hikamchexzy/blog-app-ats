import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';
import '../models/category.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:4000/api';

  // ============ CATEGORIES ============
  static Future<List<Category>> getCategories({String? status}) async {
    final url = status != null
        ? '$baseUrl/categories?status=$status'
        : '$baseUrl/categories';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat kategori');
    }
  }

  // ============ POSTS ============
  static Future<List<Post>> getPosts({String? status}) async {
    final url = status != null
        ? '$baseUrl/posts?status=$status'
        : '$baseUrl/posts';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat artikel');
    }
  }

  static Future<Post> getPostById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/posts/$id'));

    if (response.statusCode == 200) {
      return Post.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Artikel tidak ditemukan');
    } else {
      throw Exception('Gagal memuat detail artikel');
    }
  }

  static Future<Post> createPost({
    required String title,
    required String content,
    int? categoryId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'content': content,
        'categoryId': categoryId,
      }),
    );

    if (response.statusCode == 201) {
      return Post.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Gagal membuat artikel');
    }
  }

  static Future<Post> updatePost({
    required int id,
    required String title,
    required String content,
    int? categoryId,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/posts/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'content': content,
        'categoryId': categoryId,
      }),
    );

    if (response.statusCode == 200) {
      return Post.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Gagal update artikel');
    }
  }

  static Future<void> deletePost(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/posts/$id'));

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus artikel');
    }
  }

  static Future<void> restorePost(int id) async {
    final response = await http.put(Uri.parse('$baseUrl/posts/$id/restore'));

    if (response.statusCode != 200) {
      throw Exception('Gagal restore artikel');
    }
  }
}