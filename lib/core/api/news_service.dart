// lib/core/api/news_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:aplikasi_news/core/models/article_model.dart';

class NewsApiService {
  final String _apiKey = '06d0f7a97d1c460c99b355c6f3e16034';
  final String _baseUrl = 'https://newsapi.org/v2';

  // --- PERUBAHAN DI SINI ---
  // Tambahkan parameter 'category'
  Future<List<Article>> getTopHeadlines({required String category}) async {
    // Gunakan kategori dalam URL
    final String url =
        '$_baseUrl/top-headlines?country=us&category=$category&apiKey=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);

        if (json['status'] == 'ok') {
          final List<dynamic> articlesJson = json['articles'];
          return articlesJson.map((item) => Article.fromJson(item)).toList();
        } else {
          throw Exception('Failed to load news: ${json['message']}');
        }
      } else {
        throw Exception(
            'Failed to load news (Status code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to load news: $e');
    }
  }

  // --- METHOD BARU UNTUK SEARCH ---
  Future<List<Article>> searchNews({required String query}) async {
    // Gunakan endpoint 'everything' untuk pencarian
    final String url = '$_baseUrl/everything?q=$query&apiKey=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);

        if (json['status'] == 'ok') {
          final List<dynamic> articlesJson = json['articles'];
          return articlesJson.map((item) => Article.fromJson(item)).toList();
        } else {
          throw Exception('Failed to load news: ${json['message']}');
        }
      } else {
        throw Exception(
            'Failed to load news (Status code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to load news: $e');
    }
  }
}