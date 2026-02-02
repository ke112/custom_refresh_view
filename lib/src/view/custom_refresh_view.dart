import 'package:custom_refresh_view/src/controller/refresh_controller.dart';
import 'package:custom_refresh_view/src/widget/default_footer_widget.dart';
import 'package:custom_refresh_view/src/widget/default_header_widget.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';

/// Builder for wrapping the default refresh view based on state
/// 根据刷新状态包裹默认视图的构建器
typedef RefreshStateViewBuilder = Widget Function(BuildContext context, RefreshViewState state, Widget defaultView);

/// Builder for providing custom content for loading/error/empty states
/// 为 loading / error / empty 状态提供自定义内容的构建器
typedef RefreshStateContentBuilder = Widget Function(BuildContext context, RefreshViewState state);

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
    this.stateBuilder,
    this.stateContentBuilder,
  });

  /// Refresh controller
  /// 刷新控制器
  final RefreshController? refreshController;

  /// Number of list items
  /// 列表项数量
  final int itemCount;

  /// List item builder
  /// 列表项构建器
  final IndexedWidgetBuilder itemBuilder;

  /// Pull-to-refresh callback
  /// 下拉刷新回调
  final Future<void> Function()? onRefresh;

  /// Load-more callback
  /// 上拉加载回调
  final Future<void> Function()? onLoad;

  /// Inner padding of the list
  /// 列表内边距
  final EdgeInsetsGeometry padding;

  /// Scroll controller for the list
  /// 列表滚动控制器
  final ScrollController? controller;

  /// Scroll physics for the list
  /// 列表滚动物理属性
  final ScrollPhysics? physics;

  /// Header indicator
  /// 头部刷新指示器
  final Header? header;

  /// Footer indicator
  /// 尾部加载指示器
  final Footer? footer;

  /// Override view based on loading state
  /// 根据加载状态重写整体视图
  final RefreshStateViewBuilder? stateBuilder;

  /// Override default content for loading/error/empty states
  /// 重写 loading / error / empty 状态下的默认内容
  final RefreshStateContentBuilder? stateContentBuilder;

  @override
  Widget build(BuildContext context) {
    final refreshStateController = refreshController;

    // Attach scroll controller for programmatic control
    // 绑定滚动控制器，用于程序化滚动与刷新
    refreshStateController?.attachScrollController(controller);

    // No refresh controller: always render success view
    // 未提供刷新控制器时，始终渲染成功态视图
    if (refreshStateController == null) {
      return _buildRefreshView(context, RefreshViewState.success);
    }

    // Rebuild when refresh state changes
    // 当刷新状态变化时自动重建
    return AnimatedBuilder(
      animation: refreshStateController,
      builder: (context, _) {
        return _buildRefreshView(context, refreshStateController.state);
      },
    );
  }

  /// Build EasyRefresh wrapper based on current state
  /// 根据当前状态构建 EasyRefresh 容器
  Widget _buildRefreshView(BuildContext context, RefreshViewState state) {
    final effectiveOnLoad =
        onLoad == null
            ? null
            : () async {
              final controller = refreshController;

              // Prepare load task
              // 开始加载任务前的准备
              controller?.beginLoadTask();

              try {
                await onLoad?.call();
              } catch (_) {
                // Explicitly mark load as failed
                // 显式标记加载失败
                controller?.finishLoadFail();
                rethrow;
              } finally {
                // Finish load if not explicitly handled
                // 如果未显式处理结果，则自动结束加载
                controller?.finishLoadIfNeeded();
              }
            };

    final resolvedState = _resolveViewState(state);

    return EasyRefresh.builder(
      onRefresh: onRefresh,
      onLoad: effectiveOnLoad,
      controller: refreshController?.easyController,
      header: _resolveHeader(),
      footer: _resolveFooter(),
      scrollController: controller,
      childBuilder: (context, refreshPhysics) {
        final listPhysics =
            physics != null
                ? physics!.applyTo(refreshPhysics)
                : const AlwaysScrollableScrollPhysics().applyTo(refreshPhysics);

        final defaultView =
            resolvedState == RefreshViewState.success
                ? _buildSuccessView(context, listPhysics)
                : _buildStateView(context, listPhysics, resolvedState);

        // Allow external override of the whole view
        // 允许外部基于状态整体替换视图
        return stateBuilder?.call(context, resolvedState, defaultView) ?? defaultView;
      },
    );
  }

  /// Resolve view state based on itemCount
  /// 根据 itemCount 解析视图状态（空态由控制器显式设置时优先）
  RefreshViewState _resolveViewState(RefreshViewState state) {
    if (state == RefreshViewState.success && itemCount == 0) {
      return RefreshViewState.empty;
    }
    return state;
  }

  /// Build list view for success state
  /// 构建成功状态下的列表视图
  Widget _buildSuccessView(BuildContext context, ScrollPhysics listPhysics) {
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
  }

  /// Build view for loading / error / empty states
  /// 构建 loading / error / empty 状态下的视图
  Widget _buildStateView(BuildContext context, ScrollPhysics listPhysics, RefreshViewState state) {
    final hasHeader = onRefresh != null;
    final hasFooter = onLoad != null;

    return CustomScrollView(
      controller: controller,
      physics: listPhysics,
      slivers: [
        if (hasHeader) const SliverToBoxAdapter(child: HeaderLocator()),
        SliverPadding(
          padding: padding,
          sliver: SliverFillRemaining(hasScrollBody: false, child: _buildDefaultStateContent(context, state)),
        ),
        if (hasFooter) const SliverToBoxAdapter(child: FooterLocator()),
      ],
    );
  }

  /// Build default content for non-success states
  /// 构建非成功状态下的默认内容
  Widget _buildDefaultStateContent(BuildContext context, RefreshViewState state) {
    final textStyle = Theme.of(context).textTheme.bodyMedium;

    // Allow overriding state content
    // 允许外部重写状态内容
    final override = stateContentBuilder?.call(context, state);
    if (override != null) {
      return override;
    }

    switch (state) {
      case RefreshViewState.loading:
        return const Center(child: CircularProgressIndicator());
      case RefreshViewState.error:
        return Center(child: Text('Load failed', style: textStyle));
      case RefreshViewState.empty:
        return Center(child: Text('No data', style: textStyle));
      case RefreshViewState.success:
        return const SizedBox.shrink();
    }
  }

  /// Resolve header configuration
  /// 解析并统一 Header 配置
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
  /// 解析并统一 Footer 配置
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
