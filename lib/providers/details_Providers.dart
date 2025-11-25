// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
//
// /// API base: http://172.16.16.241/dynamic_flutter/public/api/v1/details/{type}/{index}
// const String kDetailsBase =
//     'http://172.16.16.241/dynamic_flutter/public/api/v1/details';
//
// class DetailsData {
//   final String name;
//   final String cover;         // "img"
//   final List<String> pics;    // "pics" (list)
//   final String content;       // "content"
//   final String androidUrl;    // "androidurl"
//   final String webUrl;        // "url"
//   final bool isApk;           // is_apk == '1'
//   final bool isBrowser;       // is_browser == '1'
//
//   DetailsData({
//     required this.name,
//     required this.cover,
//     required this.pics,
//     required this.content,
//     required this.androidUrl,
//     required this.webUrl,
//     required this.isApk,
//     required this.isBrowser,
//   });
//
//   factory DetailsData.fromJson(Map<String, dynamic> j) {
//     List<String> _pics = [];
//     final raw = j['pics'];
//     if (raw is List) {
//       _pics = raw.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList();
//     }
//     return DetailsData(
//       name: (j['name'] ?? '').toString(),
//       cover: (j['img'] ?? '').toString(),
//       pics: _pics,
//       content: (j['content'] ?? '').toString(),
//       androidUrl: (j['androidurl'] ?? '').toString(),
//       webUrl: (j['url'] ?? '').toString(),
//       isApk: (j['is_apk'] ?? '').toString() == '1',
//       isBrowser: (j['is_browser'] ?? '').toString() == '1',
//     );
//   }
// }
//
// class DetailsProvider extends ChangeNotifier {
//   /// Simple in-memory cache so we don’t refetch same item repeatedly.
//   final Map<String, DetailsData> _cache = {};
//
//   Future<DetailsData> fetch(String type, int index) async {
//     final key = '$type/$index';
//     if (_cache.containsKey(key)) return _cache[key]!;
//
//     final uri = Uri.parse('$kDetailsBase/$type/$index');
//     final res = await http.get(uri).timeout(const Duration(seconds: 12));
//
//     if (res.statusCode != 200) {
//       throw Exception('HTTP ${res.statusCode}');
//     }
//     final body = json.decode(res.body);
//     if (body is! Map || body['data'] is! Map) {
//       throw Exception('Invalid response shape');
//     }
//     final data = DetailsData.fromJson((body['data'] as Map).cast<String, dynamic>());
//     _cache[key] = data;
//     return data;
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// নতুন POST API:
/// http://172.16.16.241/video_store/public/api/v1/product-details
const String kProductDetailsApi =
    'http://172.16.16.241/video_store/public/api/v1/product-details';

class DetailsData {
  final String name;
  final String cover;         // API: "img"
  final List<String> pics;    // ভবিষ্যতে থাকলে use করবো, না থাকলে []
  final String content;       // API: "content"
  final String androidUrl;    // API: "android_url"
  final String webUrl;        // API: "product_link"
  final bool isApk;           // is_apk == '1'
  final bool isBrowser;       // is_browser == '1'

  DetailsData({
    required this.name,
    required this.cover,
    required this.pics,
    required this.content,
    required this.androidUrl,
    required this.webUrl,
    required this.isApk,
    required this.isBrowser,
  });

  factory DetailsData.fromJson(Map<String, dynamic> j) {
    // যদি future এ "pics" list দাও, এখানে map করবে
    List<String> _pics = [];
    final raw = j['pics'];
    if (raw is List) {
      _pics = raw
          .map((e) => e?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return DetailsData(
      name: (j['name'] ?? '').toString(),
      cover: (j['img'] ?? '').toString(),
      pics: _pics,
      content: (j['content'] ?? '').toString(),
      androidUrl: (j['android_url'] ?? '').toString(),
      webUrl: (j['product_link'] ?? '').toString(),
      // তোমার এই API রেসপন্সে is_apk / is_browser নেই, তাই default false হবে
      isApk: (j['is_apk'] ?? '').toString() == '1',
      isBrowser: (j['is_browser'] ?? '').toString() == '1',
    );
  }
}

class DetailsProvider extends ChangeNotifier {
  /// id ভিত্তিক simple cache
  final Map<int, DetailsData> _cache = {};

  /// মূল ফাংশন: শুধুমাত্র id দিয়ে detail আনবে
  Future<DetailsData> fetchById(int id) async {
    if (_cache.containsKey(id)) {
      if (kDebugMode) print('🔁 Details cache hit for id=$id');
      return _cache[id]!;
    }

    if (kDebugMode) print('🌐 Fetching details for id=$id');

    final uri = Uri.parse(kProductDetailsApi);
    final res = await http
        .post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}), // 👈 body: { "id": 4 }
    )
        .timeout(const Duration(seconds: 12));

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}');
    }

    final body = json.decode(res.body);

    // ✅ এখানে আমরা data.list থেকে আসল object নিচ্ছি
    if (body is! Map || body['data'] is! Map) {
      throw Exception('Invalid response shape (no data)');
    }
    final dataWrapper = body['data'] as Map;
    if (dataWrapper['list'] is! Map) {
      throw Exception('Invalid response shape (no data.list)');
    }

    final raw = (dataWrapper['list'] as Map).cast<String, dynamic>();

    final data = DetailsData.fromJson(raw);

    _cache[id] = data;
    return data;
  }

  /// পুরনো signature থাকলে (type/index) – চাইলে ব্যবহারই না করো
  Future<DetailsData> fetch(String type, int index) {
    return fetchById(index);
  }
}
