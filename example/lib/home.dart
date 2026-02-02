import 'package:custom_refresh_view/custom_refresh_view.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.onToggleDirection, required this.textDirection});

  final VoidCallback onToggleDirection;
  final TextDirection textDirection;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const int _pageSize = 10;
  final RefreshController _refreshController = RefreshController();
  final ScrollController _scrollController = ScrollController();
  List<String> items = [];

  @override
  void initState() {
    super.initState();
    _resetItems();
  }

  /// 下拉刷新
  Future<void> _handleRefresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    setState(() {
      _resetItems();
      // _clearItems();
    });
    _refreshController.resetNoMore();
    _refreshController.setState(RefreshViewState.success);
  }

  /// 上拉加载
  Future<void> _handleLoad() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    setState(() {
      final start = items.length;
      items.addAll(List.generate(_pageSize, (index) => 'Item ${start + index + 1}'));
    });
    if (items.length >= 20) {
      _refreshController.markNoMore();
    }
  }

  void _clearItems() {
    setState(() {
      items = [];
    });
    _refreshController.setState(RefreshViewState.empty);
  }

  void _resetItems() async {
    items = List.generate(_pageSize, (index) => 'Item ${index + 1}');
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _refreshController.setState(RefreshViewState.success);
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = widget.textDirection == TextDirection.rtl;

    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page (${isRtl ? 'RTL' : 'LTR'})'),
        actions: [
          IconButton(
            tooltip: 'Scroll to top & refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _refreshController.scrollToStartAndRefresh,
          ),
          IconButton(
            tooltip: isRtl ? 'Switch to LTR' : 'Switch to RTL',
            icon: Icon(isRtl ? Icons.format_textdirection_l_to_r : Icons.format_textdirection_r_to_l),
            onPressed: widget.onToggleDirection,
          ),
        ],
      ),
      body: Stack(
        children: [
          CustomRefreshView(
            refreshController: _refreshController,
            itemCount: items.length,
            onRefresh: _handleRefresh,
            onLoad: _handleLoad,
            padding: EdgeInsetsDirectional.only(bottom: 100),
            itemBuilder: (context, index) {
              return _buildItemWidget(context, index);
            },
            stateContentBuilder: (context, state) {
              return Text('state: $state');
            },
            stateBuilder: (context, state, defaultView) {
              if (state == RefreshViewState.loading) {
                return const Center(child: CircularProgressIndicator(color: Colors.green));
              }
              if (state == RefreshViewState.error) {
                return const Center(child: Text('Error'));
              }
              if (state == RefreshViewState.empty) {
                return const Center(child: Text('Empty'));
              }
              return defaultView;
            },
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                _clearItems();
              },
              child: Container(
                height: 50,
                alignment: Alignment.center,
                margin: const EdgeInsetsDirectional.symmetric(horizontal: 40),
                decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(12)),
                child: Text(
                  '我是底部遮挡按钮',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemWidget(BuildContext context, int index) {
    String now = DateTime.now().toIso8601String().substring(0, 19);
    now = now.replaceAll('T', ' ');
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 12, start: 12, end: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadiusDirectional.all(Radius.circular(12)),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: ListTile(title: Text(items[index]), subtitle: Text('Index ${index + 1}   $now')),
      ),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
