import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/apiList_provider.dart';
import '../providers/banner_provider.dart';
import '../providers/recommended_provider.dart';

/// ===================== COLORS (Single brand color: #FF34D3) =====================
const kPink       = Color(0xFFFF34D3);
const kPinkDeep   = kPink; // এক রংই use করছি যাতে সবখানে same থাকে
const kPinkLight  = kPink;
const announcement  = Color(0xFFF5D3F5);

const kCard       = Colors.white;      // card b5
const kDivider    = Color(0xFFEFEFEF); // light divider
const kTextMain   = Color(0xFF222222); // main text
const kTextSub    = Color(0xFF8E8E93); // sub text
const kBg         = Color(0xFFF8F8F8); // page bg

/// ===================== HOME =====================
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tab = 0;

  final tabs = const ['热门', '视频', '直播', '游戏'];

  final mockRecommended = List.generate(
    8,
        (i) => _RecommendItem(
      icon: 'https://picsum.photos/seed/r$i/200',
      title: '热门应用 $i',
      sub: '私密可靠 · 真实有效',
    ),
  );

  final mockDating = List.generate(
    8,
        (i) => _DatingItem(
      name: ['小月', '安安', '可可', '思思', '沫沫', '小雪', '琪琪', '甜甜'][i % 8],
      photo: 'https://picsum.photos/seed/d$i/800/1000',
      badge: '${40 + i * 8}人约过',
    ),
  );

  final mockLive = List.generate(
    8,
        (i) => _LiveItem(
      photo: 'https://picsum.photos/seed/l$i/800/1000',
      tag: i.isEven ? '热门' : '新人',
      online: '${1500 + i * 320}人在线',
    ),
  );

  bool _fetched = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_fetched) {
      context.read<BannerProvider>().fetch();
      context.read<AnnouncementsProvider>().fetch(force: true);
      ChangeNotifierProvider<OtherProvider>(create: (_) => OtherProvider());
      ChangeNotifierProvider<DatingZoneProvider>(create: (_) => DatingZoneProvider());

    _fetched = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              /// 顶部 Banner（API → Provider）
              const _ApiHeroCarousel(),
              const SizedBox(height: 10),

              /// 顶部提示文案（自动左向跑马灯）
              /// c
              Padding(
                padding: const EdgeInsets.only(left: 8,right: 8),
                child: Container(
                  height: 25,
                  color: announcement,
                  child: Consumer<AnnouncementsProvider>(
                    builder: (context, p, _) {
                      if (p.loading) {
                        return const SizedBox(
                          height: 26,
                          child: Center(
                            child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                          ),
                        );
                      }
                      if (p.error != null || p.texts.isEmpty) {
                        // সাইলেন্ট ফ্যালব্যাক (লেআউট উচ্চতা একই রাখা)
                        return const SizedBox(height: 26);
                      }
                      return _AutoMarqueeList(
                        texts: p.texts, // ✅ API থেকে আসা announcments
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        height: 26,
                        speedPxPerSec: 50,
                        gap: 40,
                        style: const TextStyle(color: Colors.black, fontSize: 12),
                      );
                    },
                  ),
                ),
              ),



              const SizedBox(height: 12),
              const _SectionTitle(cn: '官方推荐', en: 'RECOMMENDED'),
              const SizedBox(height: 12),

              /// 小图标网格（图 + 下载按钮） — ডেমো
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: AppMiniGridFromApi(), // ✅ API থেকে ডেটা দেখাবে
              ),

              const SizedBox(height: 16),

              /// 官方推荐 — লিস্ট
              const _SectionTitle(cn: '官方推荐', en: 'other'),
              const SizedBox(height: 6),
              const OtherSectionFromApi(),

              const SizedBox(height: 12),

              /// 同城约会
              const _SectionTitle(cn: '同城约会', en: 'DATING ZONE'),
              const SizedBox(height: 10),
              const DatingZoneSectionFromApi(),
              // // _TwoColGrid(
              // //   padding: const EdgeInsets.symmetric(horizontal: 10),
              // //   spacing: 12,
              // //   children: mockDating.map((e) => _DatingCard(item: e)).toList(),
              // // ),
              //
              // const SizedBox(height: 12),
              //
              // /// 直播专区
              // const _SectionTitle(cn: '直播专区', en: 'LIVE ZONE'),
              // const SizedBox(height: 10),
              // const DatingZoneSectionFromApi(),
            ],
          ),
        ),
      ),
    );
  }
}

