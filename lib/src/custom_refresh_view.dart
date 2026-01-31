import 'package:custom_refresh_view/src/widget/default_footer_widget.dart';
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
    this.footer,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final Future<void> Function()? onRefresh;
  final Future<void> Function()? onLoad;
  final EdgeInsetsGeometry padding;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final Header? header;
  final Footer? footer;
  static const double _minHeaderExtent = 30;

  @override
  Widget build(BuildContext context) {
    return EasyRefresh(
      onRefresh: onRefresh,
      onLoad: onLoad,
      header: _buildHeader(),
      footer: footer ?? buildDefaultFooter(),
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
            if (state.mode == IndicatorMode.inactive || state.offset <= _minHeaderExtent) {
              return const SizedBox.shrink();
            }
            final axis = state.axis;
            final crossExtent = axis == Axis.vertical ? double.infinity : state.offset;
            final mainExtent = axis == Axis.horizontal ? double.infinity : state.offset;
            final alignment = axis == Axis.vertical ? AlignmentDirectional.center : AlignmentDirectional.centerStart;
            return SizedBox(
              width: crossExtent,
              height: mainExtent,
              child: Align(
                alignment: alignment,
                child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
              ),
            );
          },
        );
  }
}
