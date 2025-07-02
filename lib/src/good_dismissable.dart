// ignore_for_file: library_private_types_in_public_api, document_ignores, lines_longer_than_80_chars, public_member_api_docs

import 'package:flutter/material.dart';

/// A customizable swipe card widget that mimics Gmail iOS style dismissible behavior
/// with a background card that appears behind the main card during swipe gesture
class GoodDismissable extends StatefulWidget {
  const GoodDismissable({
    required this.child,
    super.key,

    this.backgroundContent,
    this.onDismissed,
    this.onSwipeProgress,
    this.backgroundColor = Colors.red,
    this.cardOffset = 8.0,
    this.initialScale = 0.95,
    this.initialOpacity = 0.3,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeOutCubic,
    this.borderRadius = 12.0,
    this.backgroundElevation = 2.0,
    this.mainCardElevation = 4.0,
    this.dismissible = true,
    this.dismissDirections = const {
      DismissDirection.startToEnd,
      DismissDirection.endToStart,
    },
    this.dismissThreshold = 0.4,
    this.margin,
  });

  /// The main content widget that will be displayed and can be swiped
  final Widget child;

  /// Custom widget to display as background when swiping
  /// If null, a default delete icon will be shown
  final Widget? backgroundContent;

  /// Callback function called when the card is dismissed
  final VoidCallback? onDismissed;

  /// Callback function called during swipe with progress value (0.0 to 1.0)
  final ValueChanged<double>? onSwipeProgress;

  /// Background color of the card that appears behind during swipe
  final Color backgroundColor;

  /// Horizontal offset distance for the background card
  final double cardOffset;

  /// Initial scale factor for the background card (0.0 to 1.0)
  final double initialScale;

  /// Initial opacity for the background card (0.0 to 1.0)
  final double initialOpacity;

  /// Duration for the swipe animation
  final Duration animationDuration;

  /// Animation curve for the swipe effect
  final Curve animationCurve;

  /// Border radius for both cards
  final double borderRadius;

  /// Elevation for the background card
  final double backgroundElevation;

  /// Elevation for the main card
  final double mainCardElevation;

  /// Whether to enable swipe to dismiss functionality
  final bool dismissible;

  /// Direction(s) allowed for dismissing
  final Set<DismissDirection> dismissDirections;

  /// Threshold for triggering dismiss (0.0 to 1.0)
  final double dismissThreshold;

  /// Margin around the entire card widget
  final EdgeInsetsGeometry? margin;

  @override
  _GoodDismissableState createState() => _GoodDismissableState();
}

class _GoodDismissableState extends State<GoodDismissable>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _offsetAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _offsetAnimation =
        Tween<double>(
          begin: 0,
          end: 1,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: widget.animationCurve,
          ),
        );

    _scaleAnimation =
        Tween<double>(
          begin: widget.initialScale,
          end: 1,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: widget.animationCurve,
          ),
        );

    _opacityAnimation =
        Tween<double>(
          begin: widget.initialOpacity,
          end: 1,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: widget.animationCurve,
          ),
        );
  }

  @override
  void didUpdateWidget(GoodDismissable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animationDuration != widget.animationDuration ||
        oldWidget.animationCurve != widget.animationCurve ||
        oldWidget.initialScale != widget.initialScale ||
        oldWidget.initialOpacity != widget.initialOpacity) {
      _controller.dispose();
      _initializeAnimations();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildBackgroundContent() {
    return widget.backgroundContent ??
        Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(
            Icons.delete,
            color: Colors.white,
            size: 24,
          ),
        );
  }

  Widget _buildBackgroundCard() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned.fill(
          child: Transform.translate(
            offset: Offset(
              widget.cardOffset * (1 - _offsetAnimation.value),
              0,
            ),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Card(
                  elevation: widget.backgroundElevation,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                  ),
                  color: widget.backgroundColor,
                  child: _buildBackgroundContent(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainCard() {
    if (!widget.dismissible) {
      return Card(
        elevation: widget.mainCardElevation,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: widget.child,
      );
    }

    return Dismissible(
      key: UniqueKey(),
      background: Container(),
      secondaryBackground: Container(),
      direction: widget.dismissDirections.length == 1
          ? widget.dismissDirections.first
          : DismissDirection.horizontal,
      dismissThresholds: {
        for (final direction in widget.dismissDirections)
          direction: widget.dismissThreshold,
      },
      onUpdate: (details) {
        final progress = details.progress.clamp(0.0, 1.0);
        _controller.value = progress;
        widget.onSwipeProgress?.call(progress);
      },
      onDismissed: (direction) {
        widget.onDismissed?.call();
      },
      child: Card(
        elevation: widget.mainCardElevation,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: widget.child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          widget.margin ??
          const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _buildBackgroundCard(),
          _buildMainCard(),
        ],
      ),
    );
  }
}

/// Pre-configured GoodDismissable variants for common use cases
class GoodDismissableVariants {
  /// Gmail-style delete card with red background
  static GoodDismissable delete({
    required Widget child,
    Key? key,
    VoidCallback? onDismissed,
    ValueChanged<double>? onSwipeProgress,
  }) {
    return GoodDismissable(
      key: key,
      onDismissed: onDismissed,
      onSwipeProgress: onSwipeProgress,
      backgroundContent: Row(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
      child: child,
    );
  }

  /// Archive-style card with blue background
  static GoodDismissable archive({
    required Widget child,
    Key? key,
    VoidCallback? onDismissed,
    ValueChanged<double>? onSwipeProgress,
  }) {
    return GoodDismissable(
      key: key,
      onDismissed: onDismissed,
      onSwipeProgress: onSwipeProgress,
      backgroundColor: Colors.blue,
      backgroundContent: Row(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              child: const Text(
                'Archive',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(
              Icons.archive,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
      child: child,
    );
  }

  /// Mark as read card with green background
  static GoodDismissable markRead({
    required Widget child,
    Key? key,
    VoidCallback? onDismissed,
    ValueChanged<double>? onSwipeProgress,
  }) {
    return GoodDismissable(
      key: key,
      onDismissed: onDismissed,
      onSwipeProgress: onSwipeProgress,
      backgroundColor: Colors.green,
      backgroundContent: Row(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              child: const Text(
                'Mark Read',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(
              Icons.mark_email_read,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
      child: child,
    );
  }
}
