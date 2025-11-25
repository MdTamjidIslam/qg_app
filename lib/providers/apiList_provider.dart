import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart'; // db.txt পড়ার জন্য
import 'package:http/http.dart' as http;

/// =====================
/// MODEL: OtherItem
/// =====================
class OtherItem {
  final int id;
  final String name;
  final String img;
  final String slogan;
  final String androidUrl;
  final String webUrl;
  final bool isApk;
  final bool isBrowser;

  const OtherItem({
    required this.id,
    required this.name,
    required this.img,
    required this.slogan,
    required this.androidUrl,
    required this.webUrl,
    required this.isApk,
    required this.isBrowser,
  });

  factory OtherItem.fromJson(Map<String, dynamic> j) => OtherItem(
    id: j['id'] is int
        ? j['id'] as int
        : int.tryParse('${j['id'] ?? 0}') ?? 0,
    name: (j['name'] ?? '').toString(),
    // category-product রেসপন্সে img ফিল্ড আছে
    img: (j['img'] ?? '').toString(),
    // backend এ আলাদা slogan না থাকলে content কে স্লোগান হিসেবে নিলাম
    slogan: (j['slogan'] ?? j['content'] ?? '').toString(),
    // নতুন API ফিল্ড নাম
    androidUrl: (j['android_url'] ?? '').toString(),
    webUrl: (j['product_link'] ?? '').toString(),
    isApk: (j['is_apk'] ?? '0').toString() == '1',
    isBrowser: (j['is_browser'] ?? '0').toString() == '1',
  );
}

/// =====================
/// PROVIDER: OtherProvider
/// =====================
class OtherProvider extends ChangeNotifier {
  /// পুরনো /dynamic_flutter/.../other না,
  /// এখন সব জায়গায় POST: /video_store/public/api/v1/category-product
  final String api =
      'http://172.16.16.241/video_store/public/api/v1/category-product';

  final List<OtherItem> _items = [];
  bool _loading = false;
  String? _error;

  List<OtherItem> get items => List.unmodifiable(_items);
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetch({bool force = false}) async {
    if (_loading) return;
    if (_items.isNotEmpty && !force) return;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      // 1️⃣ db.txt থেকে JSON পড়া
      // NOTE: pubspec.yaml এ path যেমন দিয়েছো,
      // assets:
      //   - assets/db.txt
      // তাহলে এখানে 'assets/db.txt' সঠিক
      final txt = await rootBundle.loadString('assets/db.txt');
      final dynamic raw = jsonDecode(txt);

      if (raw is! Map) {
        throw 'Invalid db.txt format (expecting JSON object)';
      }

      final Map<String, dynamic> cfg = raw.cast<String, dynamic>();

      /// 2️⃣ কোন MAP থেকে আমরা Others-এর জন্য payload নিবো?
      ///
      /// প্রথম চেষ্টা: cfg['recommended_others'] (যদি নাম ঠিকমতো দেওয়া থাকে)
      Map<String, dynamic>? src;

      if (cfg['recommended_others'] is Map<String, dynamic>) {
        src = cfg['recommended_others'] as Map<String, dynamic>;
      }

      /// দ্বিতীয় চেষ্টা: এমন child map খুঁজবো, যেখানে category_id == 20
      /// (তুমি চাইলে এই আইডি বদলাতে পারো)
      if (src == null) {
        for (final entry in cfg.entries) {
          final value = entry.value;
          if (value is Map<String, dynamic> &&
              value['category_id'] == 20) {
            src = value;
            break;
          }
        }
      }

      /// তৃতীয় চেষ্টা: যে কোনো child map যার ভেতরে category_id আছে
      if (src == null) {
        for (final entry in cfg.entries) {
          final value = entry.value;
          if (value is Map<String, dynamic> &&
              value.containsKey('category_id')) {
            src = value;
            break;
          }
        }
      }

      /// কিছুই না পেলে root থেকেই চেষ্টা করি (edge case)
      src ??= cfg;

      // 3️⃣ শুধু এই চারটা ফিল্ড use করব
      final payload = {
        'category_id': src['category_id'] ?? 0,
        'product_count': src['product_count'] ?? 0,
        'title': src['title'] ?? '',
        'product_ids': src['product_ids'] is List
            ? src['product_ids']
            : <dynamic>[],
      };

      if (kDebugMode) {
        print('🔵 Other payload from db.txt: $payload');
      }

      // 4️⃣ POST request
      final res = await http
          .post(
        Uri.parse(api),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      )
          .timeout(const Duration(seconds: 12));

      if (kDebugMode) {
        print('🟣 Other Status: ${res.statusCode}');
        // print('🟣 Other Body: ${res.body}');
      }

      if (res.statusCode != 200) {
        _error = 'HTTP ${res.statusCode}';
      } else {
        final body = json.decode(res.body);

        // body: { status: true, data: { list: [ ... ] } }
        final list = (body is Map &&
            body['data'] is Map &&
            body['data']['list'] is List)
            ? (body['data']['list'] as List)
            .whereType<Map<String, dynamic>>()
            : const <Map<String, dynamic>>[];

        _items
          ..clear()
          ..addAll(
            list
                .map(OtherItem.fromJson)
                .where((e) => e.img.isNotEmpty && e.name.isNotEmpty),
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
  final String api = 'http://172.16.16.241/dynamic_flutter/public/api/v1/dating-zone';

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
