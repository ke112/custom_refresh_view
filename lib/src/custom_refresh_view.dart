import 'package:custom_refresh_view/src/widget/default_footer_widget.dart';
import 'package:custom_refresh_view/src/widget/default_header_widget.dart';
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
  static const double _triggerOffset = 70;

  @override
  Widget build(BuildContext context) {
    final resolvedHeader = _resolveHeader();
    final resolvedFooter = _resolveFooter();
    return EasyRefresh.builder(
      onRefresh: onRefresh,
      onLoad: onLoad,
      header: resolvedHeader,
      footer: resolvedFooter,
      scrollController: controller,
      childBuilder: (context, refreshPhysics) {
        final listPhysics = const AlwaysScrollableScrollPhysics().applyTo(refreshPhysics);
        final hasHeader = onRefresh != null;
        final hasFooter = onLoad != null;
        final extraStart = hasHeader ? 1 : 0;
        final extraEnd = hasFooter ? 1 : 0;
        final totalCount = itemCount + extraStart + extraEnd;
        return CustomScrollView(
          controller: controller,
          physics: listPhysics,
          slivers: [
            SliverPadding(
              padding: padding,
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (hasHeader && index == 0) {
                    return const HeaderLocator();
                  }
                  if (hasFooter && index == totalCount - 1) {
                    return const FooterLocator();
                  }
                  final itemIndex = index - extraStart;
                  return itemBuilder(context, itemIndex);
                }, childCount: totalCount),
              ),
            ),
          ],
        );
      },
    );
  }

  Header _resolveHeader() {
    final base =
        header ??
        buildDefaultHeader(
          triggerOffset: _triggerOffset,
          minHeaderExtent: _minHeaderExtent,
          position: IndicatorPosition.locator,
        );
    if (base.position == IndicatorPosition.locator) {
      return base;
    }
    return OverrideHeader(header: base, position: IndicatorPosition.locator);
  }

  Footer _resolveFooter() {
    final base = footer ?? buildDefaultFooter(triggerOffset: _triggerOffset, position: IndicatorPosition.locator);
    if (base.position == IndicatorPosition.locator) {
      return base;
    }
    return OverrideFooter(footer: base, position: IndicatorPosition.locator);
  }
}
