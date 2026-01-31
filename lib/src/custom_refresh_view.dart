import 'dart:math' as math;

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';

class CustomRefreshView extends StatelessWidget {
  const CustomRefreshView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.onRefresh,
    this.onLoad,
    this.padding = EdgeInsetsDirectional.zero,
    this.controller,
    this.physics,
    this.header,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final Future<void> Function()? onRefresh;
  final Future<void> Function()? onLoad;
  final EdgeInsetsGeometry padding;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final Header? header;

  @override
  Widget build(BuildContext context) {
    return EasyRefresh(
      onRefresh: onRefresh,
      onLoad: onLoad,
      header: _buildHeader(),
      child: ListView.builder(
        controller: controller,
        physics: physics ?? const AlwaysScrollableScrollPhysics(),
        padding: padding,
        itemCount: itemCount,
        itemBuilder: itemBuilder,
      ),
    );
  }

  Header _buildHeader() {
    return header ??
        BuilderHeader(
          triggerOffset: 70,
          clamping: false,
          position: IndicatorPosition.above,
          builder: (ctx, state) {
            if (state.mode == IndicatorMode.inactive && state.offset <= 0) {
              return const SizedBox.shrink();
            }
            return _ClassicLikeHeaderView(state: state);
          },
        );
  }
}

class _ClassicLikeHeaderView extends StatefulWidget {
  const _ClassicLikeHeaderView({required this.state});

  final IndicatorState state;

  @override
  State<_ClassicLikeHeaderView> createState() => _ClassicLikeHeaderViewState();
}

