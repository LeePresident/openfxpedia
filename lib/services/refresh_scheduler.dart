import 'dart:async';
import 'dart:io' show Platform;
import 'dart:developer' as developer;

class RefreshScheduler {
  Timer? _timer;
  final Duration interval;
  final void Function() onRefresh;

  RefreshScheduler(
      {required this.onRefresh, this.interval = const Duration(hours: 1)});

  void start({bool initialRun = false}) {
    stop();
    if (initialRun) {
      runOnceNow();
    }

    if (Platform.isAndroid) {
      developer.log(
          'Platform is Android - integrate with Workmanager for background refreshes.',
          name: 'RefreshScheduler');
    }

    _timer = Timer.periodic(interval, (_) => onRefresh());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void scheduleImmediateRefresh() {
    Future.microtask(() => onRefresh());
  }

  void runOnceNow() => scheduleImmediateRefresh();
}
