import 'dart:async';
import 'package:flutter/material.dart';

/// 모달 바텀시트, 다이얼로그 등 최상위 레이어 위로 안전하게 표출되는 플로팅 토스트/스낵바
class AppToast {
  static OverlayEntry? _currentEntry;

  /// 모달 바텀시트나 다이얼로그보다 상위(rootOverlay)에 토스트 알림을 띄웁니다.
  /// [isTop]이 false일 경우 일반 스낵바처럼 하단에 모달 시트 위로 표출됩니다.
  static void show(
    BuildContext context,
    String message, {
    IconData? icon,
    Color? iconColor,
    Color? backgroundColor,
    Duration duration = const Duration(milliseconds: 3000),
    bool isTop = false,
  }) {
    // 기존 활성화된 토스트가 있다면 즉시 제거
    _currentEntry?.remove();
    _currentEntry = null;

    final overlay = Overlay.maybeOf(context, rootOverlay: true) ??
        Overlay.maybeOf(context);
    if (overlay == null) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _ToastOverlayWidget(
        message: message,
        icon: icon,
        iconColor: iconColor,
        backgroundColor: backgroundColor,
        duration: duration,
        isTop: isTop,
        onDismissed: () {
          if (entry.mounted) {
            entry.remove();
          }
          if (_currentEntry == entry) {
            _currentEntry = null;
          }
        },
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);
  }

  /// 활성화된 토스트가 있다면 강제 닫기
  static void dismiss() {
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

class _ToastOverlayWidget extends StatefulWidget {
  final String message;
  final IconData? icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final Duration duration;
  final bool isTop;
  final VoidCallback onDismissed;

  const _ToastOverlayWidget({
    required this.message,
    this.icon,
    this.iconColor,
    this.backgroundColor,
    required this.duration,
    required this.isTop,
    required this.onDismissed,
  });

  @override
  State<_ToastOverlayWidget> createState() => _ToastOverlayWidgetState();
}

class _ToastOverlayWidgetState extends State<_ToastOverlayWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 250),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: widget.isTop ? const Offset(0, -0.6) : const Offset(0, 0.6),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeIn,
    ));

    _controller.forward();

    _dismissTimer = Timer(widget.duration, () {
      _dismiss();
    });
  }

  void _dismiss() {
    if (!mounted) return;
    _dismissTimer?.cancel();
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onDismissed();
      }
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;
    final bottomPadding = mediaQuery.padding.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultBg = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFF1E1B4B); // 짙은 인디고/슬레이트 프리미엄 다크
    final borderColor = isDark
        ? const Color(0xFF475569)
        : Colors.indigo.shade300.withValues(alpha: 0.6);

    return Positioned(
      top: widget.isTop ? (topPadding + 14) : null,
      bottom: !widget.isTop ? (bottomPadding + 24) : null,
      left: 16,
      right: 16,
      child: Center(
        child: Material(
          type: MaterialType.transparency,
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: GestureDetector(
                onTap: _dismiss,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: widget.backgroundColor ?? defaultBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          color: widget.iconColor ?? Colors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                      ],
                      Flexible(
                        child: Text(
                          widget.message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
