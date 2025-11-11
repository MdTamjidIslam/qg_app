import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class OtherItem {
  final String name;
  final String img;
  final String slogan;
  final String androidUrl;
  final String webUrl;
  final bool isApk;
  final bool isBrowser;

  const OtherItem({
    required this.name,
    required this.img,
    required this.slogan,
    required this.androidUrl,
    required this.webUrl,
    required this.isApk,
    required this.isBrowser,
  });

  factory OtherItem.fromJson(Map<String, dynamic> j) => OtherItem(
    name: (j['name'] ?? '').toString(),
    img: (j['img'] ?? '').toString(),
    slogan: (j['slogan'] ?? '').toString(),
    androidUrl: (j['androidurl'] ?? '').toString(),
    webUrl: (j['url'] ?? '').toString(),
    isApk: (j['is_apk'] ?? '').toString() == '1',
    isBrowser: (j['is_browser'] ?? '').toString() == '1',
  );
}

class OtherProvider extends ChangeNotifier {
  final String api = 'http://172.16.16.253/dynamic_flutter/public/api/v1/other';
  final List<OtherItem> _items = [];
  bool _loading = false;
  String? _error;
  List<OtherItem> get items => List.unmodifiable(_items);
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetch({bool force = false}) async {
    print(api);
    print('ldldlll 000000000');
    if (_loading) return;
    if (_items.isNotEmpty && !force) return;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await http.get(Uri.parse(api)).timeout(const Duration(seconds: 12));
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
          ..addAll(
            list.map(OtherItem.fromJson).where((e) => e.img.isNotEmpty && e.name.isNotEmpty),
          );

        if (_items.isEmpty) _error = 'Empty other list';
      }
    } on TimeoutException {
      _error = 'Request timeout';
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}


class DatingZoneApiItem {
  final String name;
  final String img;        // photo
  final String slogan;     // optional
  final String androidUrl; // optional
  final String webUrl;     // optional

  const DatingZoneApiItem({
    required this.name,
    required this.img,
    required this.slogan,
    required this.androidUrl,
    required this.webUrl,
  });

  factory DatingZoneApiItem.fromJson(Map<String, dynamic> j) => DatingZoneApiItem(
    name: (j['name'] ?? '').toString(),
    img: (j['img'] ?? '').toString(),
    slogan: (j['slogan'] ?? '').toString(),
    androidUrl: (j['androidurl'] ?? '').toString(),
    webUrl: (j['url'] ?? '').toString(),
  );
}

class DatingZoneProvider extends ChangeNotifier {
  final String api = 'http://172.16.16.253/dynamic_flutter/public/api/v1/dating-zone';

  final List<DatingZoneApiItem> _items = [];
  bool _loading = false;
  String? _error;

  List<DatingZoneApiItem> get items => List.unmodifiable(_items);
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetch({bool force = false}) async {
    if (_loading) return;
    if (_items.isNotEmpty && !force) return;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await http.get(Uri.parse(api)).timeout(const Duration(seconds: 12));
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
          ..addAll(
            list.map(DatingZoneApiItem.fromJson).where((e) => e.img.isNotEmpty && e.name.isNotEmpty),
          );

        if (_items.isEmpty) _error = 'Empty dating list';
      }
    } on TimeoutException {
      _error = 'Request timeout';
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
