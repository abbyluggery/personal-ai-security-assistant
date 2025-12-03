# JARVIS Android Implementation Plan

## Overview
Complete Android system app implementation with emergency mode, dual camera recording, LLM lockout, and multi-provider streaming.

**Target Platform:** Android 10-14 (API 29-34)
**Target Device:** Samsung Galaxy S21 Ultra (future deployment)
**Key Feature:** Emergency mode with hardened security, LLM lockout, and foreground service without visible notifications

---

## Phase 3a: Android Manifest & System App Setup

### Objectives
- [ ] Create complete `AndroidManifest.xml` with all required permissions
- [ ] Set up privileged system app configuration (`android:sharedUserId="android.uid.system"`)
- [ ] Create `privapp-permissions-jarvis.xml` for `/system/etc/permissions/`
- [ ] Configure accessibility service for voice activation
- [ ] Test manifest compilation and permission declarations

### File Structure
```
app/src/main/
├── AndroidManifest.xml                      (Main manifest)
├── res/
│   ├── xml/
│   │   └── accessibility_service_config.xml  (Accessibility config)
│   ├── values/
│   │   └── strings.xml                       (App name, descriptions)
│   └── mipmap/
│       ├── ic_launcher.png                   (App icon)
│       └── ic_launcher_round.png
└── java/com/yourname/jarvis/
    ├── JarvisApplication.kt                 (Application class)
    ├── MainActivity.kt                       (Launcher activity)
    ├── services/
    │   ├── JarvisService.kt                 (Main foreground service)
    │   ├── EmergencyModeService.kt          (Emergency service)
    │   ├── MemorySyncService.kt             (Memory sync)
    │   └── VoiceAccessibilityService.kt     (Voice activation)
    └── receivers/
        ├── BootReceiver.kt                  (Auto-start on boot)
        └── EmergencyTriggerReceiver.kt      (Voice/button receiver)

system/etc/permissions/
└── privapp-permissions-jarvis.xml           (System app whitelist)
```

### Key Configuration Decisions

| Config | Value | Reason |
|--------|-------|--------|
| `android:sharedUserId` | `android.uid.system` | Enables privileged permissions when installed in `/system/priv-app/` |
| `android:persistent` | `true` | OS automatically restarts service on crash |
| `foregroundServiceType` | `camera\|microphone\|location\|dataSync\|specialUse` | Android 14+ requires type declarations |
| `android:stopWithTask` | `false` | Emergency service continues if app swiped away |
| `android:process` | `:emergency` | Emergency service runs in isolated process |

### Implementation Steps

**Step 1: Create AndroidManifest.xml**
```
Source: Use provided manifest structure
Sections:
- Core system permissions (foreground service, wake lock, boot)
- Emergency mode permissions (camera, audio, location)
- Privileged permissions (reboot, package management)
- Voice interface permissions (Bluetooth, accessibility)
- Memory system permissions (biometric, vibration)
- Three services (Main, Emergency, Memory sync)
- Boot receiver + emergency trigger receiver
- Voice accessibility service
```

**Step 2: Create Privileged Permissions Whitelist**
```
File: system/etc/permissions/privapp-permissions-jarvis.xml
When deployed as system app, this whitelist grants:
- START_ACTIVITIES_FROM_BACKGROUND
- REBOOT
- READ_PRIVILEGED_PHONE_STATE
- DELETE_PACKAGES / INSTALL_PACKAGES
- All camera, location, audio permissions
```

**Step 3: Configure Accessibility Service**
```
File: res/xml/accessibility_service_config.xml
Settings:
- Enabled: true
- Window content retrieval: enabled (for voice state)
- Feedback: spoken (for confirmations)
- Event types: all (to catch voice commands)
```

**Step 4: Application Class**
```kotlin
class JarvisApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        initializeServices()
        initializeLLMManager()
        initializeSecurityLayer()
    }
}
```

### Testing Checklist
- [ ] Manifest compiles without errors
- [ ] All permissions declared correctly
- [ ] No "ProtectedPermissions" lint warnings (only for privapp)
- [ ] Services can be instantiated
- [ ] Receivers registered properly
- [ ] Accessibility service config valid XML

---

## Phase 3b: Android Emergency Mode Service

