import 'package:aplikasi_news/core/api/news_service.dart';
import 'package:aplikasi_news/core/models/article_model.dart';
import 'package:aplikasi_news/features/detail/screens/detail_screen.dart';
import 'package:aplikasi_news/features/discover/screens/all_news_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// Kita butuh SingleTickerProviderStateMixin untuk TabController
class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final NewsApiService _newsService = NewsApiService();

  final List<String> _categories = [
    'general',
    'business',
    'health',
    'science',
    'sports',
    'technology'
  ];

  // Map untuk cache data (Anti-Refresh)
  final Map<String, Future<List<Article>>> _categoryFutures = {};

  // Controller Tab & Scroll
  late TabController _tabController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    // Inisialisasi TabController
    _tabController = TabController(length: _categories.length, vsync: this);
    _scrollController = ScrollController();

    // Listener untuk merefresh Header Gambar saat tab berubah
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {}); // Rebuild untuk ganti gambar header
      }
    });

    // Fetch data di awal
    for (var category in _categories) {
      _categoryFutures[category] =
          _newsService.getTopHeadlines(category: category);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _changeCategory(int index) {
    // Pindah tab tanpa animasi slide (Statis)
    _tabController.animateTo(index, duration: Duration.zero);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Ambil kategori yang sedang aktif untuk menentukan Gambar Header
    String currentCategory = _categories[_tabController.index];

    return Scaffold(
      // NESTED SCROLL VIEW
      // Ini kuncinya: Header dan Body disatukan dalam satu kontrol scroll.
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            // BAGIAN 1: HEADER GAMBAR (SHARED)
            // Menggunakan FutureBuilder karena gambarnya tergantung kategori aktif
            FutureBuilder<List<Article>>(
              future: _categoryFutures[currentCategory],
              builder: (context, snapshot) {
                // Default placeholder jika data belum siap
                Article? featuredArticle;
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  featuredArticle = snapshot.data!.first;
                }

                return SliverAppBar(
                  expandedHeight: 400.0,
                  floating: false,
                  pinned: true, // Header tetap nempel di atas
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  elevation: 0,
                  leading: null,
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    background: featuredArticle == null
                        ? Container(color: Colors.grey[900]) // Loading state
                        : GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DetailScreen(article: featuredArticle!),
                          ),
                        );
                      },
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: featuredArticle.urlToImage ?? '',
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Container(color: Colors.grey[900]),
                            errorWidget: (context, url, error) =>
                                Container(
                                  color: Colors.grey[800],
                                  child: const Icon(Icons.broken_image,
                                      color: Colors.grey),
                                ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.9),
                                  Colors.transparent
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                stops: const [0.0, 0.6],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            left: 16,
                            right: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'News of the day',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  featuredArticle.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // BAGIAN 2: TAB CATEGORY (SHARED)
            // Kita taruh di luar body agar ikut scroll dengan header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final categoryName = _categories[index];
                      // Cek active index dari TabController
                      final bool isSelected = _tabController.index == index;
                      final bool isDark =
                          Theme.of(context).brightness == Brightness.dark;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: GestureDetector(
                          onTap: () => _changeCategory(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark ? Colors.white : Colors.black)
                                  : Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : Colors.grey[400]!,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                categoryName[0].toUpperCase() +
                                    categoryName.substring(1),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? (isDark ? Colors.black : Colors.white)
                                      : (isDark ? Colors.white : Colors.black),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // BAGIAN 3: HEADER TEXT
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Breaking News',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        String categoryTitle = currentCategory[0].toUpperCase() +
                            currentCategory.substring(1);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AllNewsScreen(
                              category: currentCategory,
                              title: '$categoryTitle News',
                            ),
                          ),
                        );
                      },
                      child: const Text('More'),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),
          ];
        },
        // BAGIAN 4: ISI KONTEN (BODY)
        // Menggunakan TabBarView agar sinkron dengan TabController
        body: TabBarView(
          controller: _tabController,
          // Physics NeverScrollable agar user tidak bisa swipe (sesuai request)
          physics: const NeverScrollableScrollPhysics(),
          children: _categories.map((category) {
            return BreakingNewsList(
              category: category,
              newsFuture: _categoryFutures[category]!,
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ============================================================================
// WIDGET BARU: LIST BERITA (GRID ONLY)
// ============================================================================
// Kita pisahkan list gridnya saja, karena Header sudah diurus oleh Parent (HomeScreen)

class BreakingNewsList extends StatelessWidget {
  final String category;
  final Future<List<Article>> newsFuture;

  const BreakingNewsList({
    super.key,
    required this.category,
    required this.newsFuture,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Article>>(
      future: newsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No news found.'));
        }

        final articles = snapshot.data!;
        // Kita skip 1 karena artikel pertama sudah dipakai di Header Besar
        final breakingNews = articles.skip(1).toList();

        // CustomScrollView diperlukan di dalam NestedScrollView body
        // agar scrollnya nyambung dengan header.
        return CustomScrollView(
          // Kunci agar tidak konflik scroll
          key: PageStorageKey<String>(category),
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.7,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    return _buildBreakingNewsCard(context, breakingNews[index]);
                  },
                  childCount:
                  breakingNews.length > 6 ? 6 : breakingNews.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        );
      },
    );
  }

  Widget _buildBreakingNewsCard(BuildContext context, Article article) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DetailScreen(article: article)),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: article.urlToImage ?? '',
                width: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) =>
                    Container(color: Colors.grey[200]),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            article.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            article.author ?? 'Unknown Author',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}