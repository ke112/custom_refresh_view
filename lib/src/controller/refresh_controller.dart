import 'package:flutter/material.dart';

enum LoadingStateEnum { loading, success, error, empty }

class RefreshController extends ChangeNotifier {
  /// Minimum height of the header
  double minHeaderExtent = 30;

  /// Trigger offset for refresh/load
  double triggerOffset = 70;
}
