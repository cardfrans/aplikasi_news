// lib/features/discover/screens/all_news_screen.dart

import 'package:aplikasi_news/core/api/news_service.dart';
import 'package:aplikasi_news/core/models/article_model.dart';
import 'package:aplikasi_news/features/detail/screens/detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AllNewsScreen extends StatefulWidget {
  final String category;
  final String title;

  const AllNewsScreen({
    super.key,
    required this.category,
    required this.title,
  });

  @override
  State<AllNewsScreen> createState() => _AllNewsScreenState();
}

class _AllNewsScreenState extends State<AllNewsScreen> {
  late Future<List<Article>> _newsFuture;
  final NewsApiService _newsService = NewsApiService();

  @override
  void initState() {
    super.initState();
    // Ambil berita berdasarkan kategori yang dikirim dari home screen
    _newsFuture = _newsService.getTopHeadlines(category: widget.category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title), // Gunakan title yang dikirim
      ),
      body: FutureBuilder<List<Article>>(
        future: _newsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No articles found.'));
          } else {
            final articles = snapshot.data!;
            // Tampilkan list hasil
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                // Gunakan widget kartu yang sama dengan di search screen
                return _buildArticleCard(context, articles[index]);
              },
            );
          }
        },
      ),
    );
  }

  // Widget ini kita copy-paste dari SearchScreen untuk tampilan list
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