import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/details_Providers.dart'; // <-- উপরের ফাইল

const kPink = Color(0xFFFF34D3); // fallback primary

/// এখানে তোমার OpenInstall short link বসাও; ফাঁকা রাখতে পারো।
const String kOpenInstallShortLink = '';

class DetailsPage extends StatefulWidget {
  final int id;        // 👈 শুধু id লাগবে এখন

  /// বাটনের টেক্সট কাস্টমাইজ করতে চাইলে
  final String ctaText;
  final VoidCallback? onTapCta;

  const DetailsPage({
    super.key,
    required this.id,
    this.ctaText = '下载',
    this.onTapCta,
  });

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late final DetailsProvider _provider;
  late Future<DetailsData> _future;

  @override
  void initState() {
    super.initState();
    _provider = DetailsProvider();
    _future = _provider.fetchById(widget.id); // 👈 এখানে id দিয়ে call
  }

  // ---------- URL helpers ----------
  Future<void> _openExternalUri(Uri uri) async {
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      // ignore
    }
  }

  Future<void> _openTargetUrl(String target) async {
    if (target.isEmpty) return;

    // যদি OpenInstall short link সেট করা থাকে, target কে query হিসেবে পাঠাই
    if (kOpenInstallShortLink.isNotEmpty) {
      final oi = Uri.parse(kOpenInstallShortLink);
      final uri = oi.replace(queryParameters: {
        ...oi.queryParameters,
        'target': target, // server-side এ decode করে নাও
      });
      await _openExternalUri(uri);
      return;
    }

    // নাহলে সরাসরি target ওপেন
    final uri = Uri.parse(target);
    await _openExternalUri(uri);
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title:
        const Text('应用详情', style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<DetailsData>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '加载失败：${snap.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            );
          }

          final d = snap.data!;
          final target = d.androidUrl.isNotEmpty ? d.androidUrl : d.webUrl;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 顶部卡片（logo/标题/副文）
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SquareThumb(url: d.cover, size: 64),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                d.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '首页推荐 · 官网',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.textTheme.bodySmall?.color
                                      ?.withOpacity(.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),
                    // 简介文字（跟示例一样换行）
                    Text(
                      d.content.trim().isEmpty ? '暂无简介' : d.content,
                      style: const TextStyle(fontSize: 14, height: 1.45),
                    ),

                    const SizedBox(height: 16),
                    // 大海报（封面）
                    if (d.cover.isNotEmpty) _Poster(url: d.cover),

                    const SizedBox(height: 12),
                    // 图集（横向）
                    if (d.pics.isNotEmpty) ...[
                      const Text(
                        '截图预览',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 220,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: d.pics.length,
                          separatorBuilder: (_, __) =>
                          const SizedBox(width: 10),
                          itemBuilder: (context, i) =>
                              _GalleryThumb(url: d.pics[i]),
                        ),
                      ),
                    ],

                    const SizedBox(height: 18),
                  ],
                ),
              ),

              // 底部下载按钮（তোমার দেওয়া ডিজাইন 그대로）
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    color: Colors.white,
                    child: GestureDetector(
                      onTap: widget.onTapCta ??
                              () => _openTargetUrl(target), // default আচরণ
                      child: Container(
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: kPink,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33FF34D3),
                              blurRadius: 14,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.download,
                                color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              widget.ctaText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ---------- small widgets ----------
class _SquareThumb extends StatelessWidget {
  final String url;
  final double size;
  const _SquareThumb({required this.url, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: size,
        height: size,
        color: const Color(0xFFEFEFEF),
        child: url.isEmpty
            ? const Icon(Icons.apps, size: 28, color: Colors.grey)
            : Image.network(url, fit: BoxFit.cover),
      ),
    );
  }
}

class _Poster extends StatelessWidget {
  final String url;
  const _Poster({required this.url});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(url, fit: BoxFit.cover),
      ),
    );
  }
}

class _GalleryThumb extends StatelessWidget {
  final String url;
  const _GalleryThumb({required this.url});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 9 / 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(url, fit: BoxFit.cover),
      ),
    );
  }
}