/// ===================== Banner (API slider) =====================
class _ApiHeroCarousel extends StatefulWidget {
  const _ApiHeroCarousel({super.key});
  @override
  State<_ApiHeroCarousel> createState() => _ApiHeroCarouselState();
}

class _ApiHeroCarouselState extends State<_ApiHeroCarousel> {
  late final PageController _controller;
  int index = 0;
  Timer? _timer;

  static const _autoInterval = Duration(seconds: 4);
  static const _anim = Duration(milliseconds: 420);

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _startAuto();
  }

  void _startAuto() {
    _timer?.cancel();
    _timer = Timer.periodic(_autoInterval, (_) {
      if (!mounted) return;
      final len = context.read<BannerProvider>().items.length; // ✅ correct
      if (len == 0) return;
      final next = (index + 1) % len;
      _controller.animateToPage(next, duration: _anim, curve: Curves.easeOut);
    });
  }

  void _stopAuto() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopAuto();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BannerProvider>(
      builder: (context, p, _) {
        if (p.loading) {
          return const SizedBox(
            height: 180,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (p.error != null) {
          return SizedBox(
            height: 180,
            child: Center(
              child: Text('Banner error: ${p.error}', style: const TextStyle(color: Colors.redAccent)),
            ),
          );
        }
        if (p.items.isEmpty) {
          return const SizedBox(height: 8);
        }
        return Column(
          children: [
            Listener(
              onPointerDown: (_) => _stopAuto(),
              onPointerUp: (_) => _startAuto(),
              child: SizedBox(
                height: 180,
                child: PageView.builder(
                  controller: _controller,
                  itemCount: p.items.length,
                  onPageChanged: (i) => setState(() => index = i),
                  itemBuilder: (_, i) => _BannerSlide(item: p.items[i]),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(p.items.length, (i) {
                final active = i == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 6,
                  width: active ? 18 : 6,
                  decoration: BoxDecoration(
                    color: active ? kPink : const Color(0xFFE9E9EF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                );
              }),
            )
          ],
        );
      },
    );
  }
}

class _BannerSlide extends StatelessWidget {
  final BannerItem item;
  const _BannerSlide({required this.item});

  @override
  Widget build(BuildContext context) {
    // ডিজাইন একই: ইমেজ + হালকা veil + টেক্সট চাইলে নিচে
    print(item.image);
    print('dfldlfldfll11223211');
    print(item.name);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: item.image,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: const Color(0xFFF2F2F7)),
              errorWidget: (_, __, ___) => Image.network(
                'https://picsum.photos/seed/fallback/1200/500',
                fit: BoxFit.cover,
              ),
            ),
            // warm pink veil (brand color)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [kPink.withOpacity(0.2), kPink.withOpacity(0.12)],
                ),
              ),
            ),
            if (item.name.isNotEmpty)
              Positioned(
                left: 14, bottom: 14, right: 14,
                child: Text(
                  item.name,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
/// ===================== App mini grid (demo icons) =====================
class AppMiniGridFromApi extends StatefulWidget {
  const AppMiniGridFromApi({super.key});

  @override
  State<AppMiniGridFromApi> createState() => _AppMiniGridFromApiState();
}

class _AppMiniGridFromApiState extends State<AppMiniGridFromApi> {
  bool _fetched = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_fetched) {
      context.read<RecommendedProvider>().fetch();
      _fetched = true;
    }
  }

  Future<void> _open(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RecommendedProvider>(
      builder: (_, p, __) {
        if (p.loading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        if (p.error != null) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text('加载失败: ${p.error}', style: const TextStyle(color: Colors.red)),
          );
        }
        if (p.items.isEmpty) return const SizedBox.shrink();

        return GridView.builder(
          itemCount: p.items.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 14,
            crossAxisSpacing: 12,
            mainAxisExtent: 100,
          ),
          itemBuilder: (_, i) {
            final it = p.items[i];
            // 下载 বোতামে অ্যান্ড্রয়েড/ওয়েব যেটা আছে সেটা ওপেন করাই
            final target = it.androidUrl.isNotEmpty ? it.androidUrl : it.webUrl;
            return _MiniTile(
              icon: it.img,
              title: it.name,
              onTap: () => _open(target),
            );
          },
        );
      },
    );
  }
}


class _MiniTile extends StatelessWidget {
  final String icon;
  final String title;           // ✅ name দেখাতে
  final VoidCallback? onTap;    // ✅ 下载 বোতামে অ্যাকশন

