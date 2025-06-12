// lib/screens/manual_selector_screen.dart

import 'package:flutter/material.dart';
import '../services/scraper_service.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_message.dart';
import '../widgets/dynamic_data_table.dart';

class ManualSelectorScreen extends StatefulWidget {
  final String url;
  const ManualSelectorScreen({Key? key, required this.url}) : super(key: key);

  @override
  State<ManualSelectorScreen> createState() => _ManualSelectorScreenState();
}

class _ManualSelectorScreenState extends State<ManualSelectorScreen> {
  final TextEditingController _rowSelectorController = TextEditingController();
  final TextEditingController _colSelectorsController =
  TextEditingController();
  final TextEditingController _colLabelsController = TextEditingController();

  Future<TableData>? _tableFuture;

  @override
  void dispose() {
    _rowSelectorController.dispose();
    _colSelectorsController.dispose();
    _colLabelsController.dispose();
    super.dispose();
  }

  void _loadWithSelector() {
    final rowSel = _rowSelectorController.text.trim();
    final colSelText = _colSelectorsController.text.trim();
    final colLabelText = _colLabelsController.text.trim();

    if (rowSel.isEmpty || colSelText.isEmpty || colLabelText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm alanları doldurun.')),
      );
      return;
    }
    final colSelectors = colSelText
        .split(';')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final colLabels = colLabelText
        .split(';')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (colSelectors.length != colLabels.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
            Text('Column selectors ve labels sayısı eşit olmalı.')),
      );
      return;
    }

    setState(() {
      _tableFuture = ScraperService().fetchHtml(widget.url).then((html) {
        return ScraperService().parseTableBySelector(
          htmlString: html,
          rowSelector: rowSel,
          columnSelectors: colSelectors,
          // headerSelectors: istersen ek parametre olarak alıp parse edebilirsin.
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manual Selector Mode')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'URL: ${widget.url}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _rowSelectorController,
              decoration: const InputDecoration(
                labelText: 'Row CSS Selector',
                hintText: 'e.g. div.item-row veya .product-card',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _loadWithSelector(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _colSelectorsController,
              decoration: const InputDecoration(
                labelText: 'Column CSS Selectors (;)',
                hintText: 'e.g. span.name;span.price',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _loadWithSelector(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _colLabelsController,
              decoration: const InputDecoration(
                labelText: 'Column Labels (;)',
                hintText: 'e.g. Name;Price',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _loadWithSelector(),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadWithSelector,
              icon: const Icon(Icons.playlist_add_check),
              label: const Text('Load with Selector'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _tableFuture == null
                  ? const Center(
                  child: Text(
                      'Enter selectors and tap Load with Selector.'))
                  : FutureBuilder<TableData>(
                future: _tableFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const LoadingIndicator();
                  } else if (snapshot.hasError) {
                    return ErrorMessage(
                      message:
                      'Error parsing with selector:\n${snapshot.error}',
                      onRetry: () {
                        setState(() {
                          _tableFuture = null;
                        });
                      },
                    );
                  } else if (snapshot.hasData) {
                    final table = snapshot.data!;
                    if (table.rows.isEmpty) {
                      return const Center(
                          child: Text(
                              'No rows found with given selector.'));
                    }
                    return DynamicDataTable(
                      columnLabels: table.headers,
                      rows: table.rows,
                    );
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
}
