// lib/services/scraper_service.dart

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

class TableData {
  final List<String> headers;
  final List<List<String>> rows;
  TableData({required this.headers, required this.rows});
}

class ScraperService {
  Future<String> fetchHtml(String url) async {
    final uri = Uri.parse(_ensureScheme(url));
    final headers = {
      'User-Agent':
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
          'AppleWebKit/537.36 (KHTML, like Gecko) '
          'Chrome/114.0.0.0 Safari/537.36',
      'Accept':
      'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
    };
    final response =
    await http.get(uri, headers: headers).timeout(const Duration(seconds: 15));
    final status = response.statusCode;
    if (status >= 200 && status < 300) {
      return response.body;
    } else {
      throw Exception('HTTP error: $status');
    }
  }

  Future<List<TableData>> fetchAllTables(String url) async {
    final htmlString = await fetchHtml(url);
    final document = parse(htmlString);
    final tableElements = document.getElementsByTagName('table');
    List<TableData> tables = [];
    for (final table in tableElements) {
      // Başlıkları al
      List<String> headers = [];
      Element? headerRow = table.querySelector('thead tr');
      if (headerRow == null) {
        final firstRow = table.querySelector('tr');
        if (firstRow != null) {
          final ths = firstRow.querySelectorAll('th');
          if (ths.isNotEmpty) headerRow = firstRow;
        }
      }
      if (headerRow != null) {
        final ths = headerRow.querySelectorAll('th');
        headers = ths.map((e) => e.text.trim()).where((s) => s.isNotEmpty).toList();
      }
      // Satırları al
      final rowElements = table.querySelectorAll('tr');
      List<List<String>> rows = [];
      for (final rowEl in rowElements) {
        if (headerRow != null && rowEl == headerRow) continue;
        final tds = rowEl.querySelectorAll('td');
        if (tds.isEmpty) continue;
        rows.add(tds.map((e) => e.text.trim()).toList());
      }
      if (headers.isEmpty && rows.isNotEmpty) {
        final colCount = rows.first.length;
        headers = List<String>.generate(colCount, (i) => 'Column ${i + 1}');
      }
      if (headers.isNotEmpty || rows.isNotEmpty) {
        tables.add(TableData(headers: headers, rows: rows));
      }
    }
    return tables;
  }

  /// Manuel CSS selector’larla parse:
  /// - rowSelector: e.g. ".row-class" veya "div.item"
  /// - columnSelectors: her hücre için CSS seçici, e.g. ["span.name", "span.price"]
  Future<TableData> parseTableBySelector({
    required String htmlString,
    required String rowSelector,
    required List<String> columnSelectors,
    List<String>? headerSelectors, // isteğe bağlı: header için CSS seçici listesi
  }) async {
    final document = parse(htmlString);
    final rows = document.querySelectorAll(rowSelector);
    List<List<String>> dataRows = [];
    for (final row in rows) {
      List<String> cells = [];
      for (final colSel in columnSelectors) {
        try {
          final elem = row.querySelector(colSel);
          cells.add(elem?.text.trim() ?? '');
        } catch (_) {
          cells.add('');
        }
      }
      dataRows.add(cells);
    }
    // Header: eğer headerSelectors verilmiş ve uzunluk columnSelectors ile eşitse
    List<String> headers = [];
    if (headerSelectors != null && headerSelectors.length == columnSelectors.length) {
      final headerElems = document.querySelectorAll(headerSelectors.join(','));
      // Bu basit örnek, genelde header row’u da seçiciyle alıp parse etmek lazım.
      // İsterseniz: rowSelector kullanarak header row’u seçip headerSelectors ile parse edin.
      // Örnek: headerSelectors = ["th.col1", "th.col2"] vs.
      // Burada basitçe headerSelectors ilk elementi parse ediyoruz:
      // (Detaylı uygulama projenize uyarlayın.)
      headers = headerSelectors.map((sel) {
        final elem = document.querySelector(sel);
        return elem?.text.trim() ?? '';
      }).toList();
    }
    // Eğer headerSelectors yoksa otomatik oluştur:
    if (headers.isEmpty && dataRows.isNotEmpty) {
      final colCount = dataRows.first.length;
      headers = List<String>.generate(colCount, (i) => 'Column ${i + 1}');
    }
    return TableData(headers: headers, rows: dataRows);
  }

  Future<TableData> fetchAndParseWithSelector({
    required String url,
    required String rowSelector,
    required List<String> columnSelectors,
  }) async {
    final htmlString = await fetchHtml(url);
    return parseTableBySelector(
      htmlString: htmlString,
      rowSelector: rowSelector,
      columnSelectors: columnSelectors,
    );
  }

  String _ensureScheme(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    return 'https://$url';
  }
}