  const _MiniTile({
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: icon,
              fit: BoxFit.cover,
              placeholder: (_, __) => const Center(
                child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              errorWidget: (_, __, ___) => const Icon(Icons.broken_image_outlined),
            ),
          ),
        ),
        const SizedBox(height: 6),
        // (ঐচ্ছিক) নাম দেখাতে চাইলে এই লাইন অন করুন
        // Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),

        Container(
          height: 24, width: 64, alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: kPink, width: 1.2),
          ),
          child: InkWell(
            onTap: onTap,
            child: const Center(
              child: Text('下载', style: TextStyle(color: kPink, fontWeight: FontWeight.w700, fontSize: 12)),
            ),
          ),
        ),
      ],
    );
  }
}

/// ===================== Section title =====================
class _SectionTitle extends StatelessWidget {
  final String cn, en;
  const _SectionTitle({required this.cn, required this.en});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        border: Border.all(color: kDivider),
      ),
      child: Row(
        children: [
          Container(width: 6, height: 16, decoration: BoxDecoration(color: kPink, borderRadius: BorderRadius.circular(4))),
          const SizedBox(width: 8),
          Text(cn, style: const TextStyle(color: kTextMain, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(width: 8),
          Text(en, style: const TextStyle(color: kTextSub, fontSize: 12, fontWeight: FontWeight.w600)),
          const Spacer(),
          Container(width: 64, height: 6, decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(20))),
        ],
      ),
    );
  }
}

/// ===================== Recommended row (demo) =====================
///

class OtherSectionFromApi extends StatefulWidget {
  const OtherSectionFromApi({super.key});

  @override
  State<OtherSectionFromApi> createState() => _OtherSectionFromApiState();
}

class _OtherSectionFromApiState extends State<OtherSectionFromApi> {
  bool _fetched = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_fetched) {
      context.read<OtherProvider>().fetch();
      _fetched = true;
    }
  }

  Future<void> _open(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OtherProvider>(
      builder: (_, p, __) {
        if (p.loading && p.items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        if (p.error != null) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text('加载失败: ${p.error}', style: const TextStyle(color: Colors.red)),
          );
        }
        if (p.items.isEmpty) return const SizedBox.shrink();

        // _RecommendedTile যে _RecommendItem নেয়—আমরা API item → adapter বানিয়ে পাঠাচ্ছি
        return Column(
          children: [
            for (final it in p.items)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: GestureDetector(
                  onTap: () => _open(it.androidUrl.isNotEmpty ? it.androidUrl : it.webUrl),
                  child: _RecommendedTile(
                    item: _RecommendItem(
                      icon: it.img,
                      title: it.name,
                      sub: (it.slogan.isEmpty ? '私密可靠 · 真实有效' : it.slogan),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _RecommendedTile extends StatelessWidget {
  final _RecommendItem item;
  const _RecommendedTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: kDivider)),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(imageUrl: item.icon, width: 56, height: 56, fit: BoxFit.cover),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: kTextMain, fontSize: 15, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(item.sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: kTextSub, fontSize: 12)),
            ]),
          ),
          Container(
            height: 26, width: 72, alignment: Alignment.center,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: kPink, width: 1.2)),
            child: const Text('下载', style: TextStyle(color: kPink, fontWeight: FontWeight.w700, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

/// ===================== Two-col grid helper =====================
class _TwoColGrid extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets padding;
  final double spacing;
  const _TwoColGrid({required this.children, this.padding = EdgeInsets.zero, this.spacing = 10});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: LayoutBuilder(builder: (context, c) {
        final w = (c.maxWidth - spacing) / 2;
        return Wrap(spacing: spacing, runSpacing: spacing,
          children: children.map((e) => SizedBox(width: w, child: e)).toList(),
        );
      }),
    );
  }
}

/// ===================== Cards (demo) =====================
class _DatingItem { final String name, photo, badge; const _DatingItem({required this.name, required this.photo, required this.badge}); }
class _LiveItem   { final String photo, tag, online; const _LiveItem({required this.photo, required this.tag, required this.online}); }
class _RecommendItem { final String icon, title, sub; const _RecommendItem({required this.icon, required this.title, required this.sub}); }

// class _DatingItem {
//   final String name, photo, badge;
//   const _DatingItem({required this.name, required this.photo, required this.badge});
// }

// তোমার আগের কার্ড — অপরিবর্তিত থাকবে
// class _DatingCard extends StatelessWidget { ... }

// তোমার আগের গ্রিড হেল্পার — অপরিবর্তিত
// class _TwoColGrid extends StatelessWidget { ... }

class DatingZoneSectionFromApi extends StatefulWidget {
  const DatingZoneSectionFromApi({super.key});

  @override
  State<DatingZoneSectionFromApi> createState() => _DatingZoneSectionFromApiState();
}

class _DatingZoneSectionFromApiState extends State<DatingZoneSectionFromApi> {
  bool _fetched = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_fetched) {
      context.read<DatingZoneProvider>().fetch();
      _fetched = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DatingZoneProvider>(
      builder: (_, p, __) {
        // গ্লোবাল লোডার ব্যবহার করলে এখানে লোডার না দেখালেও হবে
        if (p.error != null) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text('加载失败: ${p.error}', style: const TextStyle(color: Colors.red)),
          );
        }
        if (p.items.isEmpty) return const SizedBox.shrink();

        // API item → _DatingItem অ্যাডাপ্টার
        final items = <_DatingItem>[];
        for (int i = 0; i < p.items.length; i++) {
          final it = p.items[i];
          // badge fallback: slogan থাকলে ওটা, না থাকলে কিছু জেনারেটেড/ডিফল্ট
          final badge = (it.slogan.isNotEmpty) ? it.slogan : '${120 + i * 7}人约过';
          items.add(_DatingItem(name: it.name, photo: it.img, badge: badge));
        }

        return _TwoColGrid(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          spacing: 12,
          children: items.map((e) => _DatingCard(item: e)).toList(),
        );
      },
    );
  }
}


class _DatingCard extends StatelessWidget {
  final _DatingItem item; const _DatingCard({required this.item});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(borderRadius: BorderRadius.circular(14), child: Stack(children: [
      AspectRatio(aspectRatio: 3/4, child: CachedNetworkImage(imageUrl: item.photo, fit: BoxFit.cover)),
      Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.center, colors: [Colors.black.withOpacity(.55), Colors.transparent]),
      ))),
      Positioned(left: 10, bottom: 10, child: Row(children: [
        Text(item.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
        const SizedBox(width: 6),
        Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: kPinkDeep, borderRadius: BorderRadius.circular(6)),
          child: Text(item.badge, style: const TextStyle(color: Colors.white, fontSize: 10)),
        )
      ])),
    ]));
  }
}

//

/// ===================== Auto Marquee =====================
class _AutoMarqueeList extends StatefulWidget {
  final List<String> texts;
  final EdgeInsets padding;
  final double height;
  final double speedPxPerSec;
  final double gap;
  final TextStyle? style;
  const _AutoMarqueeList({
    required this.texts,
    this.padding = EdgeInsets.zero,
    this.height = 26,
    this.speedPxPerSec = 40,
    this.gap = 32,
    this.style,
  });
  @override
  State<_AutoMarqueeList> createState() => _AutoMarqueeListState();
}

class _AutoMarqueeListState extends State<_AutoMarqueeList> {
  final _ctrl = ScrollController();
  Timer? _timer;
  bool _paused = false;

  @override
  void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) => _start()); }

  void _start() {
    _timer?.cancel();
    final step = widget.speedPxPerSec / 60.0;
    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (_paused || !_ctrl.hasClients) return;
      final max = _ctrl.position.maxScrollExtent;
      if (max <= 0) return;
      final next = _ctrl.offset + step;
      if (next >= max) { _ctrl.jumpTo(0); } else { _ctrl.jumpTo(next); }
    });
  }

  @override
  void dispose() { _timer?.cancel(); _ctrl.dispose(); super.dispose(); }

  List<Widget> _buildItems() {
    final style = widget.style ?? const TextStyle(fontSize: 12, color: Colors.black87);
    final List<Widget> row = [];
    for (final t in widget.texts) { row.add(Text(t, style: style)); row.add(SizedBox(width: widget.gap)); }
    return row;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _paused = true,
      onPointerUp:   (_) => _paused = false,
      child: Padding(
        padding: widget.padding,
        child: SizedBox(
          height: widget.height,
          child: Stack(
            children: [
              ListView(
                controller: _ctrl,
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Row(children: _buildItems()),
                  Row(children: _buildItems()),
                ],
              ),
              IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    // gradient: LinearGradient(
                    //   begin: Alignment.centerLeft, end: Alignment.centerRight,
                    //   colors: [ Colors.white, Colors.white.withOpacity(0), Colors.white.withOpacity(0), Colors.white ],
                    //   stops: const [0.0, .12, .88, 1.0],
                    // ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
