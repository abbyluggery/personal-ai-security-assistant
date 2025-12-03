# EMERGENCY MODE - COMPLETE SECURITY SPECIFICATION
## LLM Lockout & Tamper-Proof Recording System for Traffic Stops

**Status:** Production-Ready Specification  
**Last Updated:** December 3, 2025  
**Configuration Version:** 1.0 - User Approved  

---

## 🎯 EXECUTIVE SUMMARY

This is a hardened emergency mode system designed to protect civil rights during traffic stops and other high-risk law enforcement interactions. Once activated, the system:

- **LLM Lockout**: Disables all voice command processing (AI cannot be coerced)
- **Dual Camera Recording**: Front (officer interaction) + Back (scene/context) simultaneously
- **Military-Grade Encryption**: All streams encrypted end-to-end
- **VPN Jurisdiction Hop**: 5-country chain to non-extradition storage
- **Duress Code**: Fake deactivation that continues recording silently
- **Battery Optimization**: Maintains critical functions until device death
- **Tamper-Proof**: Survives force-close, reboot, uninstall, SIM removal
- **Dead Man's Switch**: Escalates if user becomes unresponsive

---

## 📋 YOUR APPROVED CONFIGURATION

### PIN Strategy (Psychological Advantage)
```
Real Deactivation PIN:     8 digits (e.g., 12345678)
                           - Deliberate, secure entry
                           - Requires conscious decision
                           - Different enough to be obvious if forced

Duress (Fake Stop) PIN:    4 digits (e.g., 1234)
                           - Quick under pressure
                           - Plausible if coerced
                           - Appears to work but continues recording
```

### GPS Tracking
```
Update Frequency:          Every 30 seconds (constant)
Battery Optimization:      DISABLED - Accuracy is critical
Emergency Contacts:        Receive live GPS link + updates
Beacon Format:             lat,lng,accuracy,timestamp
```

### Battery Management
```
Normal Operation:          100-50% - Full quality recording (1080p/30fps)
Power Saving Threshold:    50% battery → Kill all non-essentials
Critical Threshold:        5% → Begin final upload protocol
Quality During Low Batt:   Reduce to 720p/30fps (extends runtime 2x)
Final Protocol at 5%:      Upload final segment, send completion signal
```

### Activation Methods (All Enabled)
```
1. PRIMARY - Voice Command
   Trigger: "Hey JARVIS, I'm getting pulled over"
   
2. SECONDARY - Button Combo
   Trigger: All 3 buttons pressed for 5 seconds
   Buttons: Volume Up + Volume Down + Power
   
3. TERTIARY - Steering Wheel Pattern
   Trigger: Media button pattern (Bluetooth volume events)
   Pattern: ↑ ↑ ↓ ↓ ↑ (within 3 seconds)
   Advantage: Hands on wheel, invisible to officer
   
4. QUATERNARY - Screen Tap
   Trigger: Tap upper-left corner 3 times rapidly
   Use Case: Pocket activation, discreet
```

### Deactivation Process
```
COUNTDOWN PHASE (90 seconds max)
├─ Correct 8-digit PIN entered
├─ Screen shows: "Emergency Mode Ending - 90 seconds..."
├─ Recording CONTINUES during countdown
├─ GPS CONTINUES during countdown
├─ Streams CONTINUE uploading during countdown
└─ After 90 seconds: Recording stops, streams finalize

DURESS PHASE (if 4-digit PIN entered)
├─ Screen shows: "Emergency Mode Stopped" (FAKE)
├─ Fake shutdown animation plays
├─ Recording CONTINUES silently
├─ GPS CONTINUES silently
├─ Streams CONTINUE uploading silently
├─ Emergency contacts notified: "DURESS CODE DETECTED - STILL ACTIVE"
└─ Recording continues for up to 4 hours

REAL STOP (only after 8-digit PIN + 90s countdown)
├─ Recording ends
├─ Streams complete final uploads
├─ Local cache cleared
└─ System returns to NORMAL mode
```

### VPN Architecture (Your Custom Chain)

