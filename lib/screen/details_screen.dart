// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// // ==== তোমার API/মডেল ====
// import '../providers/details_Providers.dart'; // <-- এখানে তোমার DetailsData + DetailsProvider আছে
//
// /// ===== Common color (global fallback; থাকলে মুছে দাও)
// const kPink = Color(0xFFFF34D3);
//
// /// === OpenInstall short link (নিজেরটা বসাও)
// const String kOpenInstallShortLink = 'https://thjx.svfeax.cn/index.html?c=do4123';
//
// /// Helper: OpenInstall H5 (target যোগ করে; ফ্যালব্যাকে target সরাসরি খোলে)
// Future<void> _openOpenInstallWithTarget(String target) async {
//   Uri? uri;
//   if (kOpenInstallShortLink.isNotEmpty) {
//     final base = Uri.parse(kOpenInstallShortLink);
//     final qp = Map<String, String>.from(base.queryParameters);
//     if (target.isNotEmpty) qp['target'] = target;
//     uri = base.replace(queryParameters: qp);
//   } else if (target.isNotEmpty) {
//     uri = Uri.parse(target);
//   }
//   if (uri == null) return;
//   final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
//   if (!ok) {
//     await launchUrl(uri, mode: LaunchMode.platformDefault);
//   }
// }
//
// /// ========== ENTRY PAGE: API-Backed Dating Zone Details ==========
// class DatingZoneDetailsPage extends StatefulWidget {
//   final int index;                 // কোন আইটেম
//   final String type;               // default: 'dating-zone'
//   final String ctaText;            // বাটন টেক্সট
//   final int initialImageIndex;     // কোন ইমেজ থেকে শুরু
//
//   const DatingZoneDetailsPage({
//     super.key,
//     required this.index,
//     this.type = 'dating-zone',
//     this.ctaText = ' 点击下载 进入色情专区',
//     this.initialImageIndex = 0,
//   });
//
//   @override
//   State<DatingZoneDetailsPage> createState() => _DatingZoneDetailsPageState();
// }
//
// class _DatingZoneDetailsPageState extends State<DatingZoneDetailsPage> {
//   late final DetailsProvider _provider;
//   late Future<DetailsData> _future;
//   late final PageController _pc;
//   int _current = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _provider = DetailsProvider();
//     _future = _provider.fetch(widget.type, widget.index);
//     _pc = PageController(initialPage: widget.initialImageIndex);
//     _current = widget.initialImageIndex;
//   }
//
//   @override
//   void dispose() {
//     _pc.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<DetailsData>(
//       future: _future,
//       builder: (context, snap) {
//         if (snap.connectionState == ConnectionState.waiting) {
//           return const _FullScreenLoader(title: 'dating-zone');
//         }
//         if (snap.hasError) {
//           return _FullScreenError(
//             title: 'dating-zone',
//             message: '加载失败：${snap.error}',
//             onRetry: () {
//               setState(() {
//                 _future = _provider.fetch(widget.type, widget.index);
//               });
//             },
//           );
//         }
//
//         final d = snap.data!;
//         // images = pics; empty হলে cover fallback
//         final List<String> images = (d.pics.isNotEmpty)
//             ? d.pics
//             : (d.cover.isNotEmpty ? [d.cover] : ['https://picsum.photos/seed/fallback/900/1200']);
//         final String title = (d.name.isEmpty ? 'dating-zone' : d.name);
//         final String description = d.content;
//         final String target = d.androidUrl.isNotEmpty ? d.androidUrl : d.webUrl;
//
//         // ======= UI same as তোমার দেওয়া ডিজাইন =======
//         return Scaffold(
//           backgroundColor: Colors.white,
//           body: Stack(
//             children: [
//               // Scrollable content
//               CustomScrollView(
//                 slivers: [
//                   SliverToBoxAdapter(
//                     child: _HeroImages(
//                       controller: _pc,
//                       images: images,
//                       onChanged: (i) => setState(() => _current = i),
//                     ),
//                   ),
//                   SliverToBoxAdapter(child: _TitleBlock(title: title)),
//                   const SliverToBoxAdapter(
//                     child: Divider(height: 1, color: Color(0xFFEDEDED)),
//                   ),
//                   SliverToBoxAdapter(
//                     child: Padding(
//                       padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             '介绍：',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.black87,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           const SizedBox(height: 10),
//                           Text(
//                             description,
//                             style: const TextStyle(
//                               fontSize: 14,
//                               color: Color(0xFF444444),
//                               height: 1.4,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//
//               // Back button overlay
//               SafeArea(
//                 child: Padding(
//                   padding: const EdgeInsets.only(left: 8, top: 8),
//                   child: _CircleIconButton(
//                     icon: Icons.arrow_back_ios_new,
//                     onTap: () => Navigator.pop(context),
//                   ),
//                 ),
//               ),
//
//               // Bottom CTA
//               Align(
//                 alignment: Alignment.bottomCenter,
//                 child: SafeArea(
//                   top: false,
//                   child: Container(
//                     padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
//                     color: Colors.white,
//                     child: GestureDetector(
//                       onTap: () => _openOpenInstallWithTarget(target),
//                       child: Container(
//                         height: 50,
//                         alignment: Alignment.center,
//                         decoration: BoxDecoration(
//                           color: kPink,
//                           borderRadius: BorderRadius.circular(28),
//                           boxShadow: const [
//                             BoxShadow(
//                               color: Color(0x33FF34D3),
//                               blurRadius: 14,
//                               offset: Offset(0, 6),
//                             ),
//                           ],
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             const Icon(Icons.download, color: Colors.white, size: 20),
//                             const SizedBox(width: 8),
//                             Text(
//                               widget.ctaText,
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w700,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
//
// /// ======= Top image area with page dots (unchanged design)
// class _HeroImages extends StatelessWidget {
//   final PageController controller;
//   final List<String> images;
//   final ValueChanged<int> onChanged;
//
//   const _HeroImages({
//     required this.controller,
//     required this.images,
//     required this.onChanged,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         AspectRatio(
//           aspectRatio: 9 / 12,
//           child: PageView.builder(
//             controller: controller,
//             itemCount: images.length,
//             onPageChanged: onChanged,
//             itemBuilder: (_, i) => _NetImage(url: images[i]),
//           ),
//         ),
//         const SizedBox(height: 8),
//         SizedBox(
//           height: 14,
//           child: Center(
//             child: AnimatedBuilder(
//               animation: controller,
//               builder: (context, _) {
//                 int current = 0;
//                 if (controller.hasClients && controller.page != null) {
//                   current = controller.page!.round();
//                 }
//                 return Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: List.generate(images.length, (i) {
//                     final active = i == current;
//                     return Container(
//                       margin: const EdgeInsets.symmetric(horizontal: 3),
//                       width: 8,
//                       height: 8,
//                       decoration: BoxDecoration(
//                         color: active ? kPink : const Color(0xFFDADADA),
//                         shape: BoxShape.circle,
//                       ),
//                     );
//                   }),
//                 );
//               },
//             ),
//           ),
//         ),
//         const SizedBox(height: 8),
//       ],
//     );
//   }
// }
//
// /// network image with fallback (unchanged)
// class _NetImage extends StatelessWidget {
//   final String url;
//   const _NetImage({required this.url});
//
//   @override
//   Widget build(BuildContext context) {
//     return Image.network(
//       url,
//       fit: BoxFit.cover,
//       errorBuilder: (_, __, ___) => Container(
//         color: const Color(0xFFF2F2F2),
//         alignment: Alignment.center,
//         child: const Icon(Icons.broken_image_outlined, size: 40, color: Color(0xFFBDBDBD)),
//       ),
//     );
//   }
// }
//
// class _TitleBlock extends StatelessWidget {
//   final String title;
//   const _TitleBlock({required this.title});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.white,
//       padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
//       child: Text(
//         title,
//         style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w800),
//       ),
//     );
//   }
// }
//
// class _CircleIconButton extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback? onTap;
//   const _CircleIconButton({required this.icon, this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.black.withOpacity(.35),
//       shape: const CircleBorder(),
//       clipBehavior: Clip.antiAlias,
//       child: InkWell(
//         onTap: onTap,
//         child: const SizedBox(
//           width: 36,
//           height: 36,
//           child: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
//         ),
//       ),
//     );
//   }
// }
//
// /// ======= লোডিং/এরর ফুলস্ক্রিন =======
// class _FullScreenLoader extends StatelessWidget {
//   final String title;
//   const _FullScreenLoader({required this.title});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Stack(children: [
//         const Center(child: CircularProgressIndicator()),
//         SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.only(left: 8, top: 8),
//             child: _CircleIconButton(
//               icon: Icons.arrow_back_ios_new,
//               onTap: () => Navigator.pop(context),
//             ),
//           ),
//         ),
//       ]),
//     );
//   }
// }
//
// class _FullScreenError extends StatelessWidget {
//   final String title;
//   final String message;
//   final VoidCallback onRetry;
//   const _FullScreenError({required this.title, required this.message, required this.onRetry});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Stack(children: [
//         Center(
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(message, textAlign: TextAlign.center),
//                 const SizedBox(height: 12),
//                 ElevatedButton(onPressed: onRetry, child: const Text('重试')),
//               ],
//             ),
//           ),
//         ),
//         SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.only(left: 8, top: 8),
//             child: _CircleIconButton(
//               icon: Icons.arrow_back_ios_new,
//               onTap: () => Navigator.pop(context),
//             ),
//           ),
//         ),
//       ]),
//     );
//   }
// }
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// // ==== তোমার API/মডেল ====
// // নিশ্চিত হও ফাইল/ক্লাসের নাম ঠিক আছে: DetailsData + DetailsProvider
// import '../providers/details_Providers.dart';
//
// /// ===== Common color (global fallback; থাকলে মুছে দাও)
// const kPink = Color(0xFFFF34D3);
//
// /// === OpenInstall short link (নিজেরটা বসাও; ফাঁকা থাকলে সরাসরি target ওপেন হবে)
// const String kOpenInstallShortLink = '';
//
// /// -------- URL sanitize helpers --------
// bool _isLikelyValidUrl(String s) {
//   if (s.isEmpty) return false;
//   final t = s.trim().toLowerCase();
//   if (t == 'http://' || t == 'https://') return false; // incomplete
//   Uri? u;
//   try { u = Uri.parse(s); } catch (_) { return false; }
//   return (u.scheme == 'http' || u.scheme == 'https') && (u.host.isNotEmpty);
// }
//
// String _pickTarget(String androidUrl, String webUrl) {
//   if (_isLikelyValidUrl(androidUrl)) return androidUrl;
//   if (_isLikelyValidUrl(webUrl)) return webUrl;
//   return '';
// }
//
// /// External open wrapper
// Future<void> _openExternalUri(Uri uri) async {
//   try {
//     final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
//     if (!ok) {
//       await launchUrl(uri, mode: LaunchMode.platformDefault);
//     }
//   } catch (_) {/* ignore */}
// }
//
// /// OpenInstall short link + target (fallback: target direct)
// Future<void> _openTargetUrl(BuildContext context, String target) async {
//   if (!_isLikelyValidUrl(target)) {
//     // ✅ target invalid হলে blank না দেখিয়ে user feedback দাও
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('暂无法打开链接')),
//     );
//     return;
//   }
//
//   if (kOpenInstallShortLink.isNotEmpty) {
//     final base = Uri.parse(kOpenInstallShortLink);
//     final uri = base.replace(queryParameters: {
//       ...base.queryParameters,
//       'target': target,
//     });
//     await _openExternalUri(uri);
//     return;
//   }
//   await _openExternalUri(Uri.parse(target));
// }
//
// /// ========== ENTRY PAGE: API-Backed Dating Zone Details ==========
// class DatingZoneDetailsPage extends StatefulWidget {
//   final int index;                 // কোন আইটেম
//   final String type;               // default: 'dating-zone'
//   final String ctaText;            // বাটন টেক্সট
//   final int initialImageIndex;     // কোন ইমেজ থেকে শুরু
//
//   const DatingZoneDetailsPage({
//     super.key,
//     required this.index,
//     this.type = 'dating-zone',
//     this.ctaText = ' 点击下载 进入色情专区',
//     this.initialImageIndex = 0,
//   });
//
//   @override
//   State<DatingZoneDetailsPage> createState() => _DatingZoneDetailsPageState();
// }
//
// class _DatingZoneDetailsPageState extends State<DatingZoneDetailsPage> {
//   late final DetailsProvider _provider;
//   late Future<DetailsData> _future;
//   late final PageController _pc;
//   int _current = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _provider = DetailsProvider();
//     _future = _provider.fetch(widget.type, widget.index);
//     _pc = PageController(initialPage: widget.initialImageIndex);
//     _current = widget.initialImageIndex;
//   }
//
//   @override
//   void dispose() {
//     _pc.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<DetailsData>(
//       future: _future,
//       builder: (context, snap) {
//         if (snap.connectionState == ConnectionState.waiting) {
//           return const _FullScreenLoader(title: 'dating-zone');
//         }
//         if (snap.hasError) {
//           return _FullScreenError(
//             title: 'dating-zone',
//             message: '加载失败：${snap.error}',
//             onRetry: () {
//               setState(() {
//                 _future = _provider.fetch(widget.type, widget.index);
//               });
//             },
//           );
//         }
//
//         final d = snap.data!;
//         // images = pics; empty হলে cover fallback (de-dup সহ)
//         final List<String> images = () {
//           final list = <String>[];
//           if (d.pics.isNotEmpty) list.addAll(d.pics);
//           if (list.isEmpty && d.cover.isNotEmpty) list.add(d.cover);
//           if (list.isEmpty) list.add('https://picsum.photos/seed/fallback/900/1200');
//           final seen = <String>{};
//           return list.where((e) => seen.add(e)).toList();
//         }();
//
//         final String title = (d.name.isEmpty ? 'dating-zone' : d.name);
//         final String description = d.content;
//
//         // ✅ target স্যানিটাইজ (androidurl → url; invalid হলে empty)
//         final String target = _pickTarget(d.androidUrl, d.webUrl);
//         final bool targetOk = _isLikelyValidUrl(target);
//
//         return Scaffold(
//           backgroundColor: Colors.white,
//           body: Stack(
//             children: [
//               // Scrollable content
//               CustomScrollView(
//                 slivers: [
//                   SliverToBoxAdapter(
//                     child: _HeroImages(
//                       controller: _pc,
//                       images: images,
//                       onChanged: (i) => setState(() => _current = i),
//                     ),
//                   ),
//                   SliverToBoxAdapter(child: _TitleBlock(title: title)),
//                   const SliverToBoxAdapter(
//                     child: Divider(height: 1, color: Color(0xFFEDEDED)),
//                   ),
//                   SliverToBoxAdapter(
//                     child: Padding(
//                       padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             '介绍：',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.black87,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           const SizedBox(height: 10),
//                           Text(
//                             (description.trim().isEmpty ? '暂无简介' : description),
//                             style: const TextStyle(
//                               fontSize: 14,
//                               color: Color(0xFF444444),
//                               height: 1.4,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//
//               // Back button overlay
//               SafeArea(
//                 child: Padding(
//                   padding: const EdgeInsets.only(left: 8, top: 8),
//                   child: _CircleIconButton(
//                     icon: Icons.arrow_back_ios_new,
//                     onTap: () => Navigator.pop(context),
//                   ),
//                 ),
//               ),
//
//               // Bottom CTA
//               Align(
//                 alignment: Alignment.bottomCenter,
//                 child: SafeArea(
//                   top: false,
//                   child: Container(
//                     padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
//                     color: Colors.white,
//                     child: GestureDetector(
//                       onTap: () => _openTargetUrl(context, target), // ✅ guarded
//                       child: Opacity( // target invalid হলে UI visually dim
//                         opacity: targetOk ? 1.0 : 0.6,
//                         child: Container(
//                           height: 50,
//                           alignment: Alignment.center,
//                           decoration: BoxDecoration(
//                             color: kPink,
//                             borderRadius: BorderRadius.circular(28),
//                             boxShadow: const [
//                               BoxShadow(
//                                 color: Color(0x33FF34D3),
//                                 blurRadius: 14,
//                                 offset: Offset(0, 6),
//                               ),
//                             ],
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               const Icon(Icons.download, color: Colors.white, size: 20),
//                               const SizedBox(width: 8),
//                               Text(
//                                 widget.ctaText,
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w700,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
//
// /// ======= Top image area with page dots (unchanged design)
// class _HeroImages extends StatelessWidget {
//   final PageController controller;
//   final List<String> images;
//   final ValueChanged<int> onChanged;
//
//   const _HeroImages({
//     required this.controller,
//     required this.images,
//     required this.onChanged,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     // ✅ 1+ ইমেজে ডট দেখাই; 1 হলে কেবল ছবি
//     final hasDots = images.length > 1;
//     return Column(
//       children: [
//         AspectRatio(
//           aspectRatio: 9 / 12,
//           child: PageView.builder(
//             controller: controller,
//             itemCount: images.length,
//             onPageChanged: onChanged,
//             itemBuilder: (_, i) => _NetImage(url: images[i]),
//           ),
//         ),
//         if (hasDots) ...[
//           const SizedBox(height: 8),
//           SizedBox(
//             height: 14,
//             child: Center(
//               child: AnimatedBuilder(
//                 animation: controller,
//                 builder: (context, _) {
//                   int current = 0;
//                   if (controller.hasClients && controller.page != null) {
//                     current = controller.page!.round();
//                   }
//                   return Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: List.generate(images.length, (i) {
//                       final active = i == current;
//                       return Container(
//                         margin: const EdgeInsets.symmetric(horizontal: 3),
//                         width: 8,
//                         height: 8,
//                         decoration: BoxDecoration(
//                           color: active ? kPink : const Color(0xFFDADADA),
//                           shape: BoxShape.circle,
//                         ),
//                       );
//                     }),
//                   );
//                 },
//               ),
//             ),
//           ),
//           const SizedBox(height: 8),
//         ],
//       ],
//     );
//   }
// }
//
// /// network image with fallback (unchanged)
// class _NetImage extends StatelessWidget {
//   final String url;
//   const _NetImage({required this.url});
//
//   @override
//   Widget build(BuildContext context) {
//     return Image.network(
//       url,
//       fit: BoxFit.cover,
//       errorBuilder: (_, __, ___) => Container(
//         color: const Color(0xFFF2F2F2),
//         alignment: Alignment.center,
//         child: const Icon(Icons.broken_image_outlined, size: 40, color: Color(0xFFBDBDBD)),
//       ),
//     );
//   }
// }
//
// class _TitleBlock extends StatelessWidget {
//   final String title;
//   const _TitleBlock({required this.title});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.white,
//       padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
//       child: Text(
//         title,
//         style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w800),
//       ),
//     );
//   }
// }
//
// class _CircleIconButton extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback? onTap;
//   const _CircleIconButton({required this.icon, this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.black.withOpacity(.35),
//       shape: const CircleBorder(),
//       clipBehavior: Clip.antiAlias,
//       child: InkWell(
//         onTap: onTap,
//         child: const SizedBox(
//           width: 36,
//           height: 36,
//           child: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
//         ),
//       ),
//     );
//   }
// }
//
// /// ======= লোডিং/এরর ফুলস্ক্রিন =======
// class _FullScreenLoader extends StatelessWidget {
//   final String title;
//   const _FullScreenLoader({required this.title});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Stack(children: [
//         const Center(child: CircularProgressIndicator()),
//         SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.only(left: 8, top: 8),
//             child: _CircleIconButton(
//               icon: Icons.arrow_back_ios_new,
//               onTap: () => Navigator.pop(context),
//             ),
//           ),
//         ),
//       ]),
//     );
//   }
// }
//
// class _FullScreenError extends StatelessWidget {
//   final String title;
//   final String message;
//   final VoidCallback onRetry;
//   const _FullScreenError({required this.title, required this.message, required this.onRetry});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Stack(children: [
//         Center(
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(message, textAlign: TextAlign.center),
//                 const SizedBox(height: 12),
//                 ElevatedButton(onPressed: onRetry, child: const Text('重试')),
//               ],
//             ),
//           ),
//         ),
//         SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.only(left: 8, top: 8),
//             child: _CircleIconButton(
//               icon: Icons.arrow_back_ios_new,
//               onTap: () => Navigator.pop(context),
//             ),
//           ),
//         ),
//       ]),
//     );
//   }
// }


