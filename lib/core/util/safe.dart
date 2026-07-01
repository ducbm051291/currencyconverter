import 'dart:async';

import 'package:flutter/foundation.dart';

class Safe {
  final String? tag;

  const Safe([this.tag]);

  T? run<T>(
    T Function() action, {
    bool isLog = true,
    String? errorMessage,
    T? Function(Object error, StackTrace stackTrace)? onError,
    void Function()? onFinally,
  }) {
    try {
      return action();
    } catch (error, stackTrace) {
      _handleError(error, stackTrace, isLog: isLog, errorMessage: errorMessage);
      return onError?.call(error, stackTrace);
    } finally {
      onFinally?.call();
    }
  }

  Future<T?> runAsync<T>(
    Future<T> Function() action, {
    bool isLog = true,
    String? errorMessage,
    FutureOr<T?> Function(Object error, StackTrace stackTrace)? onError,
    FutureOr<void> Function()? onFinally,
  }) async {
    try {
      return await action();
    } catch (error, stackTrace) {
      _handleError(error, stackTrace, isLog: isLog, errorMessage: errorMessage);
      return await onError?.call(error, stackTrace);
    } finally {
      await onFinally?.call();
    }
  }

  void _handleError(
    Object error,
    StackTrace stackTrace, {
    required bool isLog,
    String? errorMessage,
  }) {
    if (!isLog) {
      return;
    }
    final message = tag != null && tag!.isNotEmpty
        ? '[$tag] ${errorMessage ?? error}'
        : errorMessage ?? error.toString();
    debugPrint('$message\n$stackTrace');
  }
}
