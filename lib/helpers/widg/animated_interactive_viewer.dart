import 'package:flutter/material.dart';

class AnimatedInteractiveViewer extends StatefulWidget {
  ///It is very similar to the InteractiveViewer except the AnimatedInteractiveViewer
  ///have a double-tap animated zoom
  const AnimatedInteractiveViewer({
    super.key,
    required this.child,
    this.curve = Curves.ease,
    this.duration = const Duration(milliseconds: 200),
    this.clipBehavior = Clip.none,
    this.alignPanAxis = false,
    this.boundaryMargin = EdgeInsets.zero,
    this.constrained = true,
    this.panEnabled = true,
    this.scaleEnabled = true,
    this.maxScale = 2.0,
    this.minScale = 0.8,
    this.onInteractionEnd,
    this.onInteractionStart,
    this.onInteractionUpdate,
    this.transformationController,
    this.onDoubleTapDown,
  });

  /// It is the curve that the SwipeTransition performs
  final Curve curve;

  /// The Widget to perform the transformations on.
  ///
  /// Cannot be null.
  final Widget child;

  ///The length of time than the double-tap zoom
  ///
  ///Default: `Duration(milliseconds: 200)`
  final Duration duration;

  final Clip clipBehavior;

  final bool alignPanAxis;

  final EdgeInsets boundaryMargin;

  final bool constrained;

  final bool panEnabled;

  final bool scaleEnabled;

  final double maxScale;

  final double minScale;

  final GestureScaleEndCallback? onInteractionEnd;

  final GestureScaleStartCallback? onInteractionStart;

  final GestureScaleUpdateCallback? onInteractionUpdate;

  final TransformationController? transformationController;

  final GestureTapDownCallback? onDoubleTapDown;

  @override
  AnimatedInteractiveViewerState createState() =>
      AnimatedInteractiveViewerState();
}

class AnimatedInteractiveViewerState extends State<AnimatedInteractiveViewer>
    with TickerProviderStateMixin {
  late TransformationController _controller;
  late AnimationController _animationController;
  Animation<Matrix4>? _animationMatrix4;

  @override
  void dispose() {
    if (widget.transformationController == null) _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _controller = widget.transformationController ?? TransformationController();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    super.initState();
  }

  //Clear Matrix4 animation
  void _onInteractionStart(ScaleStartDetails details) {
    widget.onInteractionStart?.call(details);
    if (_animationController.status == AnimationStatus.forward) {
      _clearAnimation();
    }
  }

  void _changeControllerMatrix4() {
    _controller.value = _animationMatrix4!.value;
    if (!_animationController.isAnimating) _clearAnimation();
  }

  void _clearAnimation() {
    _animationController.stop();
    _animationMatrix4?.removeListener(_changeControllerMatrix4);
    _animationMatrix4 = null;
    _animationController.reset();
  }

  //Animate MATRIX4
  Future<void> _onDoubleTapHandle(TapDownDetails details) async {
    if (_controller.value == Matrix4.identity()) {
      final double scale = widget.maxScale;
      final Offset position = details.localPosition;
      // final Matrix4 matrix = Matrix4.diagonal3Values(scale, scale, 1.0);

      // if (scale > 2.4) {
      //   matrix.translate(-position.dx, -position.dy);
      // } else {
      //   matrix.setTranslation(vector.Vector3(-position.dx, -position.dy, 0.0));
      // }

      final Matrix4 matrix = Matrix4(
          //Column1
          scale,
          0.0,
          0.0,
          0.0,
          //Column2
          0.0,
          scale,
          0.0,
          0.0,
          //Column3
          0.0,
          0.0,
          scale,
          0.0,
          //Column4
          scale < 2.4 ? -position.dx : -position.dx * scale,
          scale < 2.4 ? -position.dy : -position.dy * scale,
          0.0,
          1.0);
      await animateMatrix4(matrix);
    } else {
      await animateMatrix4(Matrix4.identity());
    }
    widget.onDoubleTapDown?.call(details);
  }

  Future<void> animateMatrix4(Matrix4 value) async {
    _animationMatrix4 = Matrix4Tween(
      begin: _controller.value,
      end: value,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.curve,
    ));
    _animationController.duration = widget.duration;
    _animationMatrix4!.addListener(_changeControllerMatrix4);
    await _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: widget.minScale,
      maxScale: widget.maxScale,
      transformationController: _controller,
      onInteractionStart: _onInteractionStart,
      onInteractionUpdate: widget.onInteractionUpdate,
      onInteractionEnd: widget.onInteractionEnd,
      clipBehavior: widget.clipBehavior,
      constrained: widget.constrained,
      panEnabled: widget.panEnabled,
      // panAxis: widget.alignPanAxis,
      boundaryMargin: widget.boundaryMargin,
      scaleEnabled: widget.scaleEnabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onDoubleTap: () {},
        onDoubleTapDown: _onDoubleTapHandle,
        child: widget.child,
      ),
    );
  }
}
