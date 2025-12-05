import 'package:aplikasi_news/core/models/article_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart'; // Pastikan package ini diimport
import 'package:intl/intl.dart';

class DetailScreen extends StatefulWidget {
  final Article article;

  const DetailScreen({super.key, required this.article});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // 1. Inisialisasi Variable TTS
  final FlutterTts flutterTts = FlutterTts();
  bool isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  // 2. Setup Konfigurasi Suara
  Future<void> _initTts() async {
    await flutterTts.setLanguage("en-US"); // Bahasa Inggris
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);

    // Kalau selesai bicara, tombol berubah jadi Play lagi
    flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          isSpeaking = false;
        });
      }
    });
  }

  // 3. Fungsi Play/Stop
  Future<void> _toggleSpeak() async {
    if (isSpeaking) {
      await flutterTts.stop();
      setState(() => isSpeaking = false);
    } else {
      // Gabungkan Judul dan Deskripsi untuk dibaca
      String textToRead = "${widget.article.title}. ${widget.article
          .description ?? ''}";

      if (textToRead
          .trim()
          .isNotEmpty) {
        setState(() => isSpeaking = true);
        await flutterTts.speak(textToRead);
      }
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // --- PERBAIKAN LOGIC TANGGAL ---
    // Karena publishedAt kamu sudah DateTime?, kita langsung pakai saja.
    // Tidak perlu DateTime.parse() lagi.
    DateTime? dateValue = widget.article.publishedAt;

    // Format tampilan tanggal
    final String formattedDate = dateValue != null
        ? DateFormat('dd MMM yyyy, HH:mm').format(dateValue)
        : 'No Date';
    // -------------------------------

    final bool isDark = Theme
        .of(context)
        .brightness == Brightness.dark;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _toggleSpeak,
        backgroundColor: isDark ? Colors.white : Colors.black,
        icon: Icon(
          isSpeaking ? Icons.stop_circle_outlined : Icons.play_circle_fill,
          color: isDark ? Colors.black : Colors.white,
        ),
        label: Text(
          isSpeaking ? "Stop" : "Listen",
          style: TextStyle(
            color: isDark ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            backgroundColor: Theme
                .of(context)
                .scaffoldBackgroundColor,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: widget.article.urlToImage ?? '',
                fit: BoxFit.cover,
                errorWidget: (context, url, error) =>
                    Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.article.title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.grey[200],
                            child: const Icon(Icons.person, size: 18),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${widget.article.author ??
                                  'Unknown Author'} • $formattedDate',
                              style: TextStyle(
                                color: isDark ? Colors.grey[400] : Colors
                                    .grey[700],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        widget.article.description ??
                            'No description available.',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.grey[300] : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.article.content ?? 'No content available.',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.grey[400] : Colors.grey[800],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "(Konten penuh mungkin tidak tersedia. Kunjungi situs asli untuk membaca lebih lanjut)",
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}