import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// API response:
/// {
///   "status": true,
///   "data": {
///     "name": "Banner Section",
///     "list": [ { name, img, slogan, androidurl, url, is_apk, is_browser, iosurl }, ... ]
///   }
/// }

class BannerItem {
  final String name;        // API: name
  final String image;       // API: img (absolute/relative)
  final String slogan;      // API: slogan
  final String androidUrl;  // API: androidurl
  final String webUrl;      // API: url
  final bool isApk;         // '1' => true
  final bool isBrowser;     // '1' => true

  BannerItem({
    required this.name,
    required this.image,
    required this.slogan,
    required this.androidUrl,
    required this.webUrl,
    required this.isApk,
    required this.isBrowser,
  });

  factory BannerItem.fromJson(Map<String, dynamic> j, {String base = '', String pathPrefix = ''}) {
    String _abs(String v) {
      if (v.isEmpty) return v;
      if (v.startsWith('http')) return v;
      // যদি শুধু টোকেন টাইপ (যেমন "image_one") আসে, prefix যোগ করুন
      final withPrefix = pathPrefix.isNotEmpty ? '$pathPrefix$v' : v;
      if (base.isEmpty) return withPrefix;
      final sep = base.endsWith('/') || withPrefix.startsWith('/') ? '' : '/';
      return '$base$sep$withPrefix';
    }

    return BannerItem(
      name: (j['name'] ?? '').toString(),
      image: _abs((j['img'] ?? '').toString()),
      slogan: (j['slogan'] ?? '').toString(),
      androidUrl: _abs((j['androidurl'] ?? '').toString()),
      webUrl: _abs((j['url'] ?? '').toString()),
      isApk: (j['is_apk'] ?? '').toString() == '1',
      isBrowser: (j['is_browser'] ?? '').toString() == '1',
    );
  }
}

class BannerProvider extends ChangeNotifier {
  /// ✅ আপনার API
  final String api = 'http://172.16.16.253/dynamic_flutter/public/api/v1/top-banner';

  /// যদি img/url রিলেটিভ আসে, এখানে বেস ও প্রিফিক্স দিন (প্রয়োজনে বদলান):
  final String baseForMedia = 'http://172.16.16.253';     // e.g. server origin
  final String pathPrefix   = '/dynamic_flutter/public/';  // e.g. 'uploads/banners/' বা খালি ''

  final List<BannerItem> _items = [];
  bool _loading = false;
  String? _error;

  List<BannerItem> get items => List.unmodifiable(_items);
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetch() async {
    if (_loading) return;
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
            (body['data']['list'] is List))
            ? (body['data']['list'] as List)
            : const <dynamic>[];

        _items
          ..clear()
          ..addAll(
            list
                .whereType<Map<String, dynamic>>()
                .map((e) => BannerItem.fromJson(e, base: baseForMedia, pathPrefix: pathPrefix))
                .where((e) => e.image.isNotEmpty),
          );

        if (_items.isEmpty) _error = 'Empty banner list';
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


/// GET http://172.16.16.253/dynamic_flutter/public/api/v1/announcements
/// {
///   "status": true,
///   "data": {
///     "name": "Website Announcement",
///     "list": [ "text1", "text2", ... ]
///   }
/// }

class AnnouncementsProvider extends ChangeNotifier {
  final String api =
      'http://172.16.16.253/dynamic_flutter/public/api/v1/announcements';

  final List<String> _texts = [];
  bool _loading = false;
  String? _error;

  List<String> get texts => List.unmodifiable(_texts);
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetch({bool force = false}) async {
    if (_loading) return;
    if (_texts.isNotEmpty && !force) return;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await http
          .get(Uri.parse(api))
          .timeout(const Duration(seconds: 12));

      if (res.statusCode != 200) {
        _error = 'HTTP ${res.statusCode}';
      } else {
        final body = json.decode(res.body);
        final list = (body is Map &&
            body['data'] is Map &&
            body['data']['list'] is List)
            ? (body['data']['list'] as List)
            : const <dynamic>[];

        _texts
          ..clear()
          ..addAll(list
              .map((e) => (e ?? '').toString().trim())
              .where((s) => s.isNotEmpty));

        if (_texts.isEmpty) _error = 'Empty announcements';
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