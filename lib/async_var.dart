import 'package:flutter/foundation.dart';

/// A class that manages asynchronous operations and notifies listeners about
/// the loading state, data, and errors.
class AsyncVar<T> extends ChangeNotifier {
  bool _loading = false;

  /// Indicates whether the asynchronous operation is currently loading.
  bool get loading => _loading;

  String? _error;

  /// Stores any error message that occurs during the asynchronous operation.
  String? get error => _error;

  T? _data;

  /// Stores the result of the asynchronous operation.
  T? get data => _data;

  /// A parent notifier to notify when this notifier changes.
  final ChangeNotifier parentNotifier;

  /// Creates an instance of [AsyncVar] with the given [operation] and [parentNotifier].
  AsyncVar({
    required this.parentNotifier,
  }) {
    addListener(parentNotifier.notifyListeners);
  }

  /// Executes the asynchronous operation, updates the loading state, and
  /// notifies listeners about the result or any error.
  /// Parameters: [operation] - The asynchronous operation to execute.
  /// Returns the error message if any.
  Future<String?> executeTask(Future<T> Function() operation) async {
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
    return _error;
  }

  /// Disposes the notifier and removes the listener from the parent notifier.
  @override
  void dispose() {
    removeListener(parentNotifier.notifyListeners);
    super.dispose();
  }
}
