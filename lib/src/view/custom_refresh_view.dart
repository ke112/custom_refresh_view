import 'package:custom_refresh_view/src/controller/refresh_controller.dart';
import 'package:custom_refresh_view/src/widget/default_footer_widget.dart';
import 'package:custom_refresh_view/src/widget/default_header_widget.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';

class CustomRefreshView extends StatelessWidget {
  const CustomRefreshView({
    super.key,
    this.refreshController,
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

  /// Refresh controller
  final RefreshController? refreshController;

  /// Number of list items
  final int itemCount;

  /// List item builder
  final IndexedWidgetBuilder itemBuilder;

  /// Pull-to-refresh callback
  final Future<void> Function()? onRefresh;

  /// Load-more callback
  final Future<void> Function()? onLoad;

  /// Inner padding of the list
  final EdgeInsetsGeometry padding;

  /// Scroll controller for the list
  final ScrollController? controller;

  /// Scroll physics for the list
  final ScrollPhysics? physics;

  /// Header indicator
  final Header? header;

  /// Footer indicator
  final Footer? footer;

  @override
  Widget build(BuildContext context) {
    return EasyRefresh.builder(
      onRefresh: onRefresh,
      onLoad: onLoad,
      header: _resolveHeader(),
      footer: _resolveFooter(),
      scrollController: controller,
      childBuilder: (context, refreshPhysics) {
        final listPhysics =
            physics != null
                ? physics!.applyTo(refreshPhysics)
                : const AlwaysScrollableScrollPhysics().applyTo(refreshPhysics);

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

  /// Resolve header configuration
  Header _resolveHeader() {
    final base =
        header ??
        buildDefaultHeader(
          triggerOffset: refreshController?.triggerOffset ?? 70,
          minHeaderExtent: refreshController?.minHeaderExtent ?? 30,
          position: IndicatorPosition.locator,
        );

    if (base.position == IndicatorPosition.locator) {
      return base;
    }

    return OverrideHeader(header: base, position: IndicatorPosition.locator);
  }

  /// Resolve footer configuration
  Footer _resolveFooter() {
    final base =
        footer ??
        buildDefaultFooter(triggerOffset: refreshController?.triggerOffset ?? 70, position: IndicatorPosition.locator);

    if (base.position == IndicatorPosition.locator) {
      return base;
    }

    return OverrideFooter(footer: base, position: IndicatorPosition.locator);
  }
}