class _ClassicLikeHeaderViewState extends State<_ClassicLikeHeaderView>
    with TickerProviderStateMixin<_ClassicLikeHeaderView> {
  static const double _progressIndicatorSize = 20;
  static const double _progressIndicatorStrokeWidth = 2;

  late final AnimationController _iconAnimationController;
  late final GlobalKey _iconAnimatedSwitcherKey;
  late DateTime _updateTime;

  IndicatorState get _state => widget.state;
  IndicatorMode get _mode => _state.mode;
  IndicatorResult get _result => _state.result;
  Axis get _axis => _state.axis;
  bool get _reverse => _state.reverse;
  double get _offset => _state.offset;
  double get _actualTriggerOffset => _state.actualTriggerOffset;
  double get _triggerOffset => _state.triggerOffset;
  double get _safeOffset => _state.safeOffset;

  @override
  void initState() {
    super.initState();
    _iconAnimatedSwitcherKey = GlobalKey();
    _updateTime = DateTime.now();
    _iconAnimationController = AnimationController(value: 0, vsync: this, duration: const Duration(milliseconds: 200))
      ..addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(covariant _ClassicLikeHeaderView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_mode == IndicatorMode.processed && oldWidget.state.mode != IndicatorMode.processed) {
      _updateTime = DateTime.now();
    }
    if (_mode == IndicatorMode.armed && oldWidget.state.mode == IndicatorMode.drag) {
      _iconAnimationController.animateTo(1, duration: const Duration(milliseconds: 200));
    } else if (_mode == IndicatorMode.drag && oldWidget.state.mode == IndicatorMode.armed) {
      _iconAnimationController.animateBack(0, duration: const Duration(milliseconds: 200));
    } else if (_mode == IndicatorMode.processing && oldWidget.state.mode != IndicatorMode.processing) {
      _iconAnimationController.reset();
    }
  }

  @override
  void dispose() {
    _iconAnimationController.dispose();
    super.dispose();
  }

  String get _currentText {
    if (_result == IndicatorResult.noMore) {
      return 'No more';
    }
    switch (_mode) {
      case IndicatorMode.drag:
        return '1 Pull to refresh';
      case IndicatorMode.armed:
        return '2 Release ready';
      case IndicatorMode.ready:
      case IndicatorMode.processing:
        return '3 Refreshing...';
      case IndicatorMode.processed:
      case IndicatorMode.done:
        return _result == IndicatorResult.fail ? 'Failed' : 'Succeeded';
      default:
        return 'Pull to refresh';
    }
  }

  String get _messageText {
    const template = 'Last updated at %T';
    final fill = _updateTime.minute < 10 ? '0' : '';
    return template.replaceAll('%T', '${_updateTime.hour}:$fill${_updateTime.minute}');
  }

  Widget _buildIcon() {
    final iconTheme = Theme.of(context).iconTheme;
    Widget icon;
    ValueKey iconKey;
    if (_result == IndicatorResult.noMore) {
      iconKey = const ValueKey(IndicatorResult.noMore);
      icon = const Icon(Icons.inbox_outlined);
    } else if (_mode == IndicatorMode.processing || _mode == IndicatorMode.ready) {
      iconKey = const ValueKey(IndicatorMode.processing);
      icon = SizedBox(
        width: _progressIndicatorSize,
        height: _progressIndicatorSize,
        child: CircularProgressIndicator(strokeWidth: _progressIndicatorStrokeWidth, color: iconTheme.color),
      );
    } else if (_mode == IndicatorMode.processed || _mode == IndicatorMode.done) {
      if (_result == IndicatorResult.fail) {
        iconKey = const ValueKey(IndicatorResult.fail);
        icon = const Icon(Icons.error_outline);
      } else {
        iconKey = const ValueKey(IndicatorResult.success);
        icon = Transform.rotate(angle: _axis == Axis.vertical ? 0 : -math.pi / 2, child: const Icon(Icons.done));
      }
    } else {
      final textDirection = Directionality.of(context);
      final isRtl = textDirection == TextDirection.rtl;
      iconKey = const ValueKey(IndicatorMode.drag);
      final IconData horizontalForward = isRtl ? Icons.arrow_back : Icons.arrow_forward;
      final IconData horizontalBack = isRtl ? Icons.arrow_forward : Icons.arrow_back;
      icon = Transform.rotate(
        angle: -math.pi * _iconAnimationController.value,
        child: Icon(
          _reverse
              ? (_axis == Axis.vertical ? Icons.arrow_upward : horizontalBack)
              : (_axis == Axis.vertical ? Icons.arrow_downward : horizontalForward),
        ),
      );
    }
    return AnimatedSwitcher(
      key: _iconAnimatedSwitcherKey,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: ScaleTransition(scale: animation, child: child));
      },
      child: IconTheme(key: iconKey, data: iconTheme, child: icon),
    );
  }

  Widget _buildText() {
    return Text(_currentText, style: Theme.of(context).textTheme.titleMedium);
  }

  Widget _buildMessage() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 4),
      child: Text(_messageText, style: Theme.of(context).textTheme.bodySmall),
    );
  }

  Widget _buildVerticalBody() {
    return Container(
      alignment: Alignment.center,
      height: _triggerOffset,
      child: Row(
        textDirection: Directionality.of(context),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 24, child: Center(child: _buildIcon())),
          Container(
            margin: const EdgeInsetsDirectional.only(start: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_buildText(), _buildMessage()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalBody() {
    return Container(
      alignment: Alignment.center,
      width: _triggerOffset,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsetsDirectional.only(bottom: 16),
            child: RotatedBox(
              quarterTurns: -1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [_buildText(), _buildMessage()],
              ),
            ),
          ),
          SizedBox(height: 24, child: Center(child: _buildIcon())),
        ],
      ),
    );
  }

  Widget _buildVerticalWidget() {
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        PositionedDirectional(
          top:
              _offset < _actualTriggerOffset
                  ? -(_actualTriggerOffset - _offset + (_reverse ? _safeOffset : -_safeOffset)) / 2
                  : (!_reverse ? _safeOffset : 0),
          bottom: _offset < _actualTriggerOffset ? null : (_reverse ? _safeOffset : 0),
          start: 0,
          end: 0,
          height: _offset < _actualTriggerOffset ? _actualTriggerOffset : null,
          child: Center(child: _buildVerticalBody()),
        ),
      ],
    );
  }

  Widget _buildHorizontalWidget() {
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        PositionedDirectional(
          start:
              _offset < _actualTriggerOffset
                  ? -(_actualTriggerOffset - _offset + (_reverse ? _safeOffset : -_safeOffset)) / 2
                  : (!_reverse ? _safeOffset : 0),
          end: _offset < _actualTriggerOffset ? null : (_reverse ? _safeOffset : 0),
          top: 0,
          bottom: 0,
          width: _offset < _actualTriggerOffset ? _actualTriggerOffset : null,
          child: Center(child: _buildHorizontalBody()),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayOffset = _offset < 0 ? 0.0 : _offset;
    return Container(
      width: _axis == Axis.vertical ? double.infinity : displayOffset,
      height: _axis == Axis.horizontal ? double.infinity : displayOffset,
      child: _axis == Axis.vertical ? _buildVerticalWidget() : _buildHorizontalWidget(),
    );
  }
}