### Objectives
- [ ] Implement `EmergencyModeService` with LLM lockout mechanism
- [ ] Dual camera recording (front + back, 1080p/30fps)
- [ ] Encrypted streaming to emergency contacts
- [ ] GPS broadcast every 30 seconds
- [ ] Duress code handling (fake vs. real deactivation)
- [ ] Deactivation countdown (90 seconds)
- [ ] Local encrypted cache fallback

### Core Architecture

```
EmergencyModeService
├── LLM Lockout Flag (@Volatile llmLocked: Boolean)
│   ├── Set to TRUE on activation
│   ├── All voice/text command processing disabled
│   └── Only hardcoded behaviors execute
│
├── State Machine
│   ├── NORMAL → EMERGENCY (activation triggered)
│   ├── EMERGENCY → DURESS (4-digit code entered)
│   ├── EMERGENCY → DEACTIVATING (8-digit + 90sec countdown)
│   ├── EMERGENCY → DEACTIVATED (countdown complete)
│   └── DURESS → EMERGENCY (if contacts override)
│
├── Hardcoded Behaviors (No AI Interpretation)
│   ├── startDualCameraRecording()
│   ├── startEncryptedStreaming()
│   ├── startGPSBroadcast()
│   ├── notifyEmergencyContacts()
│   └── startLocalEncryptedCache()
│
└── Deactivation Handlers
    ├── handleDuresCode() → Fake shutdown
    ├── handleRealCode() → 90-second countdown
    └── actuallyDeactivate() → Complete stop
```

### Key Implementation Details

**LLM Lockout Mechanism**
```kotlin
@Volatile
private var llmLocked: Boolean = false

fun activateEmergencyMode() {
    llmLocked = true  // IMMEDIATE: disable all AI
    // Emergency contact: LLMManager.setProvider(DISABLED)
    // Result: Voice commands completely ignored
    // Only hardcoded intents processed
}
```

**Deactivation Code Strategy**
```kotlin
companion object {
    // User will customize these
    private const val DURESS_CODE = "1234"         // 4 digits - quick under pressure
    private const val REAL_DEACTIVATE_CODE = "5678" // 8 digits - deliberate, secure
    private const val DEACTIVATION_DELAY_SECONDS = 60
}

fun handleDeactivationAttempt(code: String) {
    when (code) {
        DURESS_CODE → {
            // Appear to shutdown but keep recording
            showFakeDeactivationUI()
            notifyContactsDuressCodeEntered()
            // EVERYTHING continues: recording, GPS, streaming
        }
        REAL_DEACTIVATE_CODE → {
            // Show countdown, then actually stop
            scheduleRealDeactivation()
            // After 90 seconds: stopAllRecording(), stopStreaming(), etc.
        }
        else → {
            // Wrong code - log it, continue recording
            logDeactivationAttempt(code)
        }
    }
}
```

**Dual Camera Recording (CameraX)**
```kotlin
private fun startDualCameraRecording() {
    // Front camera: 1080p/30fps, 100°+ field of view
    // Back camera: 1080p/30fps, main camera for detail
    
    // Output format: H.264 video codec, AAC audio
    // Bitrate: 4 Mbps (video) + 128 kbps (audio)
    // Resolution: 1920x1080 @ 30fps both cameras
    // Estimated: 120MB/minute combined
    
    // Storage: Encrypted local cache first
    // Upload: Parallel streams to 3 destinations
}
```

**Encrypted Streaming (3 Parallel Paths)**
```kotlin
private fun startEncryptedStreaming() {
    // Stream 1: Direct RTMP to emergency contact (if on same network)
    // Stream 2: HTTPS to primary cloud storage (encrypted)
    // Stream 3: VPN chain → Non-extradition jurisdiction storage
    
    // All encrypted with AES-256 (Tink library)
    // Each stream has retry logic
    // If one fails, others continue
}
```

**GPS Broadcast (Fixed 30-second Interval)**
```kotlin
private fun startGPSBroadcast() {
    // LocationRequest parameters:
    val locationRequest = LocationRequest.create().apply {
        interval = 30_000L                    // 30 seconds
        fastestInterval = 30_000L             // No faster
        priority = LocationRequest.PRIORITY_HIGH_ACCURACY
        maxWaitTime = 0                       // No delay allowed
    }
    
    // CANNOT be changed during emergency
    // If low battery, STILL broadcasts every 30 seconds
    // Only stops on actual deactivation
}
```

### File: `services/EmergencyModeService.kt`