import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// ==== তোমার API/মডেল ====
// নিশ্চিত হও ফাইল/ক্লাসের নাম ঠিক আছে: DetailsData + DetailsProvider
import '../providers/details_Providers.dart';

/// ===== Common color (global fallback; থাকলে মুছে দাও)
const kPink = Color(0xFFFF34D3);

/// === OpenInstall short link (নিজেরটা বসাও)
const String kOpenInstallShortLink = '';

/// -------- URL sanitize helpers --------
bool _isLikelyValidUrl(String s) {
  if (s.isEmpty) return false;
  // অনেক সময় "https://" এরকম অসম্পূর্ণ স্ট্রিং আসে; সেগুলো বাদ
  if (s.trim().toLowerCase() == 'http://' || s.trim().toLowerCase() == 'https://') return false;
  Uri? u;
  try { u = Uri.parse(s); } catch (_) { return false; }
  // scheme + host থাকলে valid ধরি
  return (u.scheme == 'http' || u.scheme == 'https') && (u.host.isNotEmpty);
}

String _pickTarget(String androidUrl, String webUrl) {
  if (_isLikelyValidUrl(androidUrl)) return androidUrl;
  if (_isLikelyValidUrl(webUrl)) return webUrl;
  return '';
}

/// Helper: OpenInstall H5 (target যোগ করে; ফ্যালব্যাকে target সরাসরি খোলে)
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

