import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Utility untuk jaga frame rate stabil.
class PerformanceGuard {
  static Duration _lastFrame = Duration.zero;
  static int _droppedCount = 0;

  /// Bungkus root widget; attach callback frame timing.
  static void install() {
    SchedulerBinding.instance.addTimingsCallback((timings) {
      for (final t in timings) {
        final total = t.totalSpan;
        if (total > const Duration(milliseconds: 20)) {
          _droppedCount++;
          if (_droppedCount % 20 == 0) {
            debugPrint('[PerfGuard] dropped frame: ${total.inMilliseconds}ms '
                '(total drops: $_droppedCount)');
          }
        }
        _lastFrame = total;
      }
    });
  }

  /// Bungkus widget berat (list, glass card) agar tidak repaint bersama.
  static Widget repaintIsolated(Widget child) =>
      RepaintBoundary(child: child);

  /// Throttle helper: panggil aksi max N kali per detik.
  static Duration throttle({int perSecond = 30}) =>
      Duration(milliseconds: (1000 / perSecond).round());
}