```kotlin
package com.yourname.jarvis.services

import android.app.Service
import android.content.Intent
import android.os.IBinder
import android.os.Handler
import android.os.Looper

class EmergencyModeService : Service() {

    @Volatile
    private var emergencyModeActive: Boolean = false
    
    @Volatile
    private var llmLocked: Boolean = false
    
    companion object {
        // CHANGE THESE to user's real codes
        private const val DURESS_CODE = "1234"
        private const val REAL_DEACTIVATE_CODE = "5678"
        private const val DEACTIVATION_DELAY_SECONDS = 90
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            "ACTIVATE_EMERGENCY" → activateEmergencyMode()
            "DEACTIVATE_EMERGENCY" → handleDeactivationAttempt(intent)
        }
        return START_STICKY
    }

    private fun activateEmergencyMode() {
        // Step 1: LOCK OUT LLM IMMEDIATELY
        llmLocked = true
        emergencyModeActive = true
        disableVoiceCommands()
        
        // Step 2: START HARDCODED BEHAVIORS
        startDualCameraRecording()
        startEncryptedStreaming()
        startGPSBroadcast()
        notifyEmergencyContacts()
        startLocalEncryptedCache()
        
        // Step 3: PREVENT TERMINATION
        startForeground(1, createNotification())
    }

    private fun disableVoiceCommands() {
        // Contact LLMManager to disable processing
        // sendBroadcast(Intent("com.yourname.jarvis.LLM_LOCKOUT"))
    }

    private fun handleDeactivationAttempt(intent: Intent) {
        val code = intent.getStringExtra("code") ?: return
        
        when (code) {
            DURESS_CODE → {
                showFakeDeactivationUI()
                notifyContactsDuressCodeEntered()
                // Recording continues silently
            }
            REAL_DEACTIVATE_CODE → {
                scheduleRealDeactivation()
            }
            else → logDeactivationAttempt(code)
        }
    }

    private fun scheduleRealDeactivation() {
        Handler(Looper.getMainLooper()).postDelayed({
            actuallyDeactivate()
        }, DEACTIVATION_DELAY_SECONDS * 1000L)
    }

    private fun actuallyDeactivate() {
        emergencyModeActive = false
        llmLocked = false
        stopAllRecording()
        stopStreaming()
        stopGPSBroadcast()
        stopForeground(true)
    }

    // ═════════════════════════════════════════════════════════════
    // HARDCODED BEHAVIORS - NO AI INTERPRETATION
    // ═════════════════════════════════════════════════════════════
    
    private fun startDualCameraRecording() {
        // TODO: Implement with CameraX or Camera2
    }

    private fun startEncryptedStreaming() {
        // TODO: Implement with RTMP + HTTPS + VPN
    }

    private fun startGPSBroadcast() {
        // TODO: Implement with FusedLocationProviderClient
    }

    private fun notifyEmergencyContacts() {
        // TODO: Send SMS/notification to 3 pre-set contacts
    }

    private fun startLocalEncryptedCache() {
        // TODO: Create encrypted cache with Tink library
    }

    private fun showFakeDeactivationUI() {
        // TODO: Show "Emergency Mode Ended" notification
    }

    private fun notifyContactsDuressCodeEntered() {
        // TODO: Silent notification to contacts
    }

    private fun logDeactivationAttempt(code: String) {
        // TODO: Log with timestamp
    }

    private fun stopAllRecording() { /* TODO */ }
    private fun stopStreaming() { /* TODO */ }
    private fun stopGPSBroadcast() { /* TODO */ }
    
    private fun createNotification(): android.app.Notification {
        // TODO: Minimal notification for foreground service
        return android.app.Notification()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        super.onDestroy()
        if (emergencyModeActive) {
            // Restart service if killed during emergency
            val restartIntent = Intent(this, EmergencyModeService::class.java)
                .setAction("ACTIVATE_EMERGENCY")
            startService(restartIntent)
        }
    }
}
```

### Testing Checklist
- [ ] Service starts without crashing
- [ ] LLM lockout flag sets correctly
- [ ] Duress code shows fake UI
- [ ] Real code triggers 90-second countdown
- [ ] Recording starts and captures video
- [ ] Streams attempt to send (mock destinations for testing)
- [ ] GPS updates every 30 seconds
- [ ] Service survives force-close and restarts
- [ ] Service survives low battery conditions

---

## Phase 3c: Android Boot & Activation

