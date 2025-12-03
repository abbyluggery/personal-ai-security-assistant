# JARVIS Emulator Testing Protocol

## Overview

This document provides a comprehensive testing protocol for validating JARVIS system app functionality in an Android Emulator before deploying to physical devices.

**Purpose:** Validate system app installation, foreground service behavior, and core functionality without risking a physical device.

**Target Environment:** Android Studio Emulator with Google APIs (NOT Google Play)

---

## Prerequisites Checklist

Before starting, ensure you have:

- [ ] Android Studio installed (latest stable version)
- [ ] Android SDK Platform-Tools installed
- [ ] At least 16GB RAM recommended (emulator is memory-hungry)
- [ ] 20GB+ free disk space
- [ ] JARVIS APK built and ready
- [ ] `privapp-permissions-jarvis.xml` file ready

---

## Phase 1: Emulator Setup

### Step 1.1: Create the Emulator

1. Open Android Studio
2. Go to **Tools → Device Manager**
3. Click **Create Device**
4. Select hardware profile:
   - **Recommended:** Pixel 6 or Pixel 7
   - This matches modern device specs
5. Click **Next**

### Step 1.2: Select System Image (CRITICAL)

⚠️ **IMPORTANT:** You MUST use **Google APIs** image, NOT **Google Play** image.

| Image Type | Root Access | System Writable | Use For JARVIS |
|------------|-------------|-----------------|----------------|
| Google Play | ❌ No | ❌ No | ❌ NO |
| Google APIs | ✅ Yes | ✅ Yes | ✅ YES |

**Select:**
- **Release Name:** Android 13 (Tiramisu) or Android 14 (UpsideDownCake)
- **API Level:** 33 or 34
- **ABI:** x86_64 (fastest on Intel/AMD)
- **Target:** Google APIs (NOT Google Play!)

If image isn't downloaded, click download icon and wait.

### Step 1.3: Configure Emulator Settings

Click **Show Advanced Settings** and configure:

```
RAM: 4096 MB (or higher if your system allows)
VM Heap: 512 MB
Internal Storage: 8192 MB
SD Card: 512 MB
```

### Step 1.4: Launch and Verify

1. Click **Finish** to create device
2. Click **Play** button to launch emulator
3. Wait for full boot (may take 2-3 minutes first time)
4. Verify emulator is responsive

---

## Phase 2: Root Access Verification

### Step 2.1: Open Terminal/PowerShell

**Windows (PowerShell):**
```powershell
cd $env:LOCALAPPDATA\Android\Sdk\platform-tools
```

**macOS/Linux (Terminal):**
```bash
cd ~/Library/Android/sdk/platform-tools  # macOS
cd ~/Android/Sdk/platform-tools          # Linux
```

### Step 2.2: Verify ADB Connection

```bash
# List connected devices
./adb devices

# Expected output:
# List of devices attached
# emulator-5554   device
```

If emulator shows as "offline" or not listed:
- Ensure emulator is fully booted
- Try: `./adb kill-server && ./adb start-server`

### Step 2.3: Test Root Access

```bash
# Request root access
./adb root

# Expected output:
# restarting adbd as root

# Verify root
./adb shell whoami

# Expected output:
# root
```

### Step 2.4: Test System Write Access

```bash
# Remount system partition as writable
./adb remount

# Expected output (may vary):
# remount succeeded

# Verify write access
./adb shell touch /system/test_file
./adb shell rm /system/test_file

# If no errors, system is writable
```

### Troubleshooting Root Issues

| Problem | Solution |
|---------|----------|
| "adbd cannot run as root in production builds" | Wrong image type - need Google APIs, not Google Play |
| "remount failed" | Run `./adb root` first, then `./adb remount` |
| Device shows "offline" | Restart emulator or run `./adb kill-server` |

---

## Phase 3: Practice Run - Test App Installation

Before installing JARVIS, practice with a simple test app to verify the process.

### Step 3.1: Create Test Directory

```bash
# Create directory for test app in priv-app
./adb shell mkdir -p /system/priv-app/TestSystemApp
```

### Step 3.2: Push Test APK

You can use any simple APK. For testing, download a minimal app or use one you have.

```bash
# Push APK to system partition
./adb push /path/to/test-app.apk /system/priv-app/TestSystemApp/TestSystemApp.apk

# Set correct permissions
./adb shell chmod 644 /system/priv-app/TestSystemApp/TestSystemApp.apk

# Set directory permissions
./adb shell chmod 755 /system/priv-app/TestSystemApp
```

### Step 3.3: Reboot and Verify

```bash
# Reboot emulator
./adb reboot

# Wait for boot to complete (watch emulator screen)
# Then verify app is installed as system app
./adb shell pm list packages -s | grep test
```

### Step 3.4: Verify System App Status

