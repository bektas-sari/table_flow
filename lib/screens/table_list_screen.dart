// lib/screens/table_list_screen.dart

import 'package:flutter/material.dart';
import '../services/scraper_service.dart';
import 'table_display_screen.dart';

class TableListScreen extends StatelessWidget {
  final String url;
  final List<TableData> tables;

  const TableListScreen({
    Key? key,
    required this.url,
    required this.tables,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a Table'),
      ),
      body: ListView.builder(
        itemCount: tables.length,
        itemBuilder: (context, index) {
          final table = tables[index];
          // Preview: ilk birkaç satırı veya headers göster
          String previewText;
          if (table.headers.isNotEmpty) {
            previewText = 'Headers: ${table.headers.join(', ')}';
          } else if (table.rows.isNotEmpty) {
            final firstRow = table.rows.first;
            previewText =
            'Row 1: ${firstRow.map((cell) => cell.length <= 20 ? cell : cell.substring(0, 20) + '...').join(' | ')}';
          } else {
            previewText = 'Empty table';
          }
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text('Table ${index + 1}'),
              subtitle: Text(previewText),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TableDisplayScreen(
                      url: url,
                      tableIndex: index,
                      tableData: table,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
