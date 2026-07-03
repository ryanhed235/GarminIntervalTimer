# Garmin Interval Timer

A custom Garmin Connect IQ watch app designed for the Venu 3. 

## Features
- **AMOLED Safe:** Black background to preserve battery life and prevent screen burn-in.
- **Interval Logic:** A simple, repeating 35-second countdown timer.
- **Always-On Display:** Automatically utilizes the `Attention.backlight(1.0)` API to prevent the screen from dimming or sleeping while a workout interval is active.
- **Haptics:** Triggers a 1-second vibration at the end of every interval.

## Building and Running
This project can be compiled and run using the Garmin Connect IQ SDK command line tools.

```bash
# Build the project
monkeyc -d venu3 -f monkey.jungle -o bin/QuickTimer.prg -y developer_key.der

# Run in Simulator
monkeydo bin/QuickTimer.prg venu3
```