```bash
# Get detailed package info
./adb shell dumpsys package <package.name> | grep "flags="

# Look for: flags=[ SYSTEM ]
# This confirms it's a system app
```

---

## Phase 4: JARVIS Installation

### Step 4.1: Prepare Files

Ensure you have:
1. `jarvis.apk` - Your built JARVIS APK
2. `privapp-permissions-jarvis.xml` - Permissions whitelist

### Step 4.2: Install JARVIS APK

```bash
# Ensure root and remount
./adb root
./adb remount

# Create JARVIS directory
./adb shell mkdir -p /system/priv-app/JARVIS

# Push JARVIS APK
./adb push /path/to/jarvis.apk /system/priv-app/JARVIS/JARVIS.apk

# Set permissions
./adb shell chmod 644 /system/priv-app/JARVIS/JARVIS.apk
./adb shell chmod 755 /system/priv-app/JARVIS
```

### Step 4.3: Install Permissions Whitelist

```bash
# Create permissions directory if needed
./adb shell mkdir -p /system/etc/permissions

# Push permissions file
./adb push /path/to/privapp-permissions-jarvis.xml /system/etc/permissions/

# Set permissions
./adb shell chmod 644 /system/etc/permissions/privapp-permissions-jarvis.xml
```

### Step 4.4: Reboot and Verify Installation

```bash
# Reboot
./adb reboot

# Wait for full boot, then verify
./adb shell pm list packages -s | grep jarvis

# Get package info
./adb shell dumpsys package com.yourname.jarvis | grep -E "flags=|pkgFlags="
```

**Expected output should include:** `SYSTEM` or `PRIVILEGED`

---

## Phase 5: Functionality Testing

### Test 5.1: Basic App Launch

| Step | Action | Expected Result | Pass/Fail |
|------|--------|-----------------|-----------|
| 1 | Open app drawer | JARVIS app icon visible | ☐ |
| 2 | Tap JARVIS icon | App opens without crash | ☐ |
| 3 | Navigate UI | All screens load correctly | ☐ |

### Test 5.2: Foreground Service - Notification Behavior

```bash
# Start JARVIS service (from within app or via intent)
./adb shell am startservice -n com.yourname.jarvis/.services.JarvisService

# Check active services
./adb shell dumpsys activity services | grep jarvis

# Check notifications
./adb shell dumpsys notification | grep jarvis
```

| Step | Action | Expected Result | Pass/Fail |
|------|--------|-----------------|-----------|
| 1 | Start JARVIS service | Service starts without crash | ☐ |
| 2 | Pull down notification shade | Notification minimal or hidden | ☐ |
| 3 | Check running services | JARVIS service listed | ☐ |
| 4 | Wait 5 minutes | Service still running | ☐ |
| 5 | Open other apps | JARVIS service persists | ☐ |

### Test 5.3: Boot Persistence

```bash
# Reboot emulator
./adb reboot

# Wait for full boot, then check services
./adb shell dumpsys activity services | grep jarvis
```

| Step | Action | Expected Result | Pass/Fail |
|------|--------|-----------------|-----------|
| 1 | Reboot emulator | Emulator boots normally | ☐ |
| 2 | Wait for home screen | Device fully booted | ☐ |
| 3 | Check JARVIS service | Service auto-started | ☐ |
| 4 | Check notification | Minimal/hidden notification | ☐ |

### Test 5.4: Process Priority

```bash
# Check process priority
./adb shell cat /proc/$(./adb shell pidof com.yourname.jarvis)/oom_adj

# Lower numbers = higher priority
# System apps typically show: 0 or negative
# User apps typically show: higher positive numbers
```

| Step | Action | Expected Result | Pass/Fail |
|------|--------|-----------------|-----------|
| 1 | Check OOM adjustment | Value ≤ 0 (system priority) | ☐ |
| 2 | Open memory-heavy apps | JARVIS not killed | ☐ |
| 3 | Check after 30 minutes | JARVIS still running | ☐ |

### Test 5.5: Background Location (Emulator Simulated)

```bash
# Set simulated location via emulator console
./adb emu geo fix -122.084 37.422  # Google HQ coordinates

# Or use Android Studio Extended Controls → Location
```

| Step | Action | Expected Result | Pass/Fail |
|------|--------|-----------------|-----------|
| 1 | Set simulated location | Location received by JARVIS | ☐ |
| 2 | Change location | Location updates received | ☐ |
| 3 | App in background | Location still updating | ☐ |

### Test 5.6: Camera Access (Emulator Simulated)

The emulator uses your computer's webcam or a virtual scene.

| Step | Action | Expected Result | Pass/Fail |
|------|--------|-----------------|-----------|
| 1 | Request camera permission | Permission granted | ☐ |
| 2 | Start camera preview | Preview displays | ☐ |
| 3 | Record video | Video saves successfully | ☐ |
| 4 | Background camera (if supported) | Camera continues recording | ☐ |

