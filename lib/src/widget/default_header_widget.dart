import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';

/// Build default header widget
/// 构建默认头部组件
Header buildDefaultHeader({
  required double triggerOffset,
  required double minHeaderExtent,
  IndicatorPosition position = IndicatorPosition.above,
}) {
  return BuilderHeader(
    triggerOffset: triggerOffset,
    clamping: false,
    processedDuration: const Duration(milliseconds: 200),
    position: position,
    builder: (ctx, state) {
      if (state.mode == IndicatorMode.inactive || state.offset <= minHeaderExtent) {
        return const SizedBox.shrink();
      }
      final axis = state.axis;
      final crossExtent = axis == Axis.vertical ? double.infinity : state.offset;
      final mainExtent = axis == Axis.horizontal ? double.infinity : state.offset;
      final alignment = axis == Axis.vertical ? AlignmentDirectional.center : AlignmentDirectional.centerStart;
      final child = SizedBox(
        width: crossExtent,
        height: mainExtent,
        child: Align(alignment: alignment, child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.red)),
      );
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        reverseDuration: const Duration(milliseconds: 100),
        child: child,
      );
    },
  );
}