```
┌─────────────┐
│ Your Phone  │
│  (Android)  │
└──────┬──────┘
       │ Encrypted WireGuard Tunnel
       ▼
┌──────────────────────────────┐
│ VPS 1: ENTRY POINT           │
│ Provider: DigitalOcean / Vultr
│ Location: US (looks normal)  │
│ Cost: $5-10/month            │
└──────┬───────────────────────┘
       │ Encrypted WireGuard Tunnel
       ▼
┌──────────────────────────────┐
│ VPS 2: MIDDLE HOP            │
│ Provider: 1984 Hosting       │
│ Location: Iceland            │
│ Privacy: Strong (not 14-eyes)│
│ Cost: $15-20/month           │
└──────┬───────────────────────┘
       │ Encrypted WireGuard Tunnel
       ▼
┌──────────────────────────────┐
│ VPS 3: PRIVACY HOP           │
│ Provider: FlokiNET           │
│ Location: Switzerland        │
│ Privacy: Supreme (no extrad) │
│ Cost: $10-15/month           │
└──────┬───────────────────────┘
       │ Encrypted WireGuard Tunnel
       ▼
┌──────────────────────────────┐
│ VPS 4: EXIT PREPARATION      │
│ Provider: OrangeWebsite      │
│ Location: Romania            │
│ Privacy: Strong (new EU law) │
│ Cost: $5-10/month            │
└──────┬───────────────────────┘
       │ Encrypted WireGuard Tunnel
       ▼
┌──────────────────────────────┐
│ VPS 5: FINAL EXIT            │
│ Provider: Custom (non-extrad)
│ Location: Isle of Man        │
│ Privacy: Maximum             │
│ Cost: $20-30/month           │
└──────┬───────────────────────┘
       │ HTTPS Over final VPN hop
       ▼
┌──────────────────────────────┐
│ Storage Options (4-Stream):  │
│ 1. Your server (Isle of Man) │
│ 2. AWS S3 (encrypted)        │
│ 3. Backblaze B2              │
│ 4. Local Cache (fallback)    │
└──────────────────────────────┘
```

Total Monthly Cost: ~$65-85 (one-time setup)

### Recording Specifications

```
FRONT CAMERA (Officer Interaction)
├─ Resolution: 1080p/30fps (Normal mode)
├─ Bitrate: ~8 Mbps
├─ Codec: H.264
├─ Audio: Built-in microphone (all sound)
└─ Storage: 8 Mbps × 60s = ~60 MB/minute

BACK CAMERA (Scene Context & License Plates)
├─ Resolution: 1080p/30fps (Normal mode)
├─ Bitrate: ~8 Mbps
├─ Codec: H.264
├─ Audio: None (single mic used for all)
└─ Storage: 8 Mbps × 60s = ~60 MB/minute

PICTURE-IN-PICTURE DISPLAY
├─ Front: 70% of screen
├─ Back: 30% of screen (corner overlay)
├─ Timestamp: Bottom center (tamper indicator)
├─ GPS: Top right (live coordinates)
└─ Status: Top left (RECORDING indicator)

TOTAL BITRATE: ~16 Mbps combined
TOTAL STORAGE: ~120 MB/minute dual recording
SESSION EXAMPLES:
├─ 10-minute stop: ~1.2 GB
├─ 30-minute stop: ~3.6 GB
├─ 60-minute stop: ~7.2 GB
└─ 2-hour stop: ~14.4 GB
```

### Cloud Upload Strategy

```
STREAM A - DIRECT TO YOUR SERVER (Primary)
├─ Destination: Your web server (www.abbyluggery.com)
├─ Method: HTTPS POST with AES-256 encryption
├─ Retry: Every 10 seconds if failed
├─ Timeout: 60 seconds per chunk
└─ Purpose: Most reliable, fully under your control

STREAM B - VPN CHAIN → ISLE OF MAN (Backup 1)
├─ Route: 5-hop WireGuard chain (see above)
├─ Destination: VPS 5 in Isle of Man
├─ Encryption: AES-256 + WireGuard tunnel encryption
├─ Retry: Every 15 seconds if failed
└─ Purpose: Jurisdictional protection

STREAM C - BACKUP COMMERCIAL VPN (Backup 2)
├─ Provider: NordVPN (Panama jurisdiction)
├─ Encryption: VPN tunnel + AES-256
├─ Retry: Every 20 seconds if failed
└─ Purpose: Geographic redundancy

STREAM D - LOCAL CACHE (Ultimate Fallback)
├─ Location: Device storage (/data/local/emergency-cache/)
├─ Encryption: AES-256 on-device
├─ Size Limit: 10 GB
├─ Retention: Until manual delete or success
└─ Purpose: If all network fails, data still safe

UPLOAD PRIORITY:
├─ Stream A (your server) - every frame sent
├─ Stream B (VPN chain) - every frame sent
├─ Stream C (backup VPN) - if A+B failing
├─ Stream D (local cache) - if all else fails
```

