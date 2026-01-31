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
  List<String> items = [];

  @override
  void initState() {
    super.initState();
    _resetItems();
  }

  /// 下拉刷新
  Future<void> _handleRefresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    setState(() {
      _resetItems();
    });
  }

  /// 上拉加载
  Future<void> _handleLoad() async {
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    setState(() {
      final start = items.length;
      items.addAll(List.generate(_pageSize, (index) => 'Item ${start + index + 1}'));
    });
  }

  void _resetItems() {
    items = List.generate(_pageSize, (index) => 'Item ${index + 1}');
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = widget.textDirection == TextDirection.rtl;

    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page (${isRtl ? 'RTL' : 'LTR'})'),
        actions: [
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
            itemCount: items.length,
            onRefresh: _handleRefresh,
            onLoad: _handleLoad,
            padding: EdgeInsetsDirectional.only(bottom: 100),
            itemBuilder: (context, index) {
              return _buildItemWidget(context, index);
            },
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Container(
              height: 50,
              alignment: Alignment.center,
              margin: const EdgeInsetsDirectional.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                color: Colors.grey[600]?.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('我是底部遮挡按钮', style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
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
      padding: const EdgeInsetsDirectional.only(bottom: 12),
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
}
