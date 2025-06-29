# System Monitor

A lightweight command-line system monitoring tool written in Dart that provides real-time system information for Linux systems.

## Features

- **CPU Usage**: Real-time CPU utilization percentage with 3-second sampling for accuracy
- **Memory Usage**: RAM usage percentage with detailed memory statistics
- **Battery Level**: Battery percentage with charging status and visual indicators
- **Disk Usage**: Storage usage for specified paths with human-readable format
- **Network Statistics**: Network interface statistics showing RX/TX data and packets

## Requirements

### For Running Dart Script
- Dart SDK (version 2.12 or higher)
- Linux operating system (uses `/proc` filesystem)
- Read access to system files (`/proc/stat`, `/proc/meminfo`, `/proc/net/dev`, `/sys/class/power_supply`)

### For Compiled Executable
- Linux operating system (uses `/proc` filesystem)
- Read access to system files (same as above)
- No Dart SDK required for running compiled executable

## Installation

### Method 1: Run as Dart Script (Recommended for Development)

1. Clone or download the repository
2. Ensure Dart SDK is installed on your system
3. Run directly with Dart:
   ```bash
   dart bin/sysmon.dart
   ```
   or
   ```bash
   dart run
   ```

### Method 2: Compile to Native Executable (Recommended for Production)

Compiling to a native executable provides better performance and eliminates the need for Dart SDK on target machines.

#### Basic Compilation
```bash
# Compile to native executable
dart compile exe bin/sysmon.dart -o sysmon

# Run the compiled executable
./sysmon
```

#### System-wide Installation
```bash
# Compile and install system-wide
dart compile exe bin/sysmon.dart -o sysmon
sudo cp sysmon /usr/local/bin/
sudo chmod +x /usr/local/bin/sysmon

# Now you can run from anywhere
sysmon cpu
```

### Deployment Recommendations

- **Development/Testing**: Use `dart bin/sysmon.dart` for quick iterations
- **Local Use**: Compile to native executable for daily usage
- **Server Deployment**: Use compiled executable with system-wide installation
- **Distribution**: Provide compiled executables for different architectures

## Usage

### Basic Usage

```bash
# Using Dart script
dart bin/sysmon.dart

# Using compiled executable
./sysmon

# Using system-installed executable
sysmon

# Show all system information
dart bin/sysmon.dart all
# or
./sysmon all
```

### Help

```bash
dart bin/sysmon.dart help
dart bin/sysmon.dart -h
dart bin/sysmon.dart --help
```

## Output Examples

### Default Output (CPU + Memory)
```
CPU: 15.3% | MEM: 62.1%
```

### All System Information
```
CPU: 15.3% | MEM: 62.1% | BAT: ⚡85% | DISK: 45% (180G/400G) | NET: RX: 2.3GiB (1.2Mip) | TX: 856.7MiB (892.1Kip)
```

### Individual Components
```bash
$ dart bin/sysmon.dart cpu
15.3%

$ dart bin/sysmon.dart battery
⚡85%

$ dart bin/sysmon.dart disk /home
67% (250G/400G)

$ dart bin/sysmon network
RX: 2.3GiB (1.2Mip) | TX: 856.7MiB (892.1Kip)
```

## Breaking Down The Network Output:

RX: 2.3GiB (1.2Mip) | TX: 856.7MiB (892.1Kip)
 ↓      ↓       ↓        ↓       ↓        ↓
 │      │       │        │       │        └─ 892,100 packets sent
 │      │       │        │       └─ 856.7 Mebibytes sent (≈ 898 MB)
 │      │       │        └─ Transmit (Upload/Outgoing)
 │      │       └─ 1,200,000 packets received  
 │      └─ 2.3 Gibibytes received (≈ 2,469 MB)
 └─ Receive (Download/Incoming)

## Technical Details

### CPU Usage Calculation
- Reads from `/proc/stat` for CPU time statistics
- Uses differential measurement for accurate usage calculation
- 3-second sampling interval for first-time measurements
- Stores previous values in `/tmp/cpu_usage_dart.tmp` for subsequent calls

### Memory Usage Calculation
- Reads from `/proc/meminfo` for memory statistics
- Prefers `MemAvailable` when available
- Falls back to manual calculation: `MemTotal - MemFree - Buffers - Cached`

### Disk Usage
- Primary method uses `df -h` command for human-readable output
- Fallback method uses `stat` command with filesystem statistics
- Supports custom path specification

### Network Statistics
- Reads from `/proc/net/dev` for interface statistics
- Excludes loopback interface
- Only counts active interfaces (with data transmission)
- Formats bytes and packets in human-readable units

### Battery Information
- Scans `/sys/class/power_supply` for battery devices
- Supports multiple battery detection (looks for BAT* directories)
- Reads capacity and charging status

## Error Handling

The tool gracefully handles various error conditions:
- Missing system files (returns 'N/A')
- Permission issues (returns 'Error')
- Invalid data parsing (returns safe defaults)
- Command execution failures (uses fallback methods)

## Project Structure

```
bin/
└── sysmon.dart              # Command-line interface

lib/
├── get_cpu_usage.dart       # CPU usage calculation
├── get_memory_usage.dart    # Memory usage calculation  
├── get_battery_level.dart   # Battery status and level
├── get_disk_usage.dart      # Disk usage for given path
└── get_network_usage.dart   # Network interface statistics
```

## Temporary Files

The tool creates `/tmp/cpu_usage_dart.tmp` to store previous CPU measurements for accurate usage calculation between calls.

## Contributing

Feel free to submit issues, feature requests, or pull requests to improve the tool.

## License

This project is open source. Please check the repository for license details.

## Platform Compatibility

- ✅ Linux (all distributions)
- ❌ Windows (not supported - uses Linux-specific `/proc` filesystem)
- ❌ macOS (not supported - uses Linux-specific `/proc` filesystem)

For Windows or macOS alternatives, consider platform-specific implementations using appropriate system APIs.