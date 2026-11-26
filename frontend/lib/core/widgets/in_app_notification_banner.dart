import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class InAppNotificationBanner {
  static OverlayEntry? _currentEntry;

  static void show(BuildContext context, {
    required String title,
    required String body,
    String type = 'info',
    VoidCallback? onTap,
  }) {
    dismiss();

    final overlay = Overlay.of(context, rootOverlay: true);

    _currentEntry = OverlayEntry(
      builder: (context) => _BannerWidget(
        title: title,
        body: body,
        type: type,
        onTap: onTap,
        onDismiss: dismiss,
      ),
    );

    overlay.insert(_currentEntry!);
  }

  static void dismiss() {
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

class _BannerWidget extends StatefulWidget {
  final String title;
  final String body;
  final String type;
  final VoidCallback? onTap;
  final VoidCallback onDismiss;

  const _BannerWidget({
    required this.title,
    required this.body,
    required this.type,
    this.onTap,
    required this.onDismiss,
  });

  @override
  State<_BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<_BannerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _bannerColor {
    final t = widget.type.toUpperCase();
    if (t.contains('BRAKE') || t.contains('HOT_AXLE') || t.contains('ACP')) {
      return const Color(0xFFD32F2F);
    }
    if (t.contains('ODOUR')) return const Color(0xFFE65100);
    return const Color(0xFF1565C0);
  }

  IconData get _icon {
    final t = widget.type.toUpperCase();
    if (t.contains('BRAKE')) return Icons.warning_amber_rounded;
    if (t.contains('HOT_AXLE')) return Icons.local_fire_department;
    if (t.contains('ODOUR')) return Icons.air;
    if (t.contains('ACP')) return Icons.link_off;
    return Icons.notifications_active;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 8,
      right: 8,
      child: SlideTransition(
        position: _slideAnimation,
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              widget.onDismiss();
              widget.onTap?.call();
            },
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
                _controller.reverse().then((_) => widget.onDismiss());
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              decoration: BoxDecoration(
                color: _bannerColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _bannerColor.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(_icon, color: Colors.white, size: 24),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.body,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 11,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.close, color: Colors.white.withValues(alpha: 0.7), size: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
