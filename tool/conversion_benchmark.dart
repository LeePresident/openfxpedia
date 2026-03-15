import 'dart:io';
import 'dart:math';

void main(List<String> args) {
  final samples = _readIntArg(args, '--samples', 100);
  final thresholdMs = _readIntArg(args, '--threshold-ms', 2000);
  final workIterations = _readIntArg(args, '--work-iterations', 500);

  final rng = Random(42);
  final timings = <int>[];

  for (var i = 0; i < samples; i++) {
    final sw = Stopwatch()..start();

    var converted = 0.0;
    for (var j = 0; j < workIterations; j++) {
      final amount = rng.nextDouble() * 10000;
      final rate = 0.5 + rng.nextDouble() * 1.5;
      converted = (amount * rate * 1000000).roundToDouble() / 1000000;
    }

    if (converted.isNaN) {
      stderr.writeln('Unexpected NaN');
      exit(2);
    }

    sw.stop();
    timings.add(sw.elapsedMicroseconds ~/ 1000);
  }

  timings.sort();
  final p95Index = ((timings.length - 1) * 0.95).floor();
  final p95 = timings[p95Index];
  final max = timings.last;
  final avg = timings.reduce((a, b) => a + b) / timings.length;

  stdout.writeln('Benchmark samples: $samples');
  stdout.writeln('Work iterations per sample: $workIterations');
  stdout.writeln('Average latency: ${avg.toStringAsFixed(2)} ms');
  stdout.writeln('p95 latency: $p95 ms');
  stdout.writeln('Max latency: $max ms');
  stdout.writeln('Threshold: $thresholdMs ms');

  if (p95 > thresholdMs) {
    stderr
        .writeln('FAIL: p95 latency $p95 ms exceeds threshold $thresholdMs ms');
    exit(1);
  }

  stdout.writeln('PASS: p95 latency is within threshold.');
}

int _readIntArg(List<String> args, String name, int defaultValue) {
  final idx = args.indexOf(name);
  if (idx == -1 || idx + 1 >= args.length) return defaultValue;
  return int.tryParse(args[idx + 1]) ?? defaultValue;
}
