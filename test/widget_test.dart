import 'package:flutter_test/flutter_test.dart';
import 'package:device_log/providers/filter_bar_provider.dart';

void main() {
  group('FilterProvider Tests', () {
    
    test('Başlangıç değerleri doğru olmalı', () {
      final provider = FilterProvider();
      expect(provider.search, "");
      expect(provider.status, "hepsi");
      expect(provider.sort, "new");
    });

    test('setSearch çalışmalı', () {
      final provider = FilterProvider();
      provider.setSearch("test");
      expect(provider.search, "test");
    });

    test('setStatus çalışmalı', () {
      final provider = FilterProvider();
      provider.setStatus("arızalı");
      expect(provider.status, "arızalı");
    });

    test('setSort çalışmalı', () {
      final provider = FilterProvider();
      provider.setSort("old");
      expect(provider.sort, "old");
    });

    test('reset çalışmalı', () {
      final provider = FilterProvider();
      provider.setSearch("test");
      provider.setStatus("arızalı");
      provider.reset();
      expect(provider.search, "");
      expect(provider.status, "hepsi");
      expect(provider.sort, "new");
    });

    test('filterAndSort status filtresi çalışmalı', () {
      final provider = FilterProvider();
      provider.setStatus("arızalı");

      final data = [
        {"name": "Cihaz 1", "status": "arızalı", "createdAt": null},
        {"name": "Cihaz 2", "status": "çalışıyor", "createdAt": null},
      ];

      final result = provider.filterAndSort(
        data: data,
        statusField: (d) => d["status"],
        dateField: (d) => DateTime.now(),
        searchMatch: (d, s) => d["name"].toString().contains(s),
      );

      expect(result.length, 1);
      expect(result[0]["name"], "Cihaz 1");
    });

  });
}