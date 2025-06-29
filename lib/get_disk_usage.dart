import 'dart:io';

Future<String> getDiskUsage() async {
  try {
    final targetPath = '/';

    // Use df command for accurate disk usage
    // -h uses binary units (1024), -H uses decimal units (1000)
    final result = await Process.run('df', ['-h', targetPath]);

    if (result.exitCode == 0) {
      final lines = result.stdout.toString().trim().split('\n');
      if (lines.length >= 2) {
        final parts = lines[1].split(RegExp(r'\s+'));
        if (parts.length >= 5) {
          final usagePercent = parts[4].replaceAll('%', '');
          final used = parts[2];
          final total = parts[1];

          // Validate percentage
          final percent = int.tryParse(usagePercent) ?? 0;
          if (percent >= 0 && percent <= 100) {
            return '$usagePercent% ($used/$total)';
          }
        }
      }
    }

    // Fallback method using statvfs
    try {
      final result2 = await Process.run('stat', [
        '-f',
        '-c',
        '%S %f %b',
        targetPath,
      ]);
      if (result2.exitCode == 0) {
        final parts = result2.stdout.toString().trim().split(' ');
        if (parts.length >= 3) {
          final blockSize = int.tryParse(parts[0]) ?? 0;
          final freeBlocks = int.tryParse(parts[1]) ?? 0;
          final totalBlocks = int.tryParse(parts[2]) ?? 0;

          if (blockSize > 0 && totalBlocks > 0) {
            final usedBlocks = totalBlocks - freeBlocks;
            final usagePercent = (usedBlocks * 100 / totalBlocks).clamp(
              0.0,
              100.0,
            );
            return '${usagePercent.toStringAsFixed(1)}%';
          }
        }
      }
    } catch (e) {
      // Ignore fallback error
    }

    return 'N/A';
  } catch (e) {
    return 'Error';
  }
}
