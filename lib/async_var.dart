import 'package:flutter/foundation.dart';
import 'package:async/async.dart';

import 'custom_exception.dart';

/// A class that manages asynchronous operations and notifies listeners about
/// the loading state, data, and errors.
/// Operations can be cancelled using the [cancelOperation] method.
class AsyncVar<T> extends ChangeNotifier {
  final ChangeNotifier _parentNotifier;
  bool _loading = false;
  String? _error;
  CustomException? _customException;
  T? _data;
  CancelableOperation? _operation;

  /// Indicates whether the asynchronous operation is currently loading.
  bool get loading => _loading;

  /// Stores any error message that occurs during the asynchronous operation.
  String? get error => _error;

  /// Stores the result of the asynchronous operation.
  T? get data => _data;

  /// Stores the custom exception that occurs during the asynchronous operation.
  CustomException? get customException => _customException;

  /// Creates an instance of [AsyncVar] with the given [operation] and [parentNotifier].
  /// A parent notifier to notify when this notifier changes.
  AsyncVar({required ChangeNotifier parentNotifier})
    : _parentNotifier = parentNotifier {
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
      _customException = null;
    } catch (e) {
      if (e is CustomException) {
        _customException = e;
      }
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

/// Retries a [futureFunction] up to [maxRetries] times with a 1-second delay between attempts.
/// Throws an exception if all retries fail.
Future<T> retry<T>(
  Future<T> Function() futureFunction, {
  int maxRetries = 3,
}) async {
  int attempt = 0;

  while (attempt < maxRetries) {
    try {
      return await futureFunction();
    } catch (e) {
      attempt++;
      if (attempt == maxRetries) {
        throw Exception('Failed after $maxRetries attempts: $e');
      }
      // Add a delay before retrying
      await Future.delayed(Duration(seconds: 1));
    }
  }

  throw Exception('Unexpected error: retry logic failed');
}