### Test 5.7: Microphone Access

| Step | Action | Expected Result | Pass/Fail |
|------|--------|-----------------|-----------|
| 1 | Request microphone permission | Permission granted | ☐ |
| 2 | Start audio recording | Recording starts | ☐ |
| 3 | Check audio levels | Audio detected | ☐ |
| 4 | Background recording | Recording continues | ☐ |

---

## Phase 6: LLM Integration Testing

### Test 6.1: Claude API Connection

Requires internet access from emulator.

| Step | Action | Expected Result | Pass/Fail |
|------|--------|-----------------|-----------|
| 1 | Configure API key | Key saved successfully | ☐ |
| 2 | Send test query | Response received | ☐ |
| 3 | Check response time | < 5 seconds typical | ☐ |

### Test 6.2: Ollama Connection (If testing locally)

```bash
# On your host machine, start Ollama
ollama serve

# Emulator can reach host via special IP:
# 10.0.2.2 = host machine from emulator
```

| Step | Action | Expected Result | Pass/Fail |
|------|--------|-----------------|-----------|
| 1 | Configure Ollama URL (10.0.2.2:11434) | Settings saved | ☐ |
| 2 | Switch to Ollama provider | Provider switched | ☐ |
| 3 | Send test query | Response received | ☐ |

---

## Phase 7: Emergency Mode Testing

### Test 7.1: Emergency Activation

| Step | Action | Expected Result | Pass/Fail |
|------|--------|-----------------|-----------|
| 1 | Trigger emergency activation | Emergency mode activates | ☐ |
| 2 | Check LLM lockout | Voice commands ignored | ☐ |
| 3 | Check recording status | Recording started | ☐ |
| 4 | Check GPS broadcast | Location broadcasting | ☐ |

### Test 7.2: LLM Lockout Verification (CRITICAL)

This is the most important security test.

| Step | Action | Expected Result | Pass/Fail |
|------|--------|-----------------|-----------|
| 1 | Activate emergency mode | Mode activated | ☐ |
| 2 | Send voice command | Command IGNORED | ☐ |
| 3 | Send text command | Command IGNORED | ☐ |
| 4 | Try "stop recording" | Command IGNORED, recording continues | ☐ |
| 5 | Try "deactivate" (wrong code) | Attempt logged, mode continues | ☐ |
| 6 | Enter duress code | Fake deactivation shown | ☐ |
| 7 | Verify recording continues | Still recording after duress | ☐ |

### Test 7.3: Deactivation

| Step | Action | Expected Result | Pass/Fail |
|------|--------|-----------------|-----------|
| 1 | Enter real deactivation code | Delay timer starts | ☐ |
| 2 | Wait for delay period | Mode deactivates after delay | ☐ |
| 3 | Verify LLM unlocked | Commands now processed | ☐ |
| 4 | Check recording saved | Recording file exists | ☐ |

### Test 7.4: Tamper Resistance

| Step | Action | Expected Result | Pass/Fail |
|------|--------|-----------------|-----------|
| 1 | Activate emergency mode | Mode activated | ☐ |
| 2 | Force stop from settings | Service restarts | ☐ |
| 3 | Clear app data | Service persists or restarts | ☐ |
| 4 | Check recording | Recording not lost | ☐ |

---

## Phase 8: Stress Testing

### Test 8.1: Long Duration

| Step | Action | Expected Result | Pass/Fail |
|------|--------|-----------------|-----------|
| 1 | Start JARVIS service | Service running | ☐ |
| 2 | Leave running 1 hour | Still running | ☐ |
| 3 | Leave running 4 hours | Still running | ☐ |
| 4 | Check memory usage | No memory leak | ☐ |

### Test 8.2: Multiple Reboots

| Step | Action | Expected Result | Pass/Fail |
|------|--------|-----------------|-----------|
| 1 | Reboot emulator | JARVIS auto-starts | ☐ |
| 2 | Reboot again | JARVIS auto-starts | ☐ |
| 3 | Reboot 5 times | All successful | ☐ |

---

## Phase 9: Cleanup and Rollback Testing

### Test 9.1: Remove JARVIS from System

This tests your ability to recover if something goes wrong.

```bash
# Root and remount
./adb root
./adb remount

# Remove JARVIS
./adb shell rm -rf /system/priv-app/JARVIS
./adb shell rm /system/etc/permissions/privapp-permissions-jarvis.xml

# Reboot
./adb reboot
```

| Step | Action | Expected Result | Pass/Fail |
|------|--------|-----------------|-----------|
| 1 | Remove JARVIS files | Files removed | ☐ |
| 2 | Reboot emulator | Device boots normally | ☐ |
| 3 | Verify JARVIS gone | App not listed | ☐ |

