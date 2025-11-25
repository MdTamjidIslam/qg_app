// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
//
// class RecommendedItem {
//   final String name;
//   final String img;
//   final String androidUrl;
//   final String webUrl;
//
//   const RecommendedItem({
//     required this.name,
//     required this.img,
//     required this.androidUrl,
//     required this.webUrl,
//   });
//
//   factory RecommendedItem.fromJson(Map<String, dynamic> j) => RecommendedItem(
//     name: (j['name'] ?? '').toString(),
//     img: (j['img'] ?? '').toString(),
//     androidUrl: (j['androidurl'] ?? '').toString(),
//     webUrl: (j['url'] ?? '').toString(),
//   );
// }
//
// class RecommendedProvider extends ChangeNotifier {
//   final String api =
//       'http://172.16.16.241/dynamic_flutter/public/api/v1/recommended';
//
//   final List<RecommendedItem> _items = [];
//   bool _loading = false;
//   String? _error;
//
//   List<RecommendedItem> get items => List.unmodifiable(_items);
//   bool get loading => _loading;
//   String? get error => _error;
//
//   Future<void> fetch({bool force = false}) async {
//     if (_loading) return;
//     if (_items.isNotEmpty && !force) return;
//
//     _loading = true; _error = null; notifyListeners();
//     try {
//       final res =
//       await http.get(Uri.parse(api)).timeout(const Duration(seconds: 12));
//       if (res.statusCode != 200) {
//         _error = 'HTTP ${res.statusCode}';
//       } else {
//         final body = json.decode(res.body);
//         final list = (body is Map &&
//             body['data'] is Map &&
//             body['data']['list'] is List)
//             ? (body['data']['list'] as List).whereType<Map<String, dynamic>>()
//             : const <Map<String, dynamic>>[];
//
//         _items
//           ..clear()
//           ..addAll(list
//               .map(RecommendedItem.fromJson)
//               .where((e) => e.img.isNotEmpty));
//         if (_items.isEmpty) _error = 'Empty list';
//       }
//     } on TimeoutException {
//       _error = 'Request timeout';
//     } catch (e) {
//       _error = e.toString();
//     } finally {
//       _loading = false; notifyListeners();
//     }
//   }
// }

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';      // db.txt পড়ার জন্য
import 'package:http/http.dart' as http;

class RecommendedItem {
  final int id;
  final String name;
  final String img;
  final String androidUrl;
  final String webUrl;

  const RecommendedItem({
    required this.id,
    required this.name,
    required this.img,
    required this.androidUrl,
    required this.webUrl,
  });

  factory RecommendedItem.fromJson(Map<String, dynamic> j) => RecommendedItem(
    id: j['id'] is int
        ? j['id'] as int
        : int.tryParse('${j['id'] ?? 0}') ?? 0,
    name: (j['name'] ?? '').toString(),
    img: (j['img'] ?? '').toString(),
    androidUrl: (j['android_url'] ?? '').toString(),
    webUrl: (j['product_link'] ?? '').toString(),
  );
}


class RecommendedProvider extends ChangeNotifier {
  // ✅ নতুন POST API (পুরনো /dynamic_flutter/public/api/v1/recommended না)
  final String api =
      'http://172.16.16.241/video_store/public/api/v1/category-product';

  final List<RecommendedItem> _items = [];
  bool _loading = false;
  String? _error;

  List<RecommendedItem> get items => List.unmodifiable(_items);
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetch({bool force = false}) async {
    if (_loading) return;
    if (_items.isNotEmpty && !force) return;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      // 1️⃣ assets/db/db.txt থেকে JSON পড়া
      final txt = await rootBundle.loadString('assets/db.txt');
      final cfg = jsonDecode(txt);

      if (cfg is! Map || cfg['recommended'] == null) {
        throw 'recommended not found in db.txt';
      }

      final rec = cfg['recommended'] as Map<String, dynamic>;

      // 2️⃣ txt এর recommended object থেকে POST body তৈরি
      final payload = {
        'category_id': rec['category_id'] ?? 0,
        'product_count': rec['product_count'] ?? 0,
        'title': rec['title'] ?? '',
        'product_ids': rec['product_ids'] ?? [],
      };

      if (kDebugMode) {
        print('🔵 Recommended payload from db.txt: $payload');
      }

      // 3️⃣ POST request পাঠানো
      final res = await http
          .post(
        Uri.parse(api),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      )
          .timeout(const Duration(seconds: 12));

      if (kDebugMode) {
        print('🟣 Status: ${res.statusCode}');
        print('🟣 Body: ${res.body}');
      }

      if (res.statusCode != 200) {
        _error = 'HTTP ${res.statusCode}';
      } else {
        final body = json.decode(res.body);

        // body: { status: true, data: { title: "...", list: [ ... ] } }
        final list = (body is Map &&
            body['data'] is Map &&
            body['data']['list'] is List)
            ? (body['data']['list'] as List).whereType<Map<String, dynamic>>()
            : const <Map<String, dynamic>>[];

        _items
          ..clear()
          ..addAll(
            list
                .map(RecommendedItem.fromJson)
                .where((e) => e.img.isNotEmpty),
          );

        if (_items.isEmpty) _error = 'Empty list';
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
