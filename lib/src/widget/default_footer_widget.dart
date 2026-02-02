import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Build default footer widget
/// 构建默认尾部组件
Footer buildDefaultFooter({required double triggerOffset, IndicatorPosition position = IndicatorPosition.above}) {
  return BuilderFooter(
    triggerOffset: triggerOffset,
    clamping: false,
    processedDuration: const Duration(milliseconds: 200),
    position: position,
    builder: (ctx, state) {
      final mode = state.mode;
      final isNoMore = state.result == IndicatorResult.noMore;
      final axis = state.axis;
      final extent = state.offset > 0 ? state.offset : 44.0;
      final crossExtent = axis == Axis.vertical ? double.infinity : extent;
      final mainExtent = axis == Axis.horizontal ? double.infinity : extent;
      final alignment = axis == Axis.vertical ? AlignmentDirectional.center : AlignmentDirectional.centerStart;

      if (isNoMore) {
        final textStyle = Theme.of(ctx).textTheme.bodyMedium ?? DefaultTextStyle.of(ctx).style;
        return SizedBox(
          width: crossExtent,
          height: mainExtent,
          child: Align(alignment: alignment, child: Text('没有更多了', style: textStyle)),
        );
      }

      final shouldShow =
          mode == IndicatorMode.processing ||
          mode == IndicatorMode.drag ||
          mode == IndicatorMode.armed ||
          mode == IndicatorMode.ready;
      if (!shouldShow || state.offset <= 0) {
        return const SizedBox.shrink();
      }
      return SizedBox(
        width: crossExtent,
        height: mainExtent,
        child: Align(alignment: alignment, child: const _LoadingMoreDots()),
      );
    },
  );
}

/// Loading more dots widget
/// 加载更多点组件
class _LoadingMoreDots extends StatefulWidget {
  const _LoadingMoreDots();

  @override
  State<_LoadingMoreDots> createState() => _LoadingMoreDotsState();
}

class _LoadingMoreDotsState extends State<_LoadingMoreDots> {
  static const Duration _interval = Duration(milliseconds: 500);
  int _dotCount = 1;
  late final Ticker _ticker;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = Ticker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final delta = elapsed - _elapsed;
    if (delta < _interval) {
      return;
    }
    _elapsed = elapsed;
    setState(() {
      _dotCount = _dotCount == 3 ? 1 : _dotCount + 1;
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium ?? DefaultTextStyle.of(context).style;
    final activeColor = textStyle.color;
    final inactiveColor = activeColor?.withValues(alpha: 0) ?? Colors.transparent;
    return Text.rich(
      TextSpan(
        text: 'Loading More ',
        children: List.generate(
          3,
          (index) => TextSpan(text: '.', style: TextStyle(color: index < _dotCount ? activeColor : inactiveColor)),
        ),
      ),
      textDirection: Directionality.of(context),
      style: textStyle,
    );
  }
}
