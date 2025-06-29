import 'package:sysmon/get_battery_level.dart';
import 'package:sysmon/get_cpu_usage.dart';
import 'package:sysmon/get_disk_usage.dart';
import 'package:sysmon/get_memory_usage.dart';
import 'package:sysmon/get_network_usage.dart';

void main(List<String> arguments) async {
  if (arguments.isNotEmpty &&
      (arguments[0].toLowerCase() == 'help' ||
          arguments[0] == '-h' ||
          arguments[0] == '--help')) {
    _printUsage();
    return;
  }

  if (arguments.isNotEmpty) {
    switch (arguments[0].toLowerCase()) {
      case 'cpu':
        print(await getCpuUsage());
        break;
      case 'memory':
      case 'mem':
        print(await getMemoryUsage());
        break;
      case 'battery':
      case 'bat':
        print(await getBatteryLevel());
        break;
      case 'disk':
        print(await getDiskUsage());
        break;
      case 'network':
      case 'net':
        print(await getNetworkUsage());
        break;
      case 'all':
        final cpu = await getCpuUsage();
        final memory = await getMemoryUsage();
        final battery = await getBatteryLevel();
        final disk = await getDiskUsage();
        final network = await getNetworkUsage();
        print(
          'CPU: $cpu | MEM: $memory | BAT: $battery | DISK: $disk | NET: $network',
        );
        break;
      default:
        _printUsage();
        break;
    }
  } else {
    // Default: show CPU and Memory
    final cpu = await getCpuUsage();
    final memory = await getMemoryUsage();
    print('CPU: $cpu | MEM: $memory');
  }
}

void _printUsage() {
  print('''
Usage: sysmon [option]

Options:
            - Show CPU and memory (default)
  cpu       - Show CPU usage only
  memory    - Show memory usage only  
  mem       - Alias for memory
  battery   - Show battery level only
  bat       - Alias for battery
  disk      - Show disk usage only
  network   - Show network statistics
  net       - Alias for network
  all       - Show all system information
  help      - Show this help message

Examples:
  sysmon
  sysmon cpu
  sysmon all
''');
}
