// lib/widgets/dynamic_data_table.dart

import 'package:flutter/material.dart';

/// DynamicDataTable: runtime’da sütun etiketleri ve satır verileriyle DataTable oluşturur.
/// columnLabels: List<String>
/// rows: List<List<String>>
class DynamicDataTable extends StatefulWidget {
  final List<String> columnLabels;
  final List<List<String>> rows;

  const DynamicDataTable({
    Key? key,
    required this.columnLabels,
    required this.rows,
  }) : super(key: key);

  @override
  State<DynamicDataTable> createState() => _DynamicDataTableState();
}

class _DynamicDataTableState extends State<DynamicDataTable> {
  int? _sortColumnIndex;
  bool _sortAscending = true;
  late List<List<String>> _displayedRows;

  @override
  void initState() {
    super.initState();
    _displayedRows = List.from(widget.rows);
  }

  @override
  void didUpdateWidget(covariant DynamicDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rows != widget.rows) {
      _displayedRows = List.from(widget.rows);
      _sortColumnIndex = null;
      _sortAscending = true;
    }
  }

  void _sort(int columnIndex) {
    setState(() {
      if (_sortColumnIndex == columnIndex) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumnIndex = columnIndex;
        _sortAscending = true;
      }
      _displayedRows.sort((a, b) {
        final aVal = a.length > columnIndex ? a[columnIndex] : '';
        final bVal = b.length > columnIndex ? b[columnIndex] : '';
        // Sayısal mı parse et
        final num? aNum = num.tryParse(aVal.replaceAll(',', '.'));
        final num? bNum = num.tryParse(bVal.replaceAll(',', '.'));
        int cmp;
        if (aNum != null && bNum != null) {
          cmp = aNum.compareTo(bNum);
        } else {
          cmp = aVal.toLowerCase().compareTo(bVal.toLowerCase());
        }
        return _sortAscending ? cmp : -cmp;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final colCount = widget.columnLabels.length;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        sortColumnIndex: _sortColumnIndex,
        sortAscending: _sortAscending,
        columns: List.generate(colCount, (index) {
          return DataColumn(
            label: Text(widget.columnLabels[index]),
            onSort: (i, asc) {
              _sort(i);
            },
          );
        }),
        rows: _displayedRows.map((row) {
          return DataRow(
            cells: List.generate(colCount, (i) {
              final text = row.length > i ? row[i] : '';
              return DataCell(Text(text));
            }),
          );
        }).toList(),
      ),
    );
  }
}
