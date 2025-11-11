import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../providers/apiList_provider.dart';
import 'details_screen.dart'; // <-- DatingZoneProvider এখানে আছে ধরে নিলাম

/// ===================== BRAND COLORS =====================
const kPink       = Color(0xFFFF34D3);
const kTextMain   = Color(0xFF222222);
const kDivider    = Color(0xFFEFEFEF);

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

/// ===================== PAGE =====================
class BrothelPage extends StatefulWidget {
  const BrothelPage({super.key});
  @override
  State<BrothelPage> createState() => _BrothelPageState();
}

class _BrothelPageState extends State<BrothelPage> {
  bool _fetched = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_fetched) {
      // ✅ প্রথমবারেই API কল
      context.read<DatingZoneProvider>().fetch();
      _fetched = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<DatingZoneProvider>();
    final firstLoading = p.items.isEmpty && p.error == null; // প্রথম লোড

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPink,
        toolbarHeight: 60,
        elevation: 0,
        centerTitle: true,
        title: const Text('青楼', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: firstLoading
            ? const _DatingSkeleton(count: 6) // ✅ শিমার স্কেলেটন
            : (p.error != null)
            ? Center(child: Text('加载失败: ${p.error}', style: const TextStyle(color: Colors.red)))
            : const Padding(
          padding: EdgeInsets.only(top: 12),
          child: _DatingSection(),
        ),
      ),
    );
  }
}

/// ===================== SECTION (from Provider) =====================
class _DatingSection extends StatelessWidget {
  const _DatingSection();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<DatingZoneProvider>();
    // Provider item → local model
    final items = <_DatingItem>[];
    for (int i = 0; i < p.items.length; i++) {
      final it = p.items[i];
      final badge = (it.slogan.isNotEmpty) ? it.slogan : '49人约过';
      items.add(_DatingItem(name: it.name, photo: it.img, badge: badge));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(cn: '同城约会', en: 'DATING ZONE'),
          const SizedBox(height: 10),
          _TwoColGrid(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            spacing: 12,
            children: items.map((e) => _DatingCard(item: e)).toList(),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

/// ===================== CARD (match the screenshot) =====================
class _DatingCard extends StatelessWidget {
  final _DatingItem item;
  const _DatingCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image box with rounded corners & soft shadow
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: InkWell(
                onTap: (){
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (_) => DetailPage(
                  //       title: item.name,              // <-- title pass
                  //       images: [item.photo],            // <-- 1+ image pass (এখানে ১টা)
                  //       description: item.badge,           // (ঐচ্ছিক) আপনি চাইলে টেক্সট দিন
                  //       ctaText: ' 点击下载 进入色情专区',
                  //     ),
                  //   ),
                  // );
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: item.photo,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Shimmer(child: Container(color: const Color(0xFFF2F2F7))),
                      errorWidget:  (_, __, ___) => Shimmer(child: Container(color: const Color(0xFFF2F2F7))),
                    ),
                    Positioned(left: 8, top: 8, child: _TopBadge(text: item.badge)),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          item.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: kTextMain, fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _TopBadge extends StatelessWidget {
  final String text;
  const _TopBadge({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: kPink,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: kPink.withOpacity(.25), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800, height: 1.0),
      ),
    );
  }
}

/// ===================== SKELETONS =====================
class _DatingSkeleton extends StatelessWidget {
  final int count;
  const _DatingSkeleton({super.key, required this.count});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: LayoutBuilder(builder: (_, c) {
        final w = (c.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(
            count,
                (_) => SizedBox(
              width: w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 3 / 4,
                    child: Shimmer(
                      child: Container(
                        decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Shimmer(child: Container(height: 12, width: 90, decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(6)))),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// ===================== HELPERS =====================
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
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children.map((e) => SizedBox(width: w, child: e)).toList(),
        );
      }),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String cn, en;
  const _SectionTitle({required this.cn, required this.en});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      margin: const EdgeInsets.symmetric(horizontal: 12),
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
          Text(en, style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w600)),
          const Spacer(),
          Container(width: 64, height: 6, decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(20))),
        ],
      ),
    );
  }
}

/// ===================== LOCAL MODELS =====================
class _DatingItem {
  final String name, photo, badge;
  const _DatingItem({required this.name, required this.photo, required this.badge});
}
