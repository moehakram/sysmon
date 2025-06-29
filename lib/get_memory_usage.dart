import 'dart:io';

Future<String> getMemoryUsage() async {
  try {
    final meminfoFile = File('/proc/meminfo');
    if (!await meminfoFile.exists()) return 'N/A';

    final lines = await meminfoFile.readAsLines();

    int memTotal = 0;
    int memAvailable = 0;
    int memFree = 0;
    int buffers = 0;
    int cached = 0;

    for (final line in lines) {
      final parts = line.split(RegExp(r'\s+'));
      if (parts.length >= 2) {
        final key = parts[0].replaceAll(':', '');
        final value = int.tryParse(parts[1]) ?? 0;

        switch (key) {
          case 'MemTotal':
            memTotal = value;
            break;
          case 'MemAvailable':
            memAvailable = value;
            break;
          case 'MemFree':
            memFree = value;
            break;
          case 'Buffers':
            buffers = value;
            break;
          case 'Cached':
            cached = value;
            break;
        }
      }
    }

    if (memTotal == 0) return 'Error';

    int memUsed;
    if (memAvailable > 0) {
      memUsed = memTotal - memAvailable;
    } else {
      memUsed = memTotal - memFree - buffers - cached;
    }

    memUsed = memUsed.clamp(0, memTotal);

    final usage = (memUsed * 100 / memTotal).clamp(0.0, 100.0);
    return '${usage.toStringAsFixed(1)}%';
  } catch (e) {
    return 'Error';
  }
}
