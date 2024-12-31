import 'package:flutter/foundation.dart';
import 'package:async/async.dart';

/// A class that manages asynchronous operations and notifies listeners about
/// the loading state, data, and errors.
/// Operations can be cancelled using the [cancelOperation] method.
class AsyncVar<T> extends ChangeNotifier {
  final ChangeNotifier _parentNotifier;
  bool _loading = false;
  String? _error;
  T? _data;
  CancelableOperation? _operation;

  /// Indicates whether the asynchronous operation is currently loading.
  bool get loading => _loading;

  /// Stores any error message that occurs during the asynchronous operation.
  String? get error => _error;

  /// Stores the result of the asynchronous operation.
  T? get data => _data;

  /// Creates an instance of [AsyncVar] with the given [operation] and [parentNotifier].
  /// A parent notifier to notify when this notifier changes.
  AsyncVar({
    required ChangeNotifier parentNotifier,
  }) : _parentNotifier = parentNotifier {
    addListener(_parentNotifier.notifyListeners);
  }

  /// Executes the asynchronous operation, updates the loading state, and
  /// notifies listeners about the result or any error.
  /// Parameters: [operation] - The asynchronous operation to execute.
  /// Returns the error message if any.
  Future<String?> executeTask(Future<T> Function() operation) async {
    _loading = true;
    notifyListeners();

    _operation = CancelableOperation<T>.fromFuture(
      operation(),
      onCancel: () {
        _loading = false;
        notifyListeners();
      },
    );

    try {
      final result = await _operation?.value;
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
    removeListener(_parentNotifier.notifyListeners);
    super.dispose();
  }

  /// Cancels the current asynchronous operation.
  void cancelOperation() {
    _operation?.cancel();
  }
}
