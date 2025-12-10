import 'package:aplikasi_news/core/models/article_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
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

  // 2. Inisialisasi Variable FONT SIZE
  // Ukuran default konten adalah 16.0
  double _baseFontSize = 16.0;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(1);

    flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          isSpeaking = false;
        });
      }
    });
  }

  Future<void> _toggleSpeak() async {
    if (isSpeaking) {
      await flutterTts.stop();
      setState(() => isSpeaking = false);
    } else {
      String textToRead = "${widget.article.title}. ${widget.article.description ?? ''}";

      if (textToRead.trim().isNotEmpty) {
        setState(() => isSpeaking = true);
        await flutterTts.speak(textToRead);
      }
    }
  }

  // 3. FUNGSI MENAMPILKAN PENGATURAN FONT (BOTTOM SHEET)
  void _showFontSettings(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
            builder: (context, setModalState) {
              return Container(
                padding: const EdgeInsets.all(24),
                height: 180,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Text Size",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        // Ikon Kecil
                        Icon(Icons.text_fields, size: 16, color: isDark ? Colors.grey : Colors.grey[600]),
                        Expanded(
                          child: Slider(
                            value: _baseFontSize,
                            min: 14.0, // Ukuran terkecil
                            max: 30.0, // Ukuran terbesar
                            divisions: 8, // Jumlah langkah geser
                            activeColor: isDark ? Colors.white : Colors.black,
                            inactiveColor: Colors.grey[300],
                            onChanged: (value) {
                              // Update UI BottomSheet (Slider jalan)
                              setModalState(() {});
                              // Update UI Layar Utama (Teks berubah)
                              setState(() {
                                _baseFontSize = value;
                              });
                            },
                          ),
                        ),
                        // Ikon Besar
                        Icon(Icons.text_fields, size: 32, color: isDark ? Colors.grey : Colors.grey[600]),
                      ],
                    ),
                    Center(
                      child: Text(
                        "Drag to adjust size",
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    )
                  ],
                ),
              );
            }
        );
      },
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DateTime? dateValue = widget.article.publishedAt;

    final String formattedDate = dateValue != null
        ? DateFormat('dd MMM yyyy, HH:mm').format(dateValue)
        : 'No Date';

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

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
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,

            // TOMBOL BACK (KIRI)
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

            // TOMBOL FONT SETTINGS (KANAN)
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    // Icon 'text_fields' melambangkan pengaturan teks
                    icon: const Icon(Icons.text_fields, color: Colors.black),
                    onPressed: () => _showFontSettings(isDark),
                  ),
                ),
              ),
            ],

            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: widget.article.urlToImage ?? '',
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
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
                      // --- JUDUL (Ukuran dinamis) ---
                      // Base + 8 (Judul selalu lebih besar dari konten)
                      Text(
                        widget.article.title,
                        style: TextStyle(
                          fontSize: _baseFontSize + 8,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // --- AUTHOR & TANGGAL ---
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
                              '${widget.article.author ?? 'Unknown Author'} • $formattedDate',
                              style: TextStyle(
                                color: isDark ? Colors.grey[400] : Colors.grey[700],
                                fontSize: 14, // Meta data biarkan statis/kecil
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // --- DESKRIPSI (Ukuran dinamis) ---
                      // Base + 2 (Sedikit lebih besar dari konten body)
                      Text(
                        widget.article.description ?? 'No description available.',
                        style: TextStyle(
                          fontSize: _baseFontSize + 2,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.grey[300] : Colors.black87,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // --- KONTEN UTAMA (Ukuran dinamis) ---
                      // Menggunakan _baseFontSize
                      Text(
                        widget.article.content ?? 'No content available.',
                        style: TextStyle(
                          fontSize: _baseFontSize,
                          color: isDark ? Colors.grey[400] : Colors.grey[800],
                          height: 1.6, // Jarak antar baris biar enak dibaca
                        ),
                      ),
                      const SizedBox(height: 10),

                      // --- FOOTER NOTE ---
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