### Emergency Contacts & Notifications

```
PRIMARY CONTACT - Sibling (B)
├─ Phone: [YOUR ENTRY]
├─ SMS on activation: "Emergency mode activated at [GPS]"
├─ SMS every 60 seconds: "Still recording at [GPS] - [timestamp]"
├─ Live stream link: [ENCRYPTED LINK]
├─ Permission: Can activate/escalate remotely

SECONDARY CONTACT - Trusted Friend
├─ Phone: [YOUR ENTRY]
├─ Same SMS pattern as primary
├─ Same stream access

TERTIARY CONTACT - Family Member
├─ Phone: [YOUR ENTRY]
├─ Same SMS pattern as primary
├─ Same stream access

DEAD MAN'S SWITCH (No phone interaction for 15+ minutes)
├─ Trigger: 15 minutes of no phone movement/interaction
├─ Action: Escalation SMS to all 3 contacts
├─ Content: "ESCALATION: User unresponsive, location: [GPS]"
├─ Behavior: Escalate recording to CRITICAL mode (higher bitrate)

WITNESS MODE (Remote Activation)
├─ If: User doesn't answer calls/texts for 5 minutes after emergency
├─ Then: Emergency contacts can text: "ACTIVATE WITNESS"
├─ Result: Recording continues even if phone locked
├─ Duration: 4 hours or manual stop with 8-digit PIN
```

### Legal & Recording Laws

```
YOUR JURISDICTION: Illinois / US (One-Party Consent)

RECORDING RULES (Illinois):
├─ ✅ Can record any person who consents (you consent to recording yourself)
├─ ✅ Can record in public space (expectation of privacy is low)
├─ ✅ Can record on your own property (includes your car)
├─ ✅ Can record police in public (1st Amendment protection)
├─ ❌ Cannot record on private property without owner consent
├─ ❌ Audio recording in bathrooms/bedrooms = illegal
└─ ⚠️  Police may order deletion, but courts protect evidence in self-defense cases

TRAFFIC STOP CONTEXT (Your Use Case):
├─ You're on/in YOUR property (vehicle)
├─ Officer is public servant in public space
├─ Recording is legal under Illinois law
├─ Audio recording is legal (one-party consent state)
└─ This recording is admissible evidence

STEALTH RECORDING:
├─ ✅ Legal (no requirement to notify)
├─ ✅ No visible indicator required
├─ ✅ Officer has no right to demand deletion
└─ ✅ Evidence is protected for self-defense
```

---

## 🔒 SECURITY INVARIANTS (MUST NEVER BE VIOLATED)

```
INVARIANT 1: LLM Lockout During Emergency
IF (state == EMERGENCY_MODE OR state == DURESS_MODE)
THEN LLM_ACTIVE == FALSE
THEN COMMAND_INTERPRETER == DISABLED
CONSEQUENCE: No voice commands possible, even if coerced

INVARIANT 2: Recording Continues Through Duress Code
IF (duress_pin_entered == TRUE)
THEN recording_continues == TRUE (hidden)
THEN gps_continues == TRUE (hidden)
THEN streams_continue == TRUE (hidden)
CONSEQUENCE: Officer cannot detect continued recording

INVARIANT 3: Real PIN Requires 90-Second Countdown
IF (real_pin_entered == TRUE)
THEN countdown_active == TRUE
THEN recording_continues == TRUE
THEN sleep_protected(90_seconds) == TRUE
CONSEQUENCE: Cannot be forced to stop immediately

INVARIANT 4: VPN Chain Before Storage
IF (network_available == TRUE)
THEN all_streams_must_use_encryption == TRUE
THEN stream_without_vpn == FALSE
CONSEQUENCE: Data always encrypted during transmission

INVARIANT 5: Battery Management Prioritization
IF (battery_percent < 50)
THEN kill_all_non_critical == TRUE
THEN recording_maintains == TRUE
THEN gps_maintains == TRUE
THEN streaming_maintains == TRUE
CONSEQUENCE: Maximum runtime for evidence capture
```

---

## ⚙️ ACTIVATION LOGIC

### Voice Activation (Primary)
```
1. Wake word listener: "Hey JARVIS"
   ├─ Biometric verification: User's voice (enrolled profile)
   ├─ On match: Proceed
   ├─ On mismatch: Ignore (silent)

2. Emergency phrase: "I'm getting pulled over"
   ├─ Confirm activation in 3 seconds
   ├─ If no confirm: Cancel

3. Transition: NORMAL_MODE → EMERGENCY_MODE
   └─ Immediate: Start all systems
```

