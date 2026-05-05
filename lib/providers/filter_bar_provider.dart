import 'package:flutter/material.dart';


class FilterProvider extends ChangeNotifier {
  String search = "";
  String status = "hepsi";
  String sort = "new";

  void setSearch(String value) {
    search = value.trim();
    notifyListeners();
  }

  void setStatus(String value) {
    status = value;
    notifyListeners();
  }

  void setSort(String value) {
    sort = value;
    notifyListeners();
  }


  List filterAndSort({
    required List data,
    required bool Function(dynamic item, String search) searchMatch,
    required String Function(dynamic item) statusField,
    required DateTime Function(dynamic item) dateField,
  }) {
    final filtered = data.where((item) {
      final statusOk = status == "hepsi" || statusField(item) == status;
      final searchOk = search.isEmpty || searchMatch(item, search);
      return statusOk && searchOk;
    }).toList();

    filtered.sort((a, b) {
      final aDate = dateField(a);
      final bDate = dateField(b);

      return sort == "new"
          ? bDate.compareTo(aDate)
          : aDate.compareTo(bDate);
    });

    return filtered;
  }

  void reset() {
  search = "";
  status = "hepsi";
  sort = "new";
  notifyListeners();
}
}