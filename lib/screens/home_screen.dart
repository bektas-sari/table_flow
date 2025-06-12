// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import '../services/scraper_service.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_message.dart';
import 'table_list_screen.dart';
import 'manual_selector_screen.dart'; // manuel moda geçiş ekranı

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();
  Future<List<TableData>>? _tablesFuture;
  String? _currentUrl;
  bool _autoModeTried = false; // otomatik mod denendi mi

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _loadTablesAuto() {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen geçerli bir URL girin.')),
      );
      return;
    }
    setState(() {
      _currentUrl = url;
      _autoModeTried = true;
      _tablesFuture = ScraperService().fetchAllTables(url);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TableFlow')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Enter URL',
                hintText: 'https://example.com/page.html',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
              onSubmitted: (_) => _loadTablesAuto(),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loadTablesAuto,
              icon: const Icon(Icons.download),
              label: const Text('Load Tables (Auto)'),
            ),
            const SizedBox(height: 16),
            if (_tablesFuture == null)
              const Expanded(
                child: Center(child: Text('Enter URL and tap Load Tables.')),
              )
            else
              Expanded(
                child: FutureBuilder<List<TableData>>(
                  future: _tablesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LoadingIndicator();
                    } else if (snapshot.hasError) {
                      // Hata: sunucu erişim vs.
                      return ErrorMessage(
                        message:
                        'Error loading tables:\n${snapshot.error}',
                        onRetry: _loadTablesAuto,
                      );
                    } else if (snapshot.hasData) {
                      final tables = snapshot.data!;
                      if (tables.isEmpty) {
                        // Otomatik mod boş döndü: Manuel moda yönlendir
                        return _buildNoTableFound();
                      }
                      // Otomatik tablolar bulundu: TableListScreen’e geç
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TableListScreen(
                              url: _currentUrl!,
                              tables: tables,
                            ),
                          ),
                        );
                      });
                      return const SizedBox.shrink();
                    } else {
                      return const Center(child: Text('No data.'));
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoTableFound() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.table_chart_outlined,
            size: 48, color: Colors.grey),
        const SizedBox(height: 8),
        const Text(
          'No <table> element found on this page.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () {
            // Manuel CSS selector girişi ekranına geç
            if (_currentUrl != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ManualSelectorScreen(url: _currentUrl!),
                ),
              );
            }
          },
          icon: const Icon(Icons.edit),
          label: const Text('Manual Selector Mode'),
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            'Bu sayfada doğrudan <table> bulunamadı veya dinamik HTML ile yükleniyor olabilir. '
                'Manuel CSS seçici girerek veriyi parse etmeyi deneyin.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ),
      ],
    );
  }
}
