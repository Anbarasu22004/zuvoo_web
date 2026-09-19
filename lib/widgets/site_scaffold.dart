import 'package:flutter/material.dart';

import '../constants/layout.dart';
import '../theme/app_colors.dart';
import 'footer.dart';
import 'nav_bar.dart';
import 'smooth_scroll.dart';

class SiteScaffold extends StatefulWidget {
  const SiteScaffold({super.key, required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  State<SiteScaffold> createState() => _SiteScaffoldState();
}

class _SiteScaffoldState extends State<SiteScaffold> {
  final _controller = ScrollController();
  final _solid = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => _solid.value = _controller.offset > 24);
  }

  @override
  void dispose() {
    _controller.dispose();
    _solid.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Title(
      title: widget.title,
      color: AppColors.teal,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        endDrawer: context.isMobile ? const NavDrawer() : null,
        body: Stack(children: [
          Positioned.fill(
            child: SmoothScrollView(controller: _controller, children: [...widget.children, const SiteFooter()]),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<bool>(
              valueListenable: _solid,
              builder: (context, solid, _) => NavBar(solid: solid),
            ),
          ),
        ]),
      ),
    );
  }
}
