import 'dart:io';

Future<String> getBatteryLevel() async {
  try {
    final batteryDir = Directory('/sys/class/power_supply');
    if (!await batteryDir.exists()) return 'N/A';

    await for (final entity in batteryDir.list()) {
      if (entity is Directory) {
        final dirName = entity.path.split('/').last;
        if (dirName.toUpperCase().startsWith('BAT')) {
          final capacityFile = File('${entity.path}/capacity');
          final statusFile = File('${entity.path}/status');

          if (await capacityFile.exists()) {
            try {
              final capacity = await capacityFile.readAsString();
              final level = (int.tryParse(capacity.trim()) ?? 0).clamp(0, 100);

              String status = '';
              if (await statusFile.exists()) {
                try {
                  final statusText = await statusFile.readAsString();
                  final statusTrim = statusText.trim().toLowerCase();

                  switch (statusTrim) {
                    case 'charging':
                      status = '⚡';
                      break;
                    case 'discharging':
                      status = _getBatteryIcon(level);
                      break;
                    case 'full':
                      status = '🔋';
                      break;
                    case 'not charging':
                      status = '🔌';
                      break;
                    default:
                      status = '🔋';
                  }
                } catch (e) {
                  status = '🔋';
                }
              }

              return '$status$level%';
            } catch (e) {
              continue;
            }
          }
        }
      }
    }

    return 'N/A';
  } catch (e) {
    return 'N/A';
  }
}

String _getBatteryIcon(int level) {
  if (level <= 30) return '🪫';
  return '🔋';
}