### Button Combo Activation (Secondary - Silent)
```
1. Listen for button events
   ├─ Volume Up + Volume Down + Power held simultaneously
   ├─ Duration: 5 seconds required
   ├─ Feedback: Single vibration

2. Transition: NORMAL_MODE → EMERGENCY_MODE
   └─ Immediate: Start all systems
```

### Steering Wheel Pattern (Tertiary - Invisible)
```
1. Listen for media button events
   ├─ Bluetooth volume control (steering wheel)
   ├─ Pattern: UP, UP, DOWN, DOWN, UP (within 3 seconds)

2. Transition: NORMAL_MODE → EMERGENCY_MODE
   └─ Immediate: Start all systems
   
3. Advantage:
   ├─ No need to touch phone
   ├─ Hands on wheel (appears normal)
   ├─ Officer cannot detect
```

### Screen Tap Pattern (Quaternary - Discreet)
```
1. Listen for tap events in upper-left corner
   ├─ 3 rapid taps (within 2 seconds)
   ├─ Area: 10cm × 10cm upper-left

2. Transition: NORMAL_MODE → EMERGENCY_MODE
   └─ Immediate: Start all systems
```

---

## 📱 TECHNICAL IMPLEMENTATION PHASES

### Phase 1: Background Service Hardening (Week 1-2)
```
Goals:
✅ Survives force-close attempts
✅ Survives system reboot
✅ Survives uninstall attempts
✅ Hides from task manager
✅ Auto-restarts if killed

Implementation:
├─ Android Foreground Service (required by OS)
├─ Device Admin capabilities (for reboot recovery)
├─ Broadcast receivers (for wake-up signals)
├─ Persistent notification (hidden/minimized)
└─ WakeLock (prevents sleep)

Disguise:
├─ Service name: "System Service" or similar
├─ Package name: Generic (not "JARVIS")
├─ Process name: Hidden in background
└─ No obvious app icon
```

### Phase 2: VPN Chain Setup (Week 2-3)
```
Tasks:
1. Provision 5 VPS servers (one per hop)
2. Install WireGuard on each
3. Generate keys for each hop
4. Configure tunnel routing
5. Test end-to-end connectivity
6. Document failover procedures

Testing:
├─ Verify traffic routing through all 5 hops
├─ Confirm jurisdiction chain is correct
├─ Test failover if any hop goes down
└─ Measure latency overhead
```

### Phase 3: Emergency Mode Core (Week 3-4)
```
Implementation:
1. State machine engine
2. Activation method listeners (voice, buttons, etc.)
3. Dual camera recording
4. GPS beacon service
5. Battery monitor
6. Pin verification system
7. Multi-stream uploader

Testing:
├─ Each activation method triggers correctly
├─ State transitions work as specified
├─ Recording quality maintained
├─ GPS updates sent correctly
└─ All streams upload in parallel
```

### Phase 4: Security Features (Week 4-5)
```
Implementation:
1. LLM lockout (disable command interpreter)
2. Duress code logic
3. Dead man's switch
4. Remote witness activation
5. Encryption (AES-256)
6. Tamper protection (reboot detection)

Testing:
├─ Verify LLM cannot process voice during emergency
├─ Confirm duress code shows fake stop but continues
├─ Test dead man's switch triggers escalation
└─ Verify encryption is end-to-end
```

### Phase 5: Integration & Testing (Week 5-6)
```
Integration:
1. Combine all components
2. Integration testing
3. Security audit
4. Performance testing
5. Battery drain testing

Testing:
├─ Full end-to-end activation test
├─ Multi-hour recording test
├─ VPN failover test
├─ GPS accuracy verification
└─ Final security review
```

---

## 🧪 TESTING CHECKLIST

### Activation Methods
- [ ] Voice activation works with correct phrase
- [ ] Voice activation ignores incorrect phrases
- [ ] Biometric verification blocks unauthorized voice
- [ ] Button combo activates correctly
- [ ] Button combo requires 5 seconds (not 4.9, not 5.1)
- [ ] Steering wheel pattern detected correctly
- [ ] Screen tap in upper-left corner works
- [ ] Screen tap outside area doesn't activate