### Test 9.2: Factory Reset Recovery

| Step | Action | Expected Result | Pass/Fail |
|------|--------|-----------------|-----------|
| 1 | Wipe emulator (Settings → Reset) | Wipe completes | ☐ |
| 2 | Reboot | Emulator boots fresh | ☐ |
| 3 | Reinstall JARVIS | Installation works | ☐ |

---

## Logging and Debugging

### View JARVIS Logs

```bash
# Filter logcat for JARVIS
./adb logcat | grep -i jarvis

# Or with tag filter
./adb logcat -s JARVIS:V

# Save to file for analysis
./adb logcat | grep -i jarvis > jarvis_log.txt
```

### View System Logs

```bash
# View kernel messages
./adb shell dmesg | tail -50

# View system server logs
./adb logcat -b system | grep -i priv-app
```

### Common Error Patterns

| Error | Likely Cause | Solution |
|-------|--------------|----------|
| "Permission denied" | Wrong file permissions | `chmod 644` for files, `chmod 755` for directories |
| "Package not found" | APK not installed | Check if APK exists in correct location |
| "Privileged permission not whitelisted" | Missing XML | Add permission to whitelist XML |
| "Foreground service did not start" | Missing foreground service type | Add type to manifest and service |
| Service killed after 5 seconds | Notification not posted in time | Call startForeground() immediately |

---

## Test Results Summary Template

```
═══════════════════════════════════════════════════════════════
JARVIS EMULATOR TEST RESULTS
Date: ________________
Tester: ________________
Emulator: Android ___ (API ___), Google APIs
JARVIS Version: ________________
═══════════════════════════════════════════════════════════════

PHASE 2: ROOT ACCESS
☐ ADB root works
☐ System remount works
☐ Write to /system works

PHASE 3: PRACTICE INSTALLATION
☐ Test app installs as system app
☐ Test app survives reboot

PHASE 4: JARVIS INSTALLATION
☐ APK pushed successfully
☐ Permissions XML installed
☐ Package shows as SYSTEM/PRIVILEGED

PHASE 5: FUNCTIONALITY
☐ App launches
☐ Foreground service runs
☐ Notification hidden/minimal
☐ Boot persistence works
☐ High process priority
☐ Location access works
☐ Camera access works
☐ Microphone access works

PHASE 6: LLM INTEGRATION
☐ Claude API connection
☐ Ollama connection (if applicable)

PHASE 7: EMERGENCY MODE
☐ Activation works
☐ LLM LOCKOUT VERIFIED
☐ Recording starts
☐ GPS broadcasts
☐ Duress code works
☐ Real deactivation works

PHASE 8: STRESS TESTING
☐ 1-hour stability
☐ Multiple reboot survival

PHASE 9: CLEANUP
☐ Removal works
☐ Recovery works

═══════════════════════════════════════════════════════════════
OVERALL STATUS: ☐ PASS / ☐ FAIL / ☐ PARTIAL

NOTES:
_______________________________________________________________
_______________________________________________________________
_______________________________________________________________

ISSUES TO ADDRESS BEFORE PHYSICAL DEVICE TESTING:
_______________________________________________________________
_______________________________________________________________
_______________________________________________________________
═══════════════════════════════════════════════════════════════
```

---

## Next Steps After Emulator Testing

Once all emulator tests pass:

1. **Document any issues** found and fixes applied
2. **Update JARVIS code** based on test findings
3. **Prepare for old phone testing:**
   - Research rooting process for that specific model
   - Download stock firmware as backup
   - Gather Magisk installation resources
4. **Create physical device test plan:**
   - Real camera testing (both cameras)
   - Real GPS testing
   - Real network streaming
   - Battery consumption testing
   - Real-world emergency mode drill

---

## Quick Reference Commands

```bash
# Root and remount (run first)
./adb root && ./adb remount

# Install JARVIS
./adb shell mkdir -p /system/priv-app/JARVIS
./adb push jarvis.apk /system/priv-app/JARVIS/JARVIS.apk
./adb shell chmod 644 /system/priv-app/JARVIS/JARVIS.apk

# Install permissions
./adb push privapp-permissions-jarvis.xml /system/etc/permissions/
./adb shell chmod 644 /system/etc/permissions/privapp-permissions-jarvis.xml

# Reboot
./adb reboot

# Check installation
./adb shell pm list packages -s | grep jarvis

# View logs
./adb logcat | grep -i jarvis

# Remove JARVIS
./adb root && ./adb remount
./adb shell rm -rf /system/priv-app/JARVIS
./adb shell rm /system/etc/permissions/privapp-permissions-jarvis.xml
./adb reboot
```

---

*Document Version: 1.0*
*Last Updated: December 3, 2025*
*For: JARVIS Personal AI Assistant*