/// ========== ENTRY PAGE: API-Backed Dating Zone Details ==========
class DatingZoneDetailsPage extends StatefulWidget {
  final int index;                 // কোন আইটেম
  final String type;               // default: 'dating-zone'
  final String ctaText;            // বাটন টেক্সট
  final int initialImageIndex;     // কোন ইমেজ থেকে শুরু

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
          return const _FullScreenLoader(title: 'dating-zone');
        }
        if (snap.hasError) {
          return _FullScreenError(
            title: 'dating-zone',
            message: '加载失败：${snap.error}',
            onRetry: () {
              setState(() {
                _future = _provider.fetch(widget.type, widget.index);
              });
            },
          );
        }

        final d = snap.data!;
        // images = pics; empty হলে cover fallback
        final List<String> images = () {
          final list = <String>[];
          if (d.pics.isNotEmpty) list.addAll(d.pics);
          // fallback + de-dup
          if (list.isEmpty && d.cover.isNotEmpty) list.add(d.cover);
          if (list.isEmpty) list.add('https://picsum.photos/seed/fallback/900/1200');
          // de-dup (simple)
          final seen = <String>{};
          return list.where((e) => seen.add(e)).toList();
        }();

        final String title = (d.name.isEmpty ? 'dating-zone' : d.name);
        final String description = d.content;
        final String target = _pickTarget(d.androidUrl, d.webUrl);

        // ======= UI same as তোমার দেওয়া ডিজাইন =======
        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              // Scrollable content
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _HeroImages(
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
      },
    );
  }
}

/// ======= Top image area with page dots (unchanged design)
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
          aspectRatio: 9 / 12,
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

/// network image with fallback (unchanged)
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

/// ======= লোডিং/এরর ফুলস্ক্রিন =======
class _FullScreenLoader extends StatelessWidget {
  final String title;
  const _FullScreenLoader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(children: [
        const Center(child: CircularProgressIndicator()),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 8, top: 8),
            child: _CircleIconButton(
              icon: Icons.arrow_back_ios_new,
              onTap: () => Navigator.pop(context),
            ),
          ),
        ),
      ]),
    );
  }
}

class _FullScreenError extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;
  const _FullScreenError({required this.title, required this.message, required this.onRetry});
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
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 8, top: 8),
            child: _CircleIconButton(
              icon: Icons.arrow_back_ios_new,
              onTap: () => Navigator.pop(context),
            ),
          ),
        ),
      ]),
    );
  }
}
