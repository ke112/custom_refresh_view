import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';

/// Refresh view state
/// 刷新视图状态
enum RefreshViewState {
  loading, // Loading state | 加载中
  success, // Success state | 加载成功
  error, // Error state | 加载失败
  empty, // Empty state | 空数据
}

class RefreshController extends ChangeNotifier {
  RefreshController({
    this.minHeaderExtent = 30,
    this.triggerOffset = 70,
    RefreshViewState initialState = RefreshViewState.loading,
  }) : _state = initialState,
       _easyController = EasyRefreshController(controlFinishLoad: true);

  /// Minimum height of the header
  /// 头部最小高度
  double minHeaderExtent;

  /// Trigger offset for refresh/load
  /// 触发刷新 / 加载的偏移量
  double triggerOffset;

  /// EasyRefresh internal controller
  /// EasyRefresh 内部控制器
  final EasyRefreshController _easyController;

  /// Attached scroll controller for list
  /// 绑定的列表滚动控制器
  ScrollController? _scrollController;

  /// Whether no more data is available
  /// 是否已经没有更多数据
  bool _noMore = false;

  /// Whether load result has been explicitly set
  /// 是否已经显式设置过加载结果
  bool _loadResultSet = false;

  /// Current refresh view state
  /// 当前刷新视图状态
  RefreshViewState _state;

  /// Current loading state
  /// 当前加载状态
  RefreshViewState get state => _state;

  /// EasyRefresh controller
  /// EasyRefresh 控制器
  EasyRefreshController get easyController => _easyController;

  /// Whether load has no more data
  /// 是否没有更多数据
  bool get noMore => _noMore;

  /// Update loading state and notify listeners
  /// 更新加载状态并通知监听者
  void setState(RefreshViewState state) {
    if (_state == state) {
      return;
    }
    _state = state;
    notifyListeners();
  }

  /// Attach list scroll controller for programmatic control
  /// 绑定列表 ScrollController，用于程序化滚动控制
  void attachScrollController(ScrollController? controller) {
    _scrollController = controller;
  }

  /// Mark load as no more data
  /// 标记加载为“没有更多数据”
  void markNoMore({bool force = false}) {
    _noMore = true;
    _loadResultSet = true;
    _easyController.finishLoad(IndicatorResult.noMore, force);
  }

  /// Reset no-more state to allow loading again
  /// 重置“没有更多数据”状态，允许再次加载
  void resetNoMore() {
    _noMore = false;
    _easyController.resetFooter();
  }

  /// Mark load as success
  /// 标记加载成功
  void finishLoadSuccess({bool force = false}) {
    _noMore = false;
    _loadResultSet = true;
    _easyController.finishLoad(IndicatorResult.success, force);
  }

  /// Mark load as fail
  /// 标记加载失败
  void finishLoadFail({bool force = false}) {
    _loadResultSet = true;
    _easyController.finishLoad(IndicatorResult.fail, force);
  }

  /// Prepare for a new load task
  /// 开始一次新的加载任务前的准备
  void beginLoadTask() {
    _loadResultSet = false;
  }

  /// Finish load task if no explicit result was set
  /// 如果未显式设置加载结果，则自动结束加载
  void finishLoadIfNeeded() {
    if (_loadResultSet) {
      return;
    }

    if (_noMore) {
      _easyController.finishLoad(IndicatorResult.noMore);
      _loadResultSet = true;
      return;
    }

    _easyController.finishLoad(IndicatorResult.success);
    _loadResultSet = true;
  }

  /// Scroll to the start offset
  /// 滚动到列表起始位置
  Future<void> scrollToStart({
    Duration duration = const Duration(milliseconds: 200),
    Curve curve = Curves.linear,
    bool jump = false,
  }) async {
    final controller = _scrollController;
    if (controller == null || !controller.hasClients) {
      return;
    }

    if (jump) {
      controller.jumpTo(0);
      return;
    }

    await controller.animateTo(0, duration: duration, curve: curve);
  }

  /// Trigger refresh programmatically
  /// 以编程方式触发刷新
  Future<void> callRefresh({
    Duration duration = const Duration(milliseconds: 200),
    Curve curve = Curves.linear,
    bool force = false,
  }) {
    return _easyController.callRefresh(
      duration: duration,
      curve: curve,
      scrollController: _scrollController,
      force: force,
    );
  }

  /// Scroll to start and trigger refresh
  /// 滚动到顶部并触发刷新
  Future<void> scrollToStartAndRefresh({
    Duration duration = const Duration(milliseconds: 200),
    Curve curve = Curves.linear,
    bool force = false,
    bool jump = false,
  }) async {
    await scrollToStart(duration: duration, curve: curve, jump: jump);
    // Reset header state first to clear any pending state from previous refresh
    // 先重置 Header 状态，清除上次刷新可能残留的状态
    _easyController.resetHeader();
    // Wait for the reset to take effect in the next frame
    // 等待重置在下一帧生效
    await WidgetsBinding.instance.endOfFrame;
    await callRefresh(duration: duration, curve: curve, force: force);
  }

  @override
  void dispose() {
    _easyController.dispose();
    super.dispose();
  }
}
