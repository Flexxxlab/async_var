import 'package:flutter/foundation.dart';

class AsyncVar<T> extends ChangeNotifier {
  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  T? _data;
  T? get data => _data;

  final Future<T> Function() operation;
  final ChangeNotifier parentNotifier;

  AsyncVar({
    required this.operation,
    required this.parentNotifier,
  }) {
    addListener(parentNotifier.notifyListeners);
  }

  Future<void> doIt() async {
    _loading = true;
    notifyListeners();
    try {
      final result = await operation();
      _data = result;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    removeListener(parentNotifier.notifyListeners);
    super.dispose();
  }
}