### Objectives
- [ ] Implement `BootReceiver` for auto-start on device boot
- [ ] Implement `EmergencyTriggerReceiver` for voice/button commands
- [ ] Implement `VoiceAccessibilityService` for always-listening wake word
- [ ] Integrate voice commands with LLMManager
- [ ] Test all activation methods

### Boot Receiver Implementation

**File:** `receivers/BootReceiver.kt`
```kotlin
class BootReceiver : BroadcastReceiver() {
    
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED ||
            intent.action == Intent.ACTION_LOCKED_BOOT_COMPLETED ||
            intent.action == "android.intent.action.QUICKBOOT_POWERON") {
            
            val serviceIntent = Intent(context, JarvisService::class.java)
                .setAction("ACTION_START_ON_BOOT")
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(serviceIntent)
            } else {
                context.startService(serviceIntent)
            }
        }
    }
}
```

### Emergency Trigger Receiver

**File:** `receivers/EmergencyTriggerReceiver.kt`
```kotlin
class EmergencyTriggerReceiver : BroadcastReceiver() {
    
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            "com.yourname.jarvis.EMERGENCY_ACTIVATE" → {
                val emergencyIntent = Intent(context, EmergencyModeService::class.java)
                    .setAction("ACTIVATE_EMERGENCY")
                context.startForegroundService(emergencyIntent)
            }
            "com.yourname.jarvis.DEACTIVATE_CODE" → {
                val code = intent.getStringExtra("code")
                val deactivateIntent = Intent(context, EmergencyModeService::class.java)
                    .setAction("DEACTIVATE_EMERGENCY")
                    .putExtra("code", code)
                context.startService(deactivateIntent)
            }
        }
    }
}
```

### Voice Accessibility Service

**File:** `services/VoiceAccessibilityService.kt`
```kotlin
class VoiceAccessibilityService : AccessibilityService() {
    
    private val voiceWakeWords = listOf(
        "hey jarvis",
        "jarvis",
        "emergency"
    )
    
    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        // Listen for speech-to-text results
        // Match wake words
        // Trigger emergency mode if "emergency" detected
    }
    
    override fun onInterrupt() {}
}
```

### Activation Methods (4 Parallel Paths)

| Method | Trigger | Implementation | Advantage |
|--------|---------|-----------------|-----------|
| **Voice** | "Hey JARVIS, emergency" | AccessibilityService + Whisper STT | Hands-free, natural |
| **Button Combo** | Vol+ + Vol- + Power (5s) | BroadcastReceiver monitoring | Always works, physical |
| **Steering Wheel** | Media buttons: ↑↑↓↓↑ | Bluetooth event monitoring | Invisible, hands on wheel |
| **Screen Tap** | Upper-left corner (3x rapidly) | Window manager overlay | Discreet, pocketable |

### Testing Checklist
- [ ] Device boots and JARVIS starts automatically
- [ ] Voice "emergency" command triggers activation
- [ ] Button combo (3-button 5s) triggers activation
- [ ] Steering wheel pattern (↑↑↓↓↑) triggers activation
- [ ] Screen tap (3x upper-left) triggers activation
- [ ] All 4 methods can activate simultaneously without conflicts
- [ ] Emergency mode starts within 2 seconds of any trigger

---

## Phase 4: Time Management & Check-ins

### Objectives
- [ ] Implement 5:15pm hard stop reminder
- [ ] Work session time blocking (e.g., 9am-5:30pm)
- [ ] Calendar integration with meeting detection
- [ ] Periodic health check-ins (every 2 hours)
- [ ] Battery and connectivity monitoring

### Implementation

**File:** `services/TimeManagementService.kt`
```kotlin
class TimeManagementService : Service() {
    
    fun scheduleHardStopReminder() {
        // At 5:15pm: Alert user to stop working
        // Force-quit work-related apps if needed
        // Cancel all pending notifications
        // Transition to personal time
    }
    
    fun startWorkSession() {
        // 9:00am: Begin tracking work time
        // Disable non-work apps
        // Enable focus mode
        // Start memory logging
    }
    
    fun checkIn() {
        // Every 2 hours: Ask user how they're doing
        // "How are you feeling? (Great/OK/Stressed)"
        // Log response for pattern analysis
        // Suggest breaks if stressed
    }
}
```

### Notification Strategy

