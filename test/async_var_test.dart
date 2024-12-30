import 'package:async_var/async_var.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';

void main() {
  group('AsyncVar', () {
    late AsyncVar<int> asyncVar;
    late int mockResult;
    late String mockError;
    late bool listenerCalled;

    setUp(() {
      mockResult = 42;
      mockError = 'Something went wrong';
      listenerCalled = false;
    });

    test('initial state is correct', () {
      asyncVar = AsyncVar<int>(
        parentNotifier: ChangeNotifier(),
      );

      expect(asyncVar.loading, isFalse);
      expect(asyncVar.data, isNull);
      expect(asyncVar.error, isNull);
    });

    test('doIt updates loading state correctly', () async {
      asyncVar = AsyncVar<int>(
        parentNotifier: ChangeNotifier(),
      );

      // Check initial state
      expect(asyncVar.loading, isFalse);

      // Call doIt and check loading state
      final error = asyncVar.executeTask(() async {
        await Future.delayed(Duration(milliseconds: 100));
        return mockResult;
      });
      expect(asyncVar.loading, isTrue);

      // Wait for completion and check final state
      await Future.delayed(Duration(milliseconds: 150));
      expect(asyncVar.loading, isFalse);
      expect(asyncVar.data, mockResult);
      expect(asyncVar.error, isNull);
      expect(await error, isNull);
    });

    test('doIt handles errors correctly', () async {
      asyncVar = AsyncVar<int>(
        parentNotifier: ChangeNotifier(),
      );

      // Call doIt and check loading state
      final error = asyncVar.executeTask(() async {
        throw Exception(mockError);
      });
      expect(asyncVar.loading, isTrue);

      // Wait for completion and check final state
      await Future.delayed(Duration(milliseconds: 100));
      expect(asyncVar.loading, isFalse);
      expect(asyncVar.data, isNull);
      expect(asyncVar.error, contains(mockError));
      expect(await error, contains(mockError));
    });

    test('notifies listeners on state changes', () async {
      asyncVar = AsyncVar<int>(
        parentNotifier: ChangeNotifier(),
      );

      // Attach a listener
      asyncVar.addListener(() {
        listenerCalled = true;
      });

      // Call doIt and verify listener is called
      asyncVar.executeTask(() async => mockResult);
      await Future.delayed(Duration(milliseconds: 150));

      expect(listenerCalled, isTrue);
    });

    test('removes listeners correctly', () {
      asyncVar = AsyncVar<int>(
        parentNotifier: ChangeNotifier(),
      );

      // Attach and remove a listener
      listener() {
        listenerCalled = true;
      }

      asyncVar.addListener(listener);
      asyncVar.removeListener(listener);

      // Call doIt and verify listener is not called
      asyncVar.executeTask(() async => mockResult);
      expect(listenerCalled, isFalse);
    });
  });
}
