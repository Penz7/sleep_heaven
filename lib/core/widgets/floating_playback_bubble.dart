import 'dart:math' as math;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../features/mixer/controllers/mixer_controller.dart';
import '../../features/player/controllers/player_controller.dart';
import '../services/navigation_state_service.dart';
import '../../routes/app_routes.dart';

enum _ActivePlaybackSource { none, player, mixer }

class FloatingPlaybackBubble extends StatefulWidget {
  const FloatingPlaybackBubble({super.key});

  @override
  State<FloatingPlaybackBubble> createState() => _FloatingPlaybackBubbleState();
}

class _FloatingPlaybackBubbleState extends State<FloatingPlaybackBubble>
    with SingleTickerProviderStateMixin {
  static const double _bubbleSize = 66;
  static const double _collapsedHitboxPadding = 28;
  static const double _collapsedPanelSize = _bubbleSize + _collapsedHitboxPadding;
  static const double _margin = 16;
  static const double _topSafeOffset = 56;
  static const double _bottomSafeOffset = 96;

  late final AnimationController _discRotationController;
  bool _isExpanded = false;
  bool _isFocused = false;
  bool _isStopping = false;
  Offset _position = const Offset(0, 0);
  bool _isDragging = false;
  bool _draggingRight = true;
  Timer? _idleTimer;
  Timer? _introTimer;
  bool _introPulse = false;
  bool _wasVisibleLastFrame = false;

  @override
  void initState() {
    super.initState();
    _discRotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    _introTimer?.cancel();
    _discRotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final PlayerController playerController = Get.isRegistered<PlayerController>()
        ? Get.find<PlayerController>()
        : Get.put<PlayerController>(PlayerController(), permanent: true);
    final MixerController mixerController = Get.isRegistered<MixerController>()
        ? Get.find<MixerController>()
        : Get.put<MixerController>(MixerController(), permanent: true);
    final NavigationStateService navigationStateService =
        Get.isRegistered<NavigationStateService>()
        ? Get.find<NavigationStateService>()
        : Get.put<NavigationStateService>(NavigationStateService(), permanent: true);

    return Obx(() {
      final Size screen = MediaQuery.of(context).size;
      final _PlaybackBubbleState state = _resolveState(
        playerController: playerController,
        mixerController: mixerController,
      );
      final String route = navigationStateService.currentRoute.value;
      final bool hiddenOnSourceRoute =
          (state.source == _ActivePlaybackSource.player && route == Routes.player) ||
          (state.source == _ActivePlaybackSource.mixer && route == Routes.mixer);
      if ((!state.visible && !_isStopping) || hiddenOnSourceRoute) {
        if (_discRotationController.isAnimating) {
          _discRotationController.stop();
        }
        if (_isExpanded) {
          _isExpanded = false;
        }
        if (_isFocused) {
          _isFocused = false;
        }
        if (_position != Offset.zero) {
          final double collapsedWidth = _collapsedPanelSize;
          final double collapsedHeight = _collapsedPanelSize;
          final double rightX = screen.width - collapsedWidth - _margin;
          final double leftX = _margin;
          _position = _clampPosition(
            screenSize: screen,
            panelWidth: collapsedWidth,
            panelHeight: collapsedHeight,
            position: Offset(_draggingRight ? rightX : leftX, _position.dy),
          );
        }
        _wasVisibleLastFrame = false;
        return const SizedBox.shrink();
      }
      _triggerIntroPulse();

      if (state.isPlaying && !_discRotationController.isAnimating) {
        _discRotationController.repeat();
      } else if (!state.isPlaying && _discRotationController.isAnimating) {
        _discRotationController.stop();
      }

      final double panelWidth = _isExpanded ? 244 : _collapsedPanelSize;
      final double panelHeight = _isExpanded ? 88 : _collapsedPanelSize;
      if (_position == Offset.zero) {
        _position = Offset(
          screen.width - panelWidth - _margin,
          screen.height - panelHeight - _bottomSafeOffset,
        );
        _draggingRight = true;
      } else if (!_isDragging) {
        _position = _clampPosition(
          screenSize: screen,
          panelWidth: panelWidth,
          panelHeight: panelHeight,
          position: _position,
        );
      }

      return SafeArea(
        child: Stack(
          children: <Widget>[
            AnimatedPositioned(
              duration: _isDragging
                  ? Duration.zero
                  : const Duration(milliseconds: 280),
              curve: _isDragging ? Curves.linear : Curves.easeOutBack,
              left: _position.dx,
              top: _position.dy,
              child: GestureDetector(
                onPanStart: (_) {
                  _touch();
                  setState(() {
                    _isDragging = true;
                  });
                },
                onPanUpdate: (DragUpdateDetails details) {
                  final Offset next = _position + details.delta;
                  setState(() {
                    _position = _clampPosition(
                      screenSize: screen,
                      panelWidth: panelWidth,
                      panelHeight: panelHeight,
                      position: next,
                    );
                    _draggingRight = _position.dx > (screen.width - panelWidth) / 2;
                  });
                },
                onPanEnd: (DragEndDetails details) {
                  final Offset snapped = _snapToEdge(
                    velocityX: details.velocity.pixelsPerSecond.dx,
                    screenSize: screen,
                    panelWidth: panelWidth,
                    panelHeight: panelHeight,
                    currentPosition: _position,
                  );
                  setState(() {
                    _isDragging = false;
                    _position = snapped;
                    _draggingRight = _position.dx > (screen.width - panelWidth) / 2;
                  });
                  _startIdleCountdown();
                },
                onPanCancel: () {
                  final Offset snapped = _snapToEdge(
                    velocityX: 0,
                    screenSize: screen,
                    panelWidth: panelWidth,
                    panelHeight: panelHeight,
                    currentPosition: _position,
                  );
                  setState(() {
                    _isDragging = false;
                    _position = snapped;
                    _draggingRight = _position.dx > (screen.width - panelWidth) / 2;
                  });
                  _startIdleCountdown();
                },
                child: AnimatedSlide(
                  offset: _isExpanded || _isFocused || _isDragging
                      ? Offset.zero
                      : Offset(_draggingRight ? 0.32 : -0.32, 0),
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  child: AnimatedOpacity(
                    opacity: _isStopping ? 0.0 : (_isFocused ? 1.0 : 0.52),
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  child: AnimatedScale(
                    scale: _isStopping
                        ? 0.74
                        : (_isDragging ? 1.07 : (_isFocused ? 1.0 : 0.62)),
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutBack,
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutBack,
                      tween: Tween<double>(begin: 1.0, end: _introPulse ? 1.12 : 1.0),
                      builder: (BuildContext context, double introScale, Widget? child) {
                        return Transform.scale(scale: introScale, child: child);
                      },
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        child: _isExpanded
                            ? _ExpandedBubblePanel(
                                source: state.source,
                                isPlaying: state.isPlaying,
                                title: _resolveActiveTitle(
                                  source: state.source,
                                  playerController: playerController,
                                  mixerController: mixerController,
                                ),
                                onBubbleTap: _onPrimaryTap,
                                onBubbleDoubleTap: () => _openSourceRoute(state.source),
                                onPlayPause: () => _togglePlayPause(state.source),
                                onStop: () => _stop(state.source),
                                discRotationController: _discRotationController,
                                alignRight: _draggingRight,
                              )
                            : _CollapsedBubble(
                                isPlaying: state.isPlaying,
                                onTap: _onPrimaryTap,
                                onDoubleTap: () => _openSourceRoute(state.source),
                                discRotationController: _discRotationController,
                                alignRight: _draggingRight,
                              ),
                      ),
                    ),
                  ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  _PlaybackBubbleState _resolveState({
    required PlayerController playerController,
    required MixerController mixerController,
  }) {
    final bool mixerVisible =
        mixerController.hasActiveSession.value || mixerController.isPlayingRx.value;
    final bool playerVisible =
        playerController.hasActiveSession.value || playerController.isPlaying.value;

    if (mixerVisible) {
      return _PlaybackBubbleState(
        source: _ActivePlaybackSource.mixer,
        visible: true,
        isPlaying: mixerController.isPlayingRx.value,
      );
    }
    if (playerVisible) {
      return _PlaybackBubbleState(
        source: _ActivePlaybackSource.player,
        visible: true,
        isPlaying: playerController.isPlaying.value,
      );
    }
    return const _PlaybackBubbleState(
      source: _ActivePlaybackSource.none,
      visible: false,
      isPlaying: false,
    );
  }

  Future<void> _togglePlayPause(_ActivePlaybackSource source) async {
    switch (source) {
      case _ActivePlaybackSource.player:
        final PlayerController controller = Get.find<PlayerController>();
        if (controller.isPlaying.value) {
          await controller.pause();
        } else {
          await controller.play();
        }
        return;
      case _ActivePlaybackSource.mixer:
        final MixerController controller = Get.find<MixerController>();
        if (controller.isPlayingRx.value) {
          await controller.pauseAll();
        } else {
          await controller.playAll();
        }
        return;
      case _ActivePlaybackSource.none:
        return;
    }
  }

  Future<void> _stop(_ActivePlaybackSource source) async {
    _idleTimer?.cancel();
    setState(() {
      _isStopping = true;
      _isExpanded = false;
      _isFocused = false;
    });
    await Future<void>.delayed(const Duration(milliseconds: 220));
    switch (source) {
      case _ActivePlaybackSource.player:
        await Get.find<PlayerController>().stop();
        break;
      case _ActivePlaybackSource.mixer:
        await Get.find<MixerController>().stopAll();
        break;
      case _ActivePlaybackSource.none:
        break;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _isStopping = false;
    });
  }

  void _openSourceRoute(_ActivePlaybackSource source) {
    switch (source) {
      case _ActivePlaybackSource.player:
        Get.toNamed(Routes.player);
        return;
      case _ActivePlaybackSource.mixer:
        Get.toNamed(Routes.mixer);
        return;
      case _ActivePlaybackSource.none:
        return;
    }
  }

  void _onPrimaryTap() {
    _touch();
    if (!_isFocused) {
      setState(() {
        _isFocused = true;
        _isExpanded = false;
      });
      _startIdleCountdown();
      return;
    }
    if (!_isExpanded) {
      _toggleExpanded();
      return;
    }
    _toggleExpanded();
  }

  void _toggleExpanded() {
    final Size screen = MediaQuery.of(context).size;
    final bool expanding = !_isExpanded;
    final double nextWidth = expanding ? 244 : _collapsedPanelSize;
    final double nextHeight = expanding ? 88 : _collapsedPanelSize;
    final double rightX = screen.width - nextWidth - _margin;
    final double leftX = _margin;
    setState(() {
      _isExpanded = expanding;
      _position = _clampPosition(
        screenSize: screen,
        panelWidth: nextWidth,
        panelHeight: nextHeight,
        position: Offset(_draggingRight ? rightX : leftX, _position.dy),
      );
    });
    _startIdleCountdown();
  }

  String _resolveActiveTitle({
    required _ActivePlaybackSource source,
    required PlayerController playerController,
    required MixerController mixerController,
  }) {
    if (source == _ActivePlaybackSource.player) {
      return playerController.currentSound.value?.title ?? 'Sleep Sound';
    }
    if (source == _ActivePlaybackSource.mixer) {
      return 'Mixer';
    }
    return 'Playback';
  }

  Offset _clampPosition({
    required Size screenSize,
    required double panelWidth,
    required double panelHeight,
    required Offset position,
  }) {
    final double maxX = (screenSize.width - panelWidth - _margin).clamp(_margin, screenSize.width);
    final double maxY =
        (screenSize.height - panelHeight - _margin - _bottomSafeOffset).clamp(_margin, screenSize.height);
    return Offset(
      position.dx.clamp(_margin, maxX),
      position.dy.clamp(_margin + _topSafeOffset, maxY),
    );
  }

  Offset _snapToEdge({
    required double velocityX,
    required Size screenSize,
    required double panelWidth,
    required double panelHeight,
    required Offset currentPosition,
  }) {
    final double leftX = _margin;
    final double rightX = screenSize.width - panelWidth - _margin;
    final double centerX = currentPosition.dx + panelWidth / 2;
    final double screenCenterX = screenSize.width / 2;
    final bool flingRight = velocityX > 250;
    final bool flingLeft = velocityX < -250;
    final bool snapRight =
        flingRight || (!flingLeft && centerX >= screenCenterX);
    final double targetX = snapRight ? rightX : leftX;
    return _clampPosition(
      screenSize: screenSize,
      panelWidth: panelWidth,
      panelHeight: panelHeight,
      position: Offset(targetX, currentPosition.dy),
    );
  }

  void _touch() {
    if (!_isFocused && !_isExpanded) {
      return;
    }
    _startIdleCountdown();
  }

  void _startIdleCountdown() {
    _idleTimer?.cancel();
    _idleTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted || _isDragging || _isStopping) {
        return;
      }
      final Size screen = MediaQuery.of(context).size;
      final double collapsedWidth = _collapsedPanelSize;
      final double collapsedHeight = _collapsedPanelSize;
      final double rightX = screen.width - collapsedWidth - _margin;
      final double leftX = _margin;
      setState(() {
        _isExpanded = false;
        _isFocused = false;
        _position = _clampPosition(
          screenSize: screen,
          panelWidth: collapsedWidth,
          panelHeight: collapsedHeight,
          position: Offset(_draggingRight ? rightX : leftX, _position.dy),
        );
      });
    });
  }

  void _triggerIntroPulse() {
    if (_wasVisibleLastFrame) {
      return;
    }
    _wasVisibleLastFrame = true;
    _introTimer?.cancel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _introPulse = true;
      });
      _introTimer = Timer(const Duration(milliseconds: 700), () {
        if (!mounted) {
          return;
        }
        setState(() {
          _introPulse = false;
        });
      });
    });
  }
}

class _CollapsedBubble extends StatelessWidget {
  const _CollapsedBubble({
    required this.isPlaying,
    required this.onTap,
    required this.onDoubleTap,
    required this.discRotationController,
    required this.alignRight,
  });

  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;
  final AnimationController discRotationController;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        child: SizedBox(
          width: _FloatingPlaybackBubbleState._collapsedPanelSize,
          height: _FloatingPlaybackBubbleState._collapsedPanelSize,
          child: Align(
            alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
            child: Semantics(
              label: 'Playback bubble',
              hint: 'Tap to focus, tap again to expand, double tap to open source',
              button: true,
              child: _BubbleDisc(
                isPlaying: isPlaying,
                size: _FloatingPlaybackBubbleState._bubbleSize,
                discRotationController: discRotationController,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpandedBubblePanel extends StatelessWidget {
  const _ExpandedBubblePanel({
    required this.source,
    required this.isPlaying,
    required this.title,
    required this.onBubbleTap,
    required this.onBubbleDoubleTap,
    required this.onPlayPause,
    required this.onStop,
    required this.discRotationController,
    required this.alignRight,
  });

  final _ActivePlaybackSource source;
  final bool isPlaying;
  final String title;
  final VoidCallback onBubbleTap;
  final VoidCallback onBubbleDoubleTap;
  final VoidCallback onPlayPause;
  final VoidCallback onStop;
  final AnimationController discRotationController;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    final String subtitle = switch (source) {
      _ActivePlaybackSource.player => 'Now playing',
      _ActivePlaybackSource.mixer => 'Mix session',
      _ => 'Audio session',
    };
    final List<Widget> infoAndActions = <Widget>[
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(width: 8),
      _ActionChip(
        icon: isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
        semanticLabel: isPlaying ? 'Pause playback' : 'Resume playback',
        onTap: onPlayPause,
      ),
      const SizedBox(width: 6),
      _ActionChip(
        icon: Icons.stop_rounded,
        semanticLabel: 'Stop playback',
        onTap: onStop,
      ),
    ];

    final Widget disc = Semantics(
      label: 'Playback bubble',
      hint: 'Tap to collapse, double tap to open source screen',
      button: true,
      child: GestureDetector(
        onTap: onBubbleTap,
        onDoubleTap: onBubbleDoubleTap,
        child: _BubbleDisc(
          isPlaying: isPlaying,
          size: 54,
          discRotationController: discRotationController,
        ),
      ),
    );

    final List<Widget> rowChildren = alignRight
        ? <Widget>[
            Expanded(child: Row(mainAxisSize: MainAxisSize.min, children: infoAndActions)),
            const SizedBox(width: 10),
            disc,
          ]
        : <Widget>[
            disc,
            const SizedBox(width: 10),
            Expanded(child: Row(mainAxisSize: MainAxisSize.min, children: infoAndActions)),
          ];

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        width: 244,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xFF161824).withOpacity(0.88),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: Colors.white.withOpacity(0.14)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.32),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(children: rowChildren),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      child: Material(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}

class _BubbleDisc extends StatelessWidget {
  const _BubbleDisc({
    required this.isPlaying,
    required this.size,
    required this.discRotationController,
  });

  final bool isPlaying;
  final double size;
  final AnimationController discRotationController;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: <Color>[
            Colors.deepPurpleAccent.withOpacity(0.92),
            Colors.blueAccent.withOpacity(0.92),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.36),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: discRotationController,
        builder: (BuildContext context, Widget? child) {
          final double angle = isPlaying ? discRotationController.value * 2 * math.pi : 0;
          return Transform.rotate(
            angle: angle,
            child: child,
          );
        },
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              width: size * 0.66,
              height: size * 0.66,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.30),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
            ),
            Container(
              width: size * 0.16,
              height: size * 0.16,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaybackBubbleState {
  const _PlaybackBubbleState({
    required this.source,
    required this.visible,
    required this.isPlaying,
  });

  final _ActivePlaybackSource source;
  final bool visible;
  final bool isPlaying;
}
