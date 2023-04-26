import 'dart:async';

import 'package:flutter/material.dart';

class ContentCard extends StatefulWidget {
  const ContentCard({
    Key? key,
    required this.onTap,
    required this.image,
    required this.description,
  }) : super(key: key);

  final GestureTapCallback onTap;
  final ImageProvider image;
  final String description;

  @override
  State<ContentCard> createState() => _ContentCardState();
}

class _ContentCardState extends State<ContentCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 200),
    vsync: this,
  );

  late final Animation<Offset> _cardSlideAnimation = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(0.0, -0.07),
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutSine,
  ));

  late final Animation<double> _thumbnailOpacityAnimation = Tween<double>(
    begin: 1.0,
    end: 0.1,
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutSine,
  ));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleHover(bool hovered) {
    if (hovered) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  Future<void> _handleTap() async {
    await _controller.reverse();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final surface = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : themeData.colorScheme.surface;
    return Theme(
      data: themeData.copyWith(
        colorScheme: themeData.colorScheme.copyWith(surface: surface),
      ),
      child: InkWell(
        onTap: _handleTap,
        onHover: _handleHover,
        mouseCursor: SystemMouseCursors.click,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        child: SlideTransition(
          position: _cardSlideAnimation,
          child: _ContentCard(
            thumbnail: _Thumbnail(
              widget.image,
              opacity: _thumbnailOpacityAnimation,
            ),
            description: _Description(
              widget.description,
              opacity: _controller.view,
            ),
          ),
        ),
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({required this.thumbnail, required this.description});

  final _Thumbnail thumbnail;
  final _Description description;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          thumbnail,
          description,
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail(this.image, {required this.opacity});

  final ImageProvider image;
  final Animation<double> opacity;

  @override
  Widget build(BuildContext context) {
    return Image(
      image: image,
      fit: BoxFit.cover,
      opacity: opacity,
    );
  }
}

class _Description extends StatelessWidget {
  const _Description(this.description, {required this.opacity});

  final String description;
  final Animation<double> opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: FadeTransition(
          opacity: opacity,
          child: Text(
            description,
            style: Theme.of(context).textTheme.labelLarge,
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
          ),
        ),
      ),
    );
  }
}
