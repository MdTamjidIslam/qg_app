
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// ===== Common color (global)
const kPink = Color(0xFFFF34D3);

/// === OpenInstall short link (replace with yours)
const String kOpenInstallShortLink = 'https://thjx.svfeax.cn/index.html?c=do4123';

/// Helper: open OpenInstall H5 (does wakeupOrInstall on that page)
Future<void> _openOpenInstall() async {
  final uri = Uri.parse(kOpenInstallShortLink);
  // Prefer external app/browser
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok) {
    await launchUrl(uri, mode: LaunchMode.platformDefault);
  }
}

/// Detail page
/// Use:
/// Navigator.push(context, MaterialPageRoute(
///   builder: (_) => DetailPage(
///     title: '襄阳网红直播',
///     images: ['https://picsum.photos/id/1011/900/1200'],
///     description: '……',
///     ctaText: ' 点击下载 进入色情专区',
///   ),
/// ));
class DetailPage extends StatefulWidget {
  final String title;
  final List<String> images;      // one or more image URLs
  final String description;       // optional
  final String ctaText;           // bottom button text
  final VoidCallback? onTapCta;   // bottom button action
  final int initialIndex;

  const DetailPage({
    super.key,
    required this.title,
    required this.images,
    this.description = '',
    this.ctaText = ' 点击下载 进入色情专区',
    this.onTapCta,
    this.initialIndex = 0,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late final PageController _pc;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, (widget.images.length - 1).clamp(0, 999));
    _pc = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imgs = widget.images.isEmpty
        ? <String>['https://picsum.photos/seed/fallback/900/1200']
        : widget.images;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ===== Scroll area (image + content)
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _HeroImages(
                  controller: _pc,
                  images: imgs,
                  onChanged: (i) => setState(() => _index = i),
                ),
              ),
              SliverToBoxAdapter(child: _TitleBlock(title: widget.title)),
              const SliverToBoxAdapter(child: Divider(height: 1, color: Color(0xFFEDEDED))),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 120), // leave room for CTA bar
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('介绍：',
                          style: TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      Text(
                        widget.description.isEmpty ? '' : widget.description,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF444444), height: 1.4),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ===== Back button overlay (top-left, over image)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 8, top: 8),
              child: _CircleIconButton(
                icon: Icons.arrow_back_ios_new,
                onTap: () => Navigator.pop(context),
              ),
            ),
          ),

          // ===== Bottom pink CTA (fixed)
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                color: Colors.white,
                child: GestureDetector(
                  onTap: widget.onTapCta ?? _openOpenInstall, // <-- default: OpenInstall link
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
                      children: [
                        const Icon(Icons.download, color: Colors.white, size: 20),
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
      ),
    );
  }
}

/// ======= Top image area with page dots
class _HeroImages extends StatelessWidget {
  final PageController controller;
  final List<String> images;
  final ValueChanged<int> onChanged;

  const _HeroImages({
    required this.controller,
    required this.images,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 9 / 12, // tall portrait box
          child: PageView.builder(
            controller: controller,
            itemCount: images.length,
            onPageChanged: onChanged,
            itemBuilder: (_, i) => _NetImage(url: images[i]),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 14,
          child: Center(
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                int current = 0;
                if (controller.hasClients && controller.page != null) {
                  current = controller.page!.round();
                }
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(images.length, (i) {
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

/// Simple network image with graceful fallback
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
        child: const SizedBox(
          width: 36,
          height: 36,
          child: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}
