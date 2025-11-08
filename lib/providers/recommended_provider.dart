import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class RecommendedItem {
  final String name;
  final String img;
  final String androidUrl;
  final String webUrl;

  const RecommendedItem({
    required this.name,
    required this.img,
    required this.androidUrl,
    required this.webUrl,
  });

  factory RecommendedItem.fromJson(Map<String, dynamic> j) => RecommendedItem(
    name: (j['name'] ?? '').toString(),
    img: (j['img'] ?? '').toString(),
    androidUrl: (j['androidurl'] ?? '').toString(),
    webUrl: (j['url'] ?? '').toString(),
  );
}

class RecommendedProvider extends ChangeNotifier {
  final String api =
      'http://172.16.16.253/dynamic_flutter/public/api/v1/recommended';

  final List<RecommendedItem> _items = [];
  bool _loading = false;
  String? _error;

  List<RecommendedItem> get items => List.unmodifiable(_items);
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetch({bool force = false}) async {
    if (_loading) return;
    if (_items.isNotEmpty && !force) return;

    _loading = true; _error = null; notifyListeners();
    try {
      final res =
      await http.get(Uri.parse(api)).timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) {
        _error = 'HTTP ${res.statusCode}';
      } else {
        final body = json.decode(res.body);
        final list = (body is Map &&
            body['data'] is Map &&
            body['data']['list'] is List)
            ? (body['data']['list'] as List).whereType<Map<String, dynamic>>()
            : const <Map<String, dynamic>>[];

        _items
          ..clear()
          ..addAll(list
              .map(RecommendedItem.fromJson)
              .where((e) => e.img.isNotEmpty));
        if (_items.isEmpty) _error = 'Empty list';
      }
    } on TimeoutException {
      _error = 'Request timeout';
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false; notifyListeners();
    }
  }
}
