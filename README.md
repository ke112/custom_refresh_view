# custom_refresh_view

A Flutter refresh list widget with pull-to-refresh and load-more callbacks.

一个轻量的 Flutter 刷新列表组件，提供下拉刷新与上拉加载回调。

## Features

- ✅ Pull-to-refresh + load-more callbacks
- ✅ Simple API with `itemCount` + `itemBuilder`
- ✅ LTR/RTL layout support
- ✅ EasyRefresh 기반，稳定可靠

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  custom_refresh_view: ^0.0.1
```

Then run:

```bash
flutter pub get
```

## Usage

```dart
import 'package:custom_refresh_view/custom_refresh_view.dart';

CustomRefreshView(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(title: Text(items[index]));
  },
  onRefresh: () async {
    await fetchNewData();
  },
  onLoad: () async {
    await fetchMoreData();
  },
);
```

## API Reference

### CustomRefreshView

| Property     | Type                        | Default | Description                          |
| ------------ | --------------------------- | ------- | ------------------------------------ |
| `itemCount`  | `int`                       | required | Data count for list items            |
| `itemBuilder`| `IndexedWidgetBuilder`      | required | Builder for list item widgets        |
| `onRefresh`  | `Future<void> Function()?`  | `null`  | Pull-to-refresh callback             |
| `onLoad`     | `Future<void> Function()?`  | `null`  | Load-more callback                   |
| `padding`    | `EdgeInsetsGeometry`        | `EdgeInsetsDirectional.zero` | List padding |
| `controller` | `ScrollController?`         | `null`  | Optional list scroll controller      |
| `physics`    | `ScrollPhysics?`            | `null`  | Optional list scroll physics         |

## LTR / RTL Support

All internal padding uses directional APIs (e.g. `EdgeInsetsDirectional`), and the example app provides a toggle to verify LTR/RTL layouts.

## Example

See the [example](example/) directory:

```bash
cd example
flutter run
```
