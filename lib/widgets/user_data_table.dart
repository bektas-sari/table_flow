// lib/widgets/user_data_table.dart
import 'package:flutter/material.dart';
import '../models/user.dart';

/// Kullanıcı listesini DataTable ile gösterir.
/// Basit sıralama desteği içerir.
class UserDataTable extends StatefulWidget {
  final List<User> users;

  const UserDataTable({Key? key, required this.users}) : super(key: key);

  @override
  State<UserDataTable> createState() => _UserDataTableState();
}

class _UserDataTableState extends State<UserDataTable> {
  int? _sortColumnIndex;
  bool _sortAscending = true;
  late List<User> _displayedUsers;

  @override
  void initState() {
    super.initState();
    _displayedUsers = List.from(widget.users);
  }

  @override
  void didUpdateWidget(covariant UserDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Yeni veri geldiğinde sıralama sıfırlanabilir
    _displayedUsers = List.from(widget.users);
    _sortColumnIndex = null;
    _sortAscending = true;
  }

  void _sort<T>(Comparable<T> Function(User u) getField, int columnIndex, bool ascending) {
    _displayedUsers.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Eğer çok fazla sütun yoksa aşağıdaki üç sütun örneğine göre düzenleyin
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        sortColumnIndex: _sortColumnIndex,
        sortAscending: _sortAscending,
        columns: [
          DataColumn(
            label: const Text('ID'),
            numeric: true,
            onSort: (i, asc) => _sort<num>((u) => u.id, i, asc),
          ),
          DataColumn(
            label: const Text('Name'),
            onSort: (i, asc) => _sort<String>((u) => u.name, i, asc),
          ),
          DataColumn(
            label: const Text('Email'),
            onSort: (i, asc) => _sort<String>((u) => u.email, i, asc),
          ),
          // Eğer modelde ekstra alanlar varsa buraya ekleyin
        ],
        rows: _displayedUsers.map((user) {
          return DataRow(cells: [
            DataCell(Text(user.id.toString())),
            DataCell(Text(user.name)),
            DataCell(Text(user.email)),
          ]);
        }).toList(),
      ),
    );
  }
}
