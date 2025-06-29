import 'dart:io';

Future<String> getNetworkUsage() async {
  try {
    final netDevFile = File('/proc/net/dev');
    if (!await netDevFile.exists()) return 'N/A';

    final lines = await netDevFile.readAsLines();

    int totalRxBytes = 0;
    int totalTxBytes = 0;
    int totalRxPackets = 0;
    int totalTxPackets = 0;
    int activeInterfaces = 0;

    for (final line in lines) {
      if (line.contains(':') && !line.contains('lo:')) {
        // Skip loopback
        final parts = line.split(':');
        if (parts.length >= 2) {
          final stats = parts[1].trim().split(RegExp(r'\s+'));
          if (stats.length >= 10) {
            final rxBytes = int.tryParse(stats[0]) ?? 0;
            final rxPackets = int.tryParse(stats[1]) ?? 0;
            final txBytes = int.tryParse(stats[8]) ?? 0;
            final txPackets = int.tryParse(stats[9]) ?? 0;

            // Only count active interfaces (have transmitted data)
            if (rxBytes > 0 || txBytes > 0) {
              totalRxBytes += rxBytes;
              totalTxBytes += txBytes;
              totalRxPackets += rxPackets;
              totalTxPackets += txPackets;
              activeInterfaces++;
            }
          }
        }
      }
    }

    if (activeInterfaces == 0) return 'No active interfaces';

    return 'RX: ${_formatBytes(totalRxBytes)} (${_formatPackets(totalRxPackets)}) | TX: ${_formatBytes(totalTxBytes)} (${_formatPackets(totalTxPackets)})';
  } catch (e) {
    return 'Error';
  }
}

String _formatBytes(int bytes) {
  const units = ['B', 'KiB', 'MiB', 'GiB', 'TiB'];
  double size = bytes.toDouble();
  int unitIndex = 0;

  while (size >= 1024 && unitIndex < units.length - 1) {
    size /= 1024;
    unitIndex++;
  }

  return '${size.toStringAsFixed(1)}${units[unitIndex]}';
}

String _formatPackets(int packets) {
  if (packets < 1024) return '${packets}p';
  if (packets < 1024 * 1024) return '${(packets / 1024).toStringAsFixed(1)}Kip';
  if (packets < 1024 * 1024 * 1024) {
    return '${(packets / (1024 * 1024)).toStringAsFixed(1)}Mip';
  }
  return '${(packets / (1024 * 1024 * 1024)).toStringAsFixed(1)}Gip';
}