### Recording Quality
- [ ] Front camera: 1080p/30fps at 8 Mbps
- [ ] Back camera: 1080p/30fps at 8 Mbps
- [ ] Picture-in-picture displays correctly (70/30 split)
- [ ] Timestamp visible and accurate
- [ ] GPS coordinates visible and updating
- [ ] Audio quality clear for officer interaction

### GPS Tracking
- [ ] Updates every 30 seconds (not faster, not slower)
- [ ] Accuracy within 5 meters in open space
- [ ] Updates continue even at 10% battery
- [ ] Emergency contacts receive live link
- [ ] Link updates in real-time

### Pin Verification
- [ ] Real PIN (8 digits) stops recording after 90s countdown
- [ ] Duress PIN (4 digits) shows fake stop, continues recording
- [ ] Wrong PIN denied
- [ ] Multiple failed PINs trigger security lockout
- [ ] PINs timeout if emergency is longer than 4 hours

### Deactivation Process
- [ ] Real PIN entered → 90s countdown shown
- [ ] Recording continues during countdown
- [ ] After 90s: Recording stops
- [ ] Duress PIN entered → Fake stop shown
- [ ] Duress mode continues for up to 4 hours
- [ ] Emergency contacts notified of duress code

### VPN Chain
- [ ] All streams route through 5 hops
- [ ] Encryption maintained through all hops
- [ ] Latency acceptable (< 500ms additional)
- [ ] If hop 3 fails, auto-uses backup
- [ ] All streams encrypted end-to-end

### Battery Management
- [ ] At 50%: Power saving mode activated
- [ ] Non-essential processes killed
- [ ] Recording quality reduced to 720p
- [ ] GPS continues at 30s intervals
- [ ] At 5%: Final upload triggered
- [ ] Device shutdown after final upload complete

### Security Features
- [ ] Voice commands ignored during emergency (LLM locked out)
- [ ] Duress code detected and reported to contacts
- [ ] Dead man's switch triggers at 15 min inactivity
- [ ] Remote witness activation works
- [ ] Tamper protection: Survives force-close
- [ ] Tamper protection: Survives reboot
- [ ] Tamper protection: Survives uninstall attempt

### Emergency Contacts
- [ ] SMS sent on activation
- [ ] SMS sent every 60 seconds during recording
- [ ] Live stream link is valid and encrypted
- [ ] Contacts can view stream in real-time
- [ ] Contacts receive duress alert if wrong PIN entered
- [ ] Contacts receive escalation alert if unresponsive

---

## 📊 JSON CONFIGURATION