| Time | Message | Action |
|------|---------|--------|
| 5:10pm | "Wrapping up in 5 minutes" | Gentle reminder |
| 5:15pm | "Work day over - closing apps" | Hard stop |
| Every 2hrs | "Check-in: How are you?" | Health status |

---

## Android Project Setup (Getting Started)

### 1. Create Android Project
```bash
# In Android Studio:
File → New → New Project
Package name: com.yourname.jarvis
Language: Kotlin
Min SDK: Android 10 (API 29)
Target SDK: Android 14 (API 34)
```

### 2. Add Dependencies (build.gradle)
```gradle
dependencies {
    // Core Android
    implementation "androidx.core:core:1.12.0"
    implementation "androidx.appcompat:appcompat:1.6.1"
    
    // Services
    implementation "androidx.lifecycle:lifecycle-service:2.6.2"
    
    // Location
    implementation "com.google.android.gms:play-services-location:21.0.1"
    
    // Camera
    implementation "androidx.camera:camera-core:1.3.0"
    implementation "androidx.camera:camera-camera2:1.3.0"
    
    // Encryption
    implementation "com.google.crypto.tink:tink-android:1.10.0"
    
    // HTTP
    implementation "com.squareup.okhttp3:okhttp:4.11.0"
    
    // Notifications
    implementation "androidx.core:core:1.12.0"
    
    // Testing
    testImplementation "junit:junit:4.13.2"
    androidTestImplementation "androidx.test.espresso:espresso-core:3.5.1"
}
```

### 3. Directory Structure
```
app/
├── src/
│   ├── main/
│   │   ├── AndroidManifest.xml
│   │   ├── java/com/yourname/jarvis/
│   │   │   ├── JarvisApplication.kt
│   │   │   ├── MainActivity.kt
│   │   │   ├── services/
│   │   │   │   ├── JarvisService.kt
│   │   │   │   ├── EmergencyModeService.kt
│   │   │   │   ├── MemorySyncService.kt
│   │   │   │   └── VoiceAccessibilityService.kt
│   │   │   ├── receivers/
│   │   │   │   ├── BootReceiver.kt
│   │   │   │   └── EmergencyTriggerReceiver.kt
│   │   │   └── utils/
│   │   │       ├── CameraManager.kt
│   │   │       ├── StreamingManager.kt
│   │   │       └── EncryptionUtil.kt
│   │   └── res/
│   │       ├── xml/
│   │       │   └── accessibility_service_config.xml
│   │       ├── values/
│   │       │   └── strings.xml
│   │       └── mipmap/
│   └── test/
└── build.gradle
```

---

## Deployment Strategy

### Development → Testing → Production

**Phase 3a-c (Development):**
- Build APK for regular testing on emulator
- Test all services and receivers
- Validate emergency mode logic

**Testing (Before Real Device):**
- Test on Android 10, 12, 14 emulators
- Mock all external services (GPS, streaming)
- Verify LLM lockout mechanism
- Test all 4 activation methods

**Production (System App Installation):**
```bash
# 1. Build signed APK
./gradlew bundleRelease

# 2. Flash to device in recovery
adb push app-release.apk /system/priv-app/Jarvis/app.apk

# 3. Install permissions whitelist
adb push privapp-permissions-jarvis.xml \
    /system/etc/permissions/privapp-permissions-jarvis.xml

# 4. Reboot and verify
adb reboot
```

---

## Security Checklist

- [ ] Deactivation codes hardcoded (not SharedPreferences)
- [ ] LLM lockout cannot be bypassed programmatically
- [ ] Emergency service runs in isolated process
- [ ] All streams encrypted with AES-256 (Tink)
- [ ] GPS tracking cannot be disabled during emergency
- [ ] Recording cannot be stopped by force-close
- [ ] Duress code appears to work but actually continues
- [ ] No logging of real deactivation codes
- [ ] Permissions whitelist signed and verified
- [ ] Foreground service notification minimized

---

## Next Steps (Immediate)

1. **Complete Phase 2** - Ollama integration to web app
2. **Set up Android project** - Create gradle project structure
3. **Implement Phase 3a** - AndroidManifest.xml + permissions
4. **Test on emulator** - Verify services start and permissions granted
5. **Implement Phase 3b** - EmergencyModeService with LLM lockout
6. **Test activation methods** - Voice, button, steering wheel, tap

---

**Document Version:** 1.0  
**Last Updated:** December 3, 2025  
**For:** JARVIS Personal AI Assistant - Android Emergency Mode  
