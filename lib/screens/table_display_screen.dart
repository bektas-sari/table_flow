// lib/screens/table_display_screen.dart

import 'package:flutter/material.dart';
import '../services/scraper_service.dart';
import '../widgets/dynamic_data_table.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_message.dart';

class TableDisplayScreen extends StatefulWidget {
  final String url;
  final int tableIndex;
  final TableData tableData;

  const TableDisplayScreen({
    Key? key,
    required this.url,
    required this.tableIndex,
    required this.tableData,
  }) : super(key: key);

  @override
  State<TableDisplayScreen> createState() => _TableDisplayScreenState();
}

class _TableDisplayScreenState extends State<TableDisplayScreen> {
  late TableData _currentTable;
  Future<TableData>? _refreshFuture;

  @override
  void initState() {
    super.initState();
    _currentTable = widget.tableData;
  }

  /// Yeniden çekme: aynı URL’dan tabloları tekrar alıp aynı index’teki tabloyu günceller
  void _refreshTable() {
    setState(() {
      _refreshFuture = ScraperService().fetchAllTables(widget.url).then((tables) {
        if (widget.tableIndex < tables.length) {
          return tables[widget.tableIndex];
        } else {
          throw Exception('Table index out of range on refresh.');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Table ${widget.tableIndex + 1}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _refreshFuture == null
            ? _buildTableView(_currentTable)
            : FutureBuilder<TableData>(
          future: _refreshFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingIndicator();
            } else if (snapshot.hasError) {
              return ErrorMessage(
                message: 'Error refreshing table:\n${snapshot.error}',
                onRetry: () {
                  setState(() {
                    _refreshFuture = null;
                  });
                },
              );
            } else if (snapshot.hasData) {
              _currentTable = snapshot.data!;
              // refreshFuture sıfırla, ardından UI güncellenmiş tabloyu gösterecek
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _refreshFuture = null;
                });
              });
              return _buildTableView(_currentTable);
            } else {
              return const Center(child: Text('No data.'));
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshTable,
        child: const Icon(Icons.refresh),
        tooltip: 'Refresh this table',
      ),
    );
  }

  /// TableData’dan DynamicDataTable oluştur
  Widget _buildTableView(TableData table) {
    if (table.headers.isEmpty && table.rows.isEmpty) {
      return const Center(child: Text('Empty table.'));
    }
    // DataTable göster
    return Column(
      children: [
        Expanded(
          child: DynamicDataTable(
            columnLabels: table.headers,
            rows: table.rows,
          ),
        ),
      ],
    );
  }
}