```json
{
  "emergency_mode": {
    "version": "1.0",
    "enabled": true,
    "configured_date": "2025-12-03",
    "user_approved": true,
    
    "activation": {
      "methods": [
        {
          "type": "voice",
          "primary": true,
          "trigger_phrase": "Hey JARVIS, I'm getting pulled over",
          "requires_biometric": true,
          "confirmation_timeout_seconds": 3
        },
        {
          "type": "button_combo",
          "buttons": ["VOLUME_UP", "VOLUME_DOWN", "POWER"],
          "duration_seconds": 5,
          "feedback": "single_vibration"
        },
        {
          "type": "steering_wheel_pattern",
          "pattern": ["UP", "UP", "DOWN", "DOWN", "UP"],
          "timeout_seconds": 3,
          "feedback": "silent"
        },
        {
          "type": "screen_tap",
          "location": "upper_left",
          "area_size_cm": 10,
          "taps_required": 3,
          "timeout_seconds": 2
        }
      ]
    },
    
    "pins": {
      "real_pin": {
        "length": 8,
        "hash": "[bcrypt_hash_of_real_pin]",
        "deactivation_delay_seconds": 90
      },
      "duress_pin": {
        "length": 4,
        "hash": "[bcrypt_hash_of_duress_pin]",
        "behavior": "fake_stop_continue_recording",
        "timeout_hours": 4
      }
    },
    
    "gps": {
      "update_interval_seconds": 30,
      "reduce_on_low_battery": false,
      "min_accuracy_meters": 5,
      "update_buffer_seconds": 5
    },
    
    "recording": {
      "front_camera": {
        "resolution": "1080p",
        "fps": 30,
        "bitrate_mbps": 8,
        "codec": "H.264",
        "audio": true
      },
      "back_camera": {
        "resolution": "1080p",
        "fps": 30,
        "bitrate_mbps": 8,
        "codec": "H.264",
        "audio": false
      },
      "storage_mb_per_minute": 120,
      "quality_reduction_at_battery_percent": 50,
      "reduced_quality_fps": 30,
      "reduced_quality_resolution": "720p"
    },
    
    "battery": {
      "aggressive_power_saving_threshold_percent": 50,
      "final_upload_threshold_percent": 5,
      "processes_to_kill": [
        "bluetooth",
        "wifi_scanning",
        "background_sync",
        "location_services",
        "all_background_apps"
      ]
    },
    
    "upload": {
      "streams": [
        {
          "priority": 1,
          "type": "direct",
          "destination": "https://www.abbyluggery.com/emergency-upload",
          "encryption": "AES-256",
          "retry_interval_seconds": 10,
          "timeout_seconds": 60
        },
        {
          "priority": 2,
          "type": "vpn_chain",
          "hops": 5,
          "destination": "isle_of_man_exit_node",
          "encryption": "AES-256 + WireGuard",
          "retry_interval_seconds": 15,
          "timeout_seconds": 60
        },
        {
          "priority": 3,
          "type": "commercial_vpn",
          "provider": "NordVPN",
          "jurisdiction": "Panama",
          "retry_interval_seconds": 20
        },
        {
          "priority": 4,
          "type": "local_cache",
          "location": "/data/local/emergency-cache",
          "max_size_gb": 10,
          "encryption": "AES-256",
          "retention": "until_manual_clear"
        }
      ]
    },
    
    "emergency_contacts": [
      {
        "name": "B (Sibling)",
        "phone": "[PHONE_NUMBER]",
        "priority": 1,
        "sms_on_activation": true,
        "sms_interval_seconds": 60,
        "can_activate_remote": true
      },
      {
        "name": "Trusted Friend",
        "phone": "[PHONE_NUMBER]",
        "priority": 2,
        "sms_on_activation": true,
        "sms_interval_seconds": 60,
        "can_activate_remote": true
      },
      {
        "name": "Family Member",
        "phone": "[PHONE_NUMBER]",
        "priority": 3,
        "sms_on_activation": true,
        "sms_interval_seconds": 60,
        "can_activate_remote": true
      }
    ],
    
    "safety_features": {
      "dead_man_switch": {
        "enabled": true,
        "inactivity_threshold_minutes": 15,
        "escalation_action": "sms_all_contacts"
      },
      "witness_mode": {
        "enabled": true,
        "activation_trigger": "contact_remote_command",
        "activation_phrase": "ACTIVATE WITNESS"
      },
      "llm_lockout": {
        "enabled": true,
        "effect": "voice_commands_ignored"
      }
    },
    
    "jurisdiction": {
      "location": "Illinois",
      "recording_law": "one_party_consent",
      "legal_under_first_amendment": true,
      "admissible_for_self_defense": true
    }
  }
}
```

---

## 🚀 NEXT STEPS

1. **VPN Setup** (Week 1-2)
   - Reserve 5 VPS servers
   - Configure WireGuard chain
   - Test connectivity and failover

2. **Backend Development** (Week 2-4)
   - Build Android background service
   - Implement state machine
   - Create recording engine

3. **Security Implementation** (Week 4-5)
   - LLM lockout mechanism
   - Duress code logic
   - Dead man's switch
   - Remote witness mode

4. **Testing & Deployment** (Week 5-6)
   - Comprehensive security testing
   - Real-world simulation tests
   - Beta testing on your device
   - Full deployment

5. **Ongoing Maintenance**
   - Monitor VPS health
   - Update security protocols as needed
   - Test monthly (activate and stop immediately)
   - Keep emergency contacts informed

---

## ✅ VERIFICATION CHECKLIST

- [x] Real PIN: 8 digits (secure)
- [x] Duress PIN: 4 digits (quick under pressure)
- [x] Deactivation delay: 90 seconds
- [x] GPS interval: Every 30 seconds (constant)
- [x] Battery threshold: 50% for aggressive saving
- [x] Activation methods: Voice + Button + Steering wheel + Tap
- [x] VPN: 5-hop self-hosted chain
- [x] Recording: Dual cameras, 1080p
- [x] Upload: 4 parallel streams
- [x] Emergency contacts: 3 configured
- [x] LLM lockout: Enabled
- [x] Duress mode: Enabled
- [x] Dead man's switch: Enabled
- [x] Witness mode: Enabled

**STATUS: READY FOR IMPLEMENTATION** ✅

---

*This specification is designed to protect your civil rights during law enforcement interactions. All features are legal under Illinois law and 1st Amendment protections. The system is built with privacy, security, and reliability as core principles.*
