// lib/features/search/screens/search_screen.dart

import 'package:aplikasi_news/core/api/news_service.dart';
import 'package:aplikasi_news/core/models/article_model.dart';
import 'package:aplikasi_news/features/detail/screens/detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final NewsApiService _newsService = NewsApiService();

  // Gunakan Future yang bisa null untuk menampung hasil pencarian
  Future<List<Article>>? _searchFuture;

  // Method untuk memulai pencarian
  void _performSearch() {
    if (_searchController.text.isNotEmpty) {
      setState(() {
        _searchFuture = _newsService.searchNews(query: _searchController.text);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search News'),
      ),
      body: Column(
        children: [
          // 1. KOTAK PENCARIAN
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search for articles...',
                hintText: 'Economic News or etc',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchFuture = null; // Hapus hasil
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              // Panggil _performSearch saat tombol 'search' di keyboard di-tap
              onSubmitted: (value) => _performSearch(),
            ),
          ),

          // 2. HASIL PENCARIAN
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  // Widget untuk menampilkan hasil
  Widget _buildSearchResults() {
    // Jika _searchFuture masih null (belum mencari), tampilkan pesan
    if (_searchFuture == null) {
      return const Center(
        child: Text('Enter a search term to begin.'),
      );
    }

    // Jika sudah mencari, gunakan FutureBuilder
    return FutureBuilder<List<Article>>(
      future: _searchFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No articles found.'));
        } else {
          // Tampilkan list hasil
          final articles = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              // Kita gunakan style kartu yang berbeda (list) untuk hasil search
              return _buildArticleCard(context, articles[index]);
            },
          );
        }
      },
    );
  }

  // Widget untuk satu kartu hasil pencarian (style list)
  Widget _buildArticleCard(BuildContext context, Article article) {
    final String formattedDate = article.publishedAt != null
        ? DateFormat('dd MMM yyyy').format(article.publishedAt!)
        : 'No Date';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailScreen(article: article),
            ),
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: CachedNetworkImage(
                imageUrl: article.urlToImage ?? '',
                height: 100,
                width: 100,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 100,
                  width: 100,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 100,
                  width: 100,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${article.sourceName ?? 'Unknown'} • $formattedDate',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}