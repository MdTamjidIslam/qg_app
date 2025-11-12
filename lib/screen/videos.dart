import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/apiList_provider.dart';
import '../providers/banner_provider.dart';
import '../providers/recommended_provider.dart';
import 'detail_fetch_page.dart';
import 'details_screen.dart';

/// ===================== COLORS (Single brand color: #FF34D3) =====================
const kPink = Color(0xFFFF34D3);
const kPinkDeep = kPink;
const kPinkLight = kPink;
const announcement = Color(0xFFF5D3F5);

const kCard = Colors.white;
const kDivider = Color(0xFFEFEFEF);
const kTextMain = Color(0xFF222222);
const kTextSub = Color(0xFF8E8E93);
const kBg = Color(0xFFF8F8F8);

/// ======= Simple Shimmer (no extra package) =======
class Shimmer extends StatefulWidget {
  final Widget child;
  const Shimmer({super.key, required this.child});
  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
  AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final gradient = LinearGradient(
          begin: Alignment(-1.0 + _c.value * 2, 0),
          end: Alignment(1.0 + _c.value * 2, 0),
          colors: const [Color(0xFFF2F2F7), Color(0xFFE9E9EF), Color(0xFFF2F2F7)],
          stops: const [0.25, 0.5, 0.75],
        );
        return ShaderMask(
          shaderCallback: (rect) => gradient.createShader(rect),
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

/// ======= Reusable skeleton boxes =======
class SkeletonBox extends StatelessWidget {
  final double h, w, r;
  const SkeletonBox({super.key, required this.h, required this.w, this.r = 8});
  @override
  Widget build(BuildContext context) =>
      Shimmer(child: Container(height: h, width: w, decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(r))));
}

class SkeletonLine extends StatelessWidget {
  final double w;
  const SkeletonLine({super.key, required this.w});
  @override
  Widget build(BuildContext context) => SkeletonBox(h: 12, w: w, r: 6);
}

/// ===================== HOME =====================
class VideosPage extends StatefulWidget {
  const VideosPage({super.key});
  @override
  State<VideosPage> createState() => _VideosPageState();
}

class _VideosPageState extends State<VideosPage> {
  bool _fetched = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_fetched) {
      // NOTE: Providers must be created above (e.g., in main.dart -> MultiProvider).
      context.read<BannerProvider>().fetch();
      context.read<AnnouncementsProvider>().fetch(force: true);
      context.read<RecommendedProvider>().fetch();
      context.read<OtherProvider>().fetch();
      context.read<DatingZoneProvider>().fetch();
      _fetched = true;
    }
  }

  bool _isFirstPageLoading(BuildContext context) {
    final b = context.watch<BannerProvider>();
    final a = context.watch<AnnouncementsProvider>();
    final r = context.watch<RecommendedProvider>();
    final o = context.watch<OtherProvider>();
    final d = context.watch<DatingZoneProvider>();

    final anyLoading = b.loading || a.loading || r.loading || o.loading || d.loading;
    final allEmpty = b.items.isEmpty && a.texts.isEmpty && r.items.isEmpty && o.items.isEmpty && d.items.isEmpty;
    return anyLoading && allEmpty; // only first entry
  }

  @override
  Widget build(BuildContext context) {
    final firstLoad = _isFirstPageLoading(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPink,
        toolbarHeight: 60,        // <-- height এখানে দিন (ডিফল্ট ~56)
        titleSpacing: 0,          // চাইলে টাইটেল গ্যাপ কমান/বাড়ান
        elevation: 0,
        centerTitle: true,
        title: Text('看片利器',style: TextStyle(color: Colors.white),),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: firstLoad
            ? const _SkeletonHome() // ✅ একবারই দেখাবে
            : SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SizedBox(height: 12),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: AppMiniGridFromApi(),
              ),
              SizedBox(height: 16),
              _SectionTitle(cn: '官方推荐', en: 'other'),
              SizedBox(height: 6),
              OtherSectionFromApi(),
              SizedBox(height: 12),
              _SectionTitle(cn: '同城约会', en: 'DATING ZONE'),
              SizedBox(height: 10),
              DatingZoneSectionFromApi(),
            ],
          ),
        ),
      ),
    );
  }
}

/// ===================== FIRST-LOAD SKELETON PAGE =====================
class _SkeletonHome extends StatelessWidget {
  const _SkeletonHome();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          const SizedBox(height: 8),
          // banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Shimmer(
              child: Container(height: 180, decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(12))),
            ),
          ),
          const SizedBox(height: 10),
          // announcement strip
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              height: 25,
              color: announcement,
              alignment: Alignment.centerLeft,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: SkeletonLine(w: 160),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const _SectionTitle(cn: '官方推荐', en: 'RECOMMENDED'),
          const SizedBox(height: 12),
          // grid skeleton (5 x 2)
          const Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: _GridSkeleton(count: 10)),
          const SizedBox(height: 16),
          const _SectionTitle(cn: '官方推荐', en: 'other'),
          const SizedBox(height: 8),
          const _ListSkeleton(count: 3),
          const SizedBox(height: 12),
          const _SectionTitle(cn: '同城约会', en: 'DATING ZONE'),
          const SizedBox(height: 10),
          const _DatingSkeleton(count: 4),
        ],
      ),
    );
  }
}

class _GridSkeleton extends StatelessWidget {
  final int count;
  const _GridSkeleton({super.key, required this.count});
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: count,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5, mainAxisSpacing: 14, crossAxisSpacing: 12, mainAxisExtent: 100),
      itemBuilder: (_, __) => Column(
        children: const [
          Expanded(child: Shimmer(child: _RoundedBox())),
          SizedBox(height: 6),
          _SkeletonButton(),
        ],
      ),
    );
  }
}

class _RoundedBox extends StatelessWidget {
  const _RoundedBox({super.key});
  @override
  Widget build(BuildContext context) =>
      Container(decoration: BoxDecoration(color: Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(12)));
}

class _SkeletonButton extends StatelessWidget {
  const _SkeletonButton({super.key});
  @override
  Widget build(BuildContext context) => Shimmer(
    child: Container(
      height: 24,
      width: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kPink, width: 1.2),
      ),
    ),
  );
}

class _ListSkeleton extends StatelessWidget {
  final int count;
  const _ListSkeleton({super.key, required this.count});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        count,
            (_) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: kDivider)),
            child: Row(children: const [
              SkeletonBox(h: 56, w: 56, r: 8),
              SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SkeletonLine(w: 120),
                SizedBox(height: 8),
                SkeletonLine(w: 180),
              ])),
              SizedBox(width: 12),
              _SkeletonButton(),
            ]),
          ),
        ),
      ),
    );
  }
}

class _DatingSkeleton extends StatelessWidget {
  final int count;
  const _DatingSkeleton({super.key, required this.count});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: LayoutBuilder(builder: (_, c) {
        final w = (c.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(
            count,
                (_) => SizedBox(
              width: w,
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: Shimmer(
                  child: Container(
                    decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}


/// ===================== App mini grid (API) =====================
class AppMiniGridFromApi extends StatelessWidget {
  const AppMiniGridFromApi({super.key});

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
        if (p.items.isEmpty) {
          return const _GridSkeleton(count: 10);
        }
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
          itemBuilder: (context, i) {
            final it = p.items[i];
            final target = it.androidUrl.isNotEmpty ? it.androidUrl : it.webUrl;

            return _MiniTile(
              icon: it.img,
              title: it.name,
              // ইমেজ/টাইটেল ট্যাপ করলে → ডিটেইল ফেচ পেজে index সহ যাবে
              onTapDetail: () {
                print('clicked kori');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailsPage(type: 'recommended', index: i),
                  ),
                );
              },
              // বাটন ট্যাপ করলে → ওপেন/ডাউনলোড
              onTapDownload: () => _open(target),
            );
          },
        );
      },
    );
  }
}

class _MiniTile extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback? onTapDetail;   // image/title → detail
  final VoidCallback? onTapDownload; // button → open/download

  const _MiniTile({
    required this.icon,
    required this.title,
    this.onTapDetail,
    this.onTapDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ইমেজে ট্যাপ করলে ডিটেইলে যাবে
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onTapDetail,
              child: CachedNetworkImage(
                imageUrl: icon,
                fit: BoxFit.cover,
                placeholder: (_, __) => const _RoundedBox(),
                errorWidget:   (_, __, ___) => const _RoundedBox(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        // টাইটেলেও ট্যাপ করলে ডিটেইল
        GestureDetector(
          onTap: onTapDetail,
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 8, color: Colors.black),
          ),
        ),
        const SizedBox(height: 4),
        // 下载 বাটন → ডাউনলোড/ওপেন
        GestureDetector(
          onTap: onTapDetail,
          child: Container(
            height: 24,
            width: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: kPink, width: 1.2),
            ),
            child: const Text(
              '下载',
              style: TextStyle(color: kPink, fontWeight: FontWeight.w700, fontSize: 12),
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
    const double h = 42;        // height
    const double r = 8;         // border radius

    return Container(
      height: h,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r),
        border: Border.all(color: const Color(0xFFECECEC)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient background (hot pink -> soft pink -> white fade)
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFFFF4FD3), // hot pink
                    Color(0xFFFF7FE3), // soft pink
                    Color(0x00FFFFFF), // fade to transparent (right)
                  ],
                  stops: [0.0, 0.65, 1.0],
                ),
              ),
            ),


            // Text row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  // left bright edge (thin highlight)
                  Container(
                    width: 3, height: 18,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.85),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // CN title (white, bold)
                  Text(
                    cn,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      shadows: [Shadow(color: Color(0x33000000), blurRadius: 2, offset: Offset(0,1))],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // EN subtitle (white, semi)
                  Text(
                    en.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .5,
                      shadows: const [Shadow(color: Color(0x22000000), blurRadius: 1)],
                    ),
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===================== Other (API list) =====================
class OtherSectionFromApi extends StatelessWidget {
  const OtherSectionFromApi({super.key});

  Future<void> _open(String url) async {
    print(url);
    print('1111111 others');
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
        if (p.items.isEmpty) {
          return const _ListSkeleton(count: 3);
        }
        return Column(
          children: [
            for (int i = 0; i < p.items.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: GestureDetector(
                  onTap: () => _open(
                      p.items[i].androidUrl.isNotEmpty ? p.items[i].androidUrl : p.items[i].webUrl
                  ),
                  child: _RecommendedTile(
                    item: _RecommendItem(
                      icon: p.items[i].img,
                      title: p.items[i].name,
                      sub: (p.items[i].slogan.isEmpty ? '私密可靠 · 真实有效' : p.items[i].slogan),
                    ),
                    index: i, // <-- নতুন
                  ),
                ),
              ),
          ],
        );

        // return Column(
        //   children: [
        //     for (final it in p.items)
        //       Padding(
        //         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        //         child: GestureDetector(
        //           onTap: () => _open(it.androidUrl.isNotEmpty ? it.androidUrl : it.webUrl),
        //           child: _RecommendedTile(
        //             item: _RecommendItem(
        //               icon: it.img,
        //               title: it.name,
        //               sub: (it.slogan.isEmpty ? '私密可靠 · 真实有效' : it.slogan),
        //             ),
        //           ),
        //         ),
        //       ),
        //   ],
        // );
      },
    );
  }
}

class _RecommendedTile extends StatelessWidget {
  final _RecommendItem item;
  final int index; // <-- নতুন

  const _RecommendedTile({required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailsPage(type: 'other', index: index), // <-- এখানে index
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: kDivider)),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: item.icon, width: 56, height: 56, fit: BoxFit.cover,
                placeholder: (_, __) => const SkeletonBox(h: 56, w: 56, r: 8),
                errorWidget: (_, __, ___) => const SkeletonBox(h: 56, w: 56, r: 8),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: kTextMain, fontSize: 15, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(item.sub, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: kTextSub, fontSize: 12)),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailsPage(type: 'other', index: index), // <-- এখানে index
                  ),
                );
              },
              child: Container(
                height: 26, width: 72, alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: kPink, width: 1.2),
                ),
                child: const Text('下载', style: TextStyle(color: kPink, fontWeight: FontWeight.w700, fontSize: 12)),
              ),
            ),
          ],
        ),
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

/// ===================== Cards & models =====================
class _DatingItem { final String name, photo, badge; const _DatingItem({required this.name, required this.photo, required this.badge}); }
class _LiveItem   { final String photo, tag, online; const _LiveItem({required this.photo, required this.tag, required this.online}); }
class _RecommendItem { final String icon, title, sub; const _RecommendItem({required this.icon, required this.title, required this.sub}); }

class DatingZoneSectionFromApi extends StatelessWidget {
  const DatingZoneSectionFromApi({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DatingZoneProvider>(
      builder: (_, p, __) {
        if (p.items.isEmpty) {
          return const _DatingSkeleton(count: 4);
        }

        return _TwoColGrid(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          spacing: 12,
          // ✅ index রাখার জন্য List.generate ব্যবহার
          children: List.generate(p.items.length, (i) {
            final it = p.items[i];
            final badge = (it.slogan.isNotEmpty) ? it.slogan : '${120 + i * 7}人约过';
            return _DatingCard(
              index: i, // <-- index পাঠানো হলো
              item: _DatingItem(name: it.name, photo: it.img, badge: badge),
            );
          }),
        );
      },
    );
  }
}

class _DatingCard extends StatelessWidget {
  final int index;              // <-- নতুন: index রিসিভ করব
  final _DatingItem item;

  const _DatingCard({
    super.key,
    required this.index,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {
          // ✅ এখানেই সঠিক index যাবে
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DatingZoneDetailsPage(
                type: 'dating-zone',
                index: index, // <-- এখানে index ইউজ করলাম
              ),
            ),
          );
        },
        child: Stack(children: [
          AspectRatio(
            aspectRatio: 3 / 4,
            child: CachedNetworkImage(
              imageUrl: item.photo,
              fit: BoxFit.cover,
              placeholder: (_, __) => Shimmer(child: Container(color: const Color(0xFFF2F2F7))),
              errorWidget:  (_, __, ___) => Shimmer(child: Container(color: const Color(0xFFF2F2F7))),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                  colors: [Colors.black.withOpacity(.55), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            left: 10,
            bottom: 10,
            child: Row(children: [
              Text(
                item.name,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: kPinkDeep, borderRadius: BorderRadius.circular(6)),
                child: Text(item.badge, style: const TextStyle(color: Colors.white, fontSize: 10)),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

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
              IgnorePointer(child: Container()),
            ],
          ),
        ),
      ),
    );
  }
}
