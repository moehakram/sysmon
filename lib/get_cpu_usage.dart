import 'dart:io';

Future<String> getCpuUsage() async {
  try {
    final statFile = File('/proc/stat');
    if (!await statFile.exists()) return 'N/A';

    final lines = await statFile.readAsLines();
    if (lines.isEmpty) return 'Error';

    final cpuLine = lines.first;
    final values = cpuLine
        .split(' ')
        .where((s) => s.isNotEmpty)
        .skip(1)
        .toList();

    if (values.length < 4) return 'Error';

    final user = int.tryParse(values[0]) ?? 0;
    final nice = int.tryParse(values[1]) ?? 0;
    final system = int.tryParse(values[2]) ?? 0;
    final idle = int.tryParse(values[3]) ?? 0;
    final iowait = values.length > 4 ? (int.tryParse(values[4]) ?? 0) : 0;
    final irq = values.length > 5 ? (int.tryParse(values[5]) ?? 0) : 0;
    final softirq = values.length > 6 ? (int.tryParse(values[6]) ?? 0) : 0;

    final totalTime = user + nice + system + idle + iowait + irq + softirq;
    final idleTime = idle + iowait;

    final tempFile = File('/tmp/cpu_usage_dart.tmp');
    int prevTotal = 0;
    int prevIdle = 0;

    if (await tempFile.exists()) {
      try {
        final prevData = await tempFile.readAsString();
        final parts = prevData.trim().split(' ');
        if (parts.length == 2) {
          prevTotal = int.tryParse(parts[0]) ?? 0;
          prevIdle = int.tryParse(parts[1]) ?? 0;
        }
      } catch (e) {
        // Ignore error reading temp file, will create new baseline
      }
    }

    await tempFile.writeAsString('$totalTime $idleTime');

    if (prevTotal > 0 && totalTime > prevTotal) {
      final totalDiff = totalTime - prevTotal;
      final idleDiff = idleTime - prevIdle;

      if (totalDiff > 0) {
        final usage = ((totalDiff - idleDiff) * 100 / totalDiff).clamp(
          0.0,
          100.0,
        );
        return '${usage.toStringAsFixed(1)}%';
      }
    } else {
      // First run or invalid previous data - take two measurements
      // Using 3 seconds for more accurate and stable CPU usage calculation
      await Future.delayed(const Duration(seconds: 3));

      final lines2 = await statFile.readAsLines();
      if (lines2.isEmpty) return 'Error';

      final cpuLine2 = lines2.first;
      final values2 = cpuLine2
          .split(' ')
          .where((s) => s.isNotEmpty)
          .skip(1)
          .toList();

      if (values2.length >= 4) {
        final user2 = int.tryParse(values2[0]) ?? 0;
        final nice2 = int.tryParse(values2[1]) ?? 0;
        final system2 = int.tryParse(values2[2]) ?? 0;
        final idle2 = int.tryParse(values2[3]) ?? 0;
        final iowait2 = values2.length > 4
            ? (int.tryParse(values2[4]) ?? 0)
            : 0;
        final irq2 = values2.length > 5 ? (int.tryParse(values2[5]) ?? 0) : 0;
        final softirq2 = values2.length > 6
            ? (int.tryParse(values2[6]) ?? 0)
            : 0;

        final totalTime2 =
            user2 + nice2 + system2 + idle2 + iowait2 + irq2 + softirq2;
        final idleTime2 = idle2 + iowait2;

        final totalDiff = totalTime2 - totalTime;
        final idleDiff = idleTime2 - idleTime;

        if (totalDiff > 0) {
          final usage = ((totalDiff - idleDiff) * 100 / totalDiff).clamp(
            0.0,
            100.0,
          );
          return '${usage.toStringAsFixed(1)}%';
        }
      }
    }

    return '0.0%';
  } catch (e) {
    return 'Error';
  }
}
