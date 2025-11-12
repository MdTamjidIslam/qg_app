// dating_zone_details_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// === Your provider (keep path the same as your project)
import '../providers/details_Providers.dart';

/// Brand color
const kPink = Color(0xFFFF34D3);

/// If you have an OpenInstall short link, put it here; otherwise we’ll open target URL directly.
const String kOpenInstallShortLink = '';

/* -------------------------------- Helpers ------------------------------- */

bool _isLikelyValidUrl(String s) {
  if (s.isEmpty) return false;
  final t = s.trim().toLowerCase();
  if (t == 'http://' || t == 'https://') return false;
  Uri? u;
  try {
    u = Uri.parse(s);
  } catch (_) {
    return false;
  }
  return (u.scheme == 'http' || u.scheme == 'https') && u.host.isNotEmpty;
}

String _pickTarget(String androidUrl, String webUrl) {
  if (_isLikelyValidUrl(androidUrl)) return androidUrl;
  if (_isLikelyValidUrl(webUrl)) return webUrl;
  return '';
}

/// Open the OpenInstall H5 (if provided) and pass `target` as a query param.
/// If no short link is configured, open the target directly.
Future<void> _openOpenInstallWithTarget(String target) async {
  Uri? uri;
  if (kOpenInstallShortLink.isNotEmpty) {
    final base = Uri.parse(kOpenInstallShortLink);
    final qp = Map<String, String>.from(base.queryParameters);
    if (target.isNotEmpty) qp['target'] = target;
    uri = base.replace(queryParameters: qp);
  } else if (target.isNotEmpty) {
    uri = Uri.parse(target);
  }
  if (uri == null) return;
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok) {
    await launchUrl(uri, mode: LaunchMode.platformDefault);
  }
}

/* ---------------------------- Main Detail Page --------------------------- */

class DatingZoneDetailsPage extends StatefulWidget {
  /// Which item to load from API: /details/{type}/{index}
  final int index;
  /// API type path segment (e.g. 'dating-zone', 'recommended', 'type', etc.)
  final String type;
  /// Bottom CTA text
  final String ctaText;
  /// Initial image index in the pager
  final int initialImageIndex;

  const DatingZoneDetailsPage({
    super.key,
    required this.index,
    this.type = 'dating-zone',
    this.ctaText = ' 点击下载 进入色情专区',
    this.initialImageIndex = 0,
  });

  @override
  State<DatingZoneDetailsPage> createState() => _DatingZoneDetailsPageState();
}

class _DatingZoneDetailsPageState extends State<DatingZoneDetailsPage> {
  late final DetailsProvider _provider;
  late Future<DetailsData> _future;
  late final PageController _pc;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _provider = DetailsProvider();
    _future = _provider.fetch(widget.type, widget.index);
    _pc = PageController(initialPage: widget.initialImageIndex);
    _current = widget.initialImageIndex;
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DetailsData>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const _FullScreenLoader();
        }
        if (snap.hasError) {
          return _FullScreenError(
            message: '加载失败：${snap.error}',
            onRetry: () => setState(() {
              _future = _provider.fetch(widget.type, widget.index);
            }),
          );
        }

        final d = snap.data!;

        // Build image list: prefer pics; fallback to cover; final fallback to placeholder.
        final List<String> images = () {
          final list = <String>[];
          if (d.pics.isNotEmpty) list.addAll(d.pics);
          if (list.isEmpty && d.cover.isNotEmpty) list.add(d.cover);
          if (list.isEmpty) list.add('https://picsum.photos/seed/fallback/900/1200');
          // de-dup
          final seen = <String>{};
          return list.where((e) => seen.add(e)).toList();
        }();

        final title = (d.name.isEmpty ? '应用详情' : d.name);
        final description = d.content;
        final target = _pickTarget(d.androidUrl, d.webUrl);

        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _AutoHeroImages(
                      controller: _pc,
                      images: images,
                      onChanged: (i) => setState(() => _current = i),
                    ),
                  ),
                  SliverToBoxAdapter(child: _TitleBlock(title: title)),
                  const SliverToBoxAdapter(
                    child: Divider(height: 1, color: Color(0xFFEDEDED)),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '介绍：',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF444444),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Back button overlay
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, top: 8),
                  child: _CircleIconButton(
                    icon: Icons.arrow_back_ios_new,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
              ),

              // Bottom CTA
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    color: Colors.white,
                    child: GestureDetector(
                      onTap: () => _openOpenInstallWithTarget(target),
                      child: Container(
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: kPink,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: const [
                            BoxShadow(color: Color(0x33FF34D3), blurRadius: 14, offset: Offset(0, 6)),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.download, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                ' 点击下载 进入色情专区',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
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
          ),
        );
      },
    );
  }
}

/* -------------------------- Auto hero slider widget -------------------------- */

class _AutoHeroImages extends StatefulWidget {
  final PageController controller;
  final List<String> images;
  final ValueChanged<int> onChanged;
  final Duration autoInterval;
  final Duration anim;

  const _AutoHeroImages({
    required this.controller,
    required this.images,
    required this.onChanged,
    this.autoInterval = const Duration(seconds: 2),
    this.anim = const Duration(milliseconds: 250),
  });

  @override
  State<_AutoHeroImages> createState() => _AutoHeroImagesState();
}

class _AutoHeroImagesState extends State<_AutoHeroImages> {
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _startAuto();
  }

  @override
  void didUpdateWidget(covariant _AutoHeroImages oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.images.length != widget.images.length) {
      _stopAuto();
      _startAuto();
    }
  }

  void _startAuto() {
    if (widget.images.length <= 1) return;
    _timer?.cancel();
    _timer = Timer.periodic(widget.autoInterval, (_) {
      if (!mounted || !widget.controller.hasClients) return;
      _index = (_index + 1) % widget.images.length;
      widget.controller.animateToPage(_index, duration: widget.anim, curve: Curves.easeOut);
    });
  }

  void _stopAuto() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopAuto();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Listener(
          onPointerDown: (_) => _stopAuto(), // pause while touching
          onPointerUp: (_) => _startAuto(),   // resume after release
          child: AspectRatio(
            aspectRatio: 9 / 12,
            child: PageView.builder(
              controller: widget.controller,
              itemCount: widget.images.length,
              onPageChanged: (i) {
                _index = i;
                widget.onChanged(i);
              },
              itemBuilder: (_, i) => _NetImage(url: widget.images[i]),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 14,
          child: Center(
            child: AnimatedBuilder(
              animation: widget.controller,
              builder: (context, _) {
                int current = 0;
                if (widget.controller.hasClients && widget.controller.page != null) {
                  current = widget.controller.page!.round();
                }
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(widget.images.length, (i) {
                    final active = i == current;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: active ? kPink : const Color(0xFFDADADA),
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

/* --------------------------------- UI bits -------------------------------- */

class _NetImage extends StatelessWidget {
  final String url;
  const _NetImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: const Color(0xFFF2F2F2),
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image_outlined, size: 40, color: Color(0xFFBDBDBD)),
      ),
    );
  }
}

class _TitleBlock extends StatelessWidget {
  final String title;
  const _TitleBlock({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _CircleIconButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(.35),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

class _FullScreenLoader extends StatelessWidget {
  const _FullScreenLoader();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: const [
          Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}

class _FullScreenError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _FullScreenError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: onRetry, child: const Text('重试')),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
