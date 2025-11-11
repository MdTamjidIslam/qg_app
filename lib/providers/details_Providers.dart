import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// API base: http://172.16.16.253/dynamic_flutter/public/api/v1/details/{type}/{index}
const String kDetailsBase =
    'http://172.16.16.253/dynamic_flutter/public/api/v1/details';

class DetailsData {
  final String name;
  final String cover;         // "img"
  final List<String> pics;    // "pics" (list)
  final String content;       // "content"
  final String androidUrl;    // "androidurl"
  final String webUrl;        // "url"
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
    List<String> _pics = [];
    final raw = j['pics'];
    if (raw is List) {
      _pics = raw.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList();
    }
    return DetailsData(
      name: (j['name'] ?? '').toString(),
      cover: (j['img'] ?? '').toString(),
      pics: _pics,
      content: (j['content'] ?? '').toString(),
      androidUrl: (j['androidurl'] ?? '').toString(),
      webUrl: (j['url'] ?? '').toString(),
      isApk: (j['is_apk'] ?? '').toString() == '1',
      isBrowser: (j['is_browser'] ?? '').toString() == '1',
    );
  }
}

class DetailsProvider extends ChangeNotifier {
  /// Simple in-memory cache so we don’t refetch same item repeatedly.
  final Map<String, DetailsData> _cache = {};

  Future<DetailsData> fetch(String type, int index) async {
    final key = '$type/$index';
    if (_cache.containsKey(key)) return _cache[key]!;

    final uri = Uri.parse('$kDetailsBase/$type/$index');
    final res = await http.get(uri).timeout(const Duration(seconds: 12));

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}');
    }
    final body = json.decode(res.body);
    if (body is! Map || body['data'] is! Map) {
      throw Exception('Invalid response shape');
    }
    final data = DetailsData.fromJson((body['data'] as Map).cast<String, dynamic>());
    _cache[key] = data;
    return data;
  }
}
