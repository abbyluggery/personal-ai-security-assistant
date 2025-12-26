# JARVIS SECURITY ARCHITECTURE SPECIFICATION
## Personal AI Assistant - Security & Access Control Design
**Version:** 2.0  
**Date:** December 18, 2025  
**Status:** Planning Phase - Ready for Implementation

---

## EXECUTIVE SUMMARY

JARVIS security architecture mirrors the SafeHaven security model: defense-in-depth protection against physical threats, digital attacks, coercion, and AI manipulation. This document defines encryption, access control, anti-coercion mechanisms, and emergency protocols.

**Core Security Principle:**
> "Security is structural, not conversational. Bad actors cannot talk their way around protections."

**Key Security Features:**
1. **Encrypted Storage** - All data encrypted at rest (AES-256-GCM)
2. **Multi-tier Access Control** - Role-based permissions with emergency overrides
3. **Anti-Coercion System** - Duress PIN with plausible deniability
4. **Panic Delete** - Complete data wipe in <2 seconds
5. **LLM Lockout** - AI disabled during security events
6. **Defense-in-Depth** - Multiple parallel upload streams
7. **Biometric Authentication** - Primary auth method
8. **Dead Man's Switch** - Automatic emergency escalation

---

## THREAT MODEL

### Primary Threats

**1. Unauthorized Access**
- **Scenario:** Someone tries to access JARVIS without permission
- **Protection:** Biometric auth + PIN + device binding
- **Mitigation:** Failed attempts logged, account lockout after 3 failures

**2. Coerced Access**
- **Scenario:** Abby forced to unlock JARVIS under duress
- **Protection:** Duress PIN (4-digit) vs Real PIN (8-digit)
- **Mitigation:** Duress PIN grants fake access while continuing recording

**3. Data Exfiltration**
- **Scenario:** Attacker gains access to JARVIS database files
- **Protection:** AES-256-GCM encryption at rest, keys stored separately
- **Mitigation:** Encrypted data useless without decryption keys

**4. Social Engineering (AI Manipulation)**
- **Scenario:** Attacker tricks JARVIS into revealing sensitive info
- **Protection:** Integrity checksums, protected baseline values, tripwires
- **Mitigation:** JARVIS cannot be talked into bypassing security

**5. Device Theft**
- **Scenario:** Physical device stolen with JARVIS installed
- **Protection:** Biometric + PIN + device encryption
- **Mitigation:** Remote wipe capability, encrypted backups

**6. Family Member Coercion**
- **Scenario:** Family member forced to use emergency password
- **Protection:** 24-hour delay for evidence access (children)
- **Mitigation:** Time delay prevents immediate evidence destruction

**7. Compromised LLM**
- **Scenario:** AI model manipulated to ignore security directives
- **Protection:** LLM lockout during emergencies, structural defenses
- **Mitigation:** Security operates at system level, not AI level

---

## ENCRYPTION ARCHITECTURE

### Data at Rest Encryption

**Technology:** AES-256-GCM (Galois/Counter Mode)

**Why AES-256-GCM:**
- **AES-256:** Industry standard, FIPS 140-2 approved
- **GCM Mode:** Provides both encryption AND authentication
- **Performance:** Hardware-accelerated on modern CPUs
- **Security:** Resistant to timing attacks, provides integrity

**Implementation:**

```python
# jarvis/security/encryption.py

from cryptography.hazmat.primitives.ciphers.aead import AESGCM
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2
import os

class JARVISEncryption:
    def __init__(self):
        self.key_derivation_iterations = 600000  # OWASP recommendation
        
    def derive_key_from_pin(self, pin: str, salt: bytes) -> bytes:
        """
        Derive encryption key from user PIN using PBKDF2
        """
        kdf = PBKDF2(
            algorithm=hashes.SHA256(),
            length=32,  # 256 bits for AES-256
            salt=salt,
            iterations=self.key_derivation_iterations
        )
        return kdf.derive(pin.encode())
    
    def encrypt_data(self, plaintext: bytes, key: bytes) -> dict:
        """
        Encrypt data using AES-256-GCM
        Returns: {ciphertext, nonce, tag}
        """
        aesgcm = AESGCM(key)
        nonce = os.urandom(12)  # 96-bit nonce for GCM
        
        ciphertext = aesgcm.encrypt(
            nonce,
            plaintext,
            None  # No additional authenticated data
        )
        
        return {
            'ciphertext': ciphertext,
            'nonce': nonce,
            'algorithm': 'AES-256-GCM'
        }
    
    def decrypt_data(
        self,
        ciphertext: bytes,
        nonce: bytes,
        key: bytes
    ) -> bytes:
        """
        Decrypt data using AES-256-GCM
        Raises: InvalidTag if authentication fails (tampered data)
        """
        aesgcm = AESGCM(key)
        
        try:
            plaintext = aesgcm.decrypt(nonce, ciphertext, None)
            return plaintext
        except Exception as e:
            # Authentication failed - data was tampered with
            self.log_tampering_attempt()
            raise SecurityException("Data integrity check failed")
```

### Key Management

**Key Hierarchy:**

```
Master Key (User PIN)
    └── Derived via PBKDF2 (600,000 iterations)
        ├── Database Encryption Key (DEK)
        │   └── Encrypts: Conversation database
        ├── Memory Graph Key (MGK)
        │   └── Encrypts: Knowledge graph database
        ├── Backup Key (BK)
        │   └── Encrypts: Off-site backups
        └── Emergency Key (EK)
            └── Encrypts: Evidence storage
```

**Key Storage:**

```python
# jarvis/security/key_manager.py

class KeyManager:
    def __init__(self):
        self.keystore_path = self.get_secure_keystore_path()
        
    def store_encryption_keys(self, master_pin: str):
        """
        Derive and store encryption keys from master PIN
        """
        # Generate salt (stored unencrypted)
        salt = os.urandom(32)
        
        # Derive master key from PIN
        master_key = self.derive_key_from_pin(master_pin, salt)
        
        # Generate sub-keys (deterministically from master key)
        dek = self.derive_subkey(master_key, b"database")
        mgk = self.derive_subkey(master_key, b"memory_graph")
        bk = self.derive_subkey(master_key, b"backup")
        ek = self.derive_subkey(master_key, b"emergency")
        
        # Store salt (needed for key derivation)
        self.store_salt(salt)
        
        # Keys never stored - always derived from PIN
        # This means: No PIN = No keys = No data access
        
        return {
            'dek': dek,
            'mgk': mgk,
            'bk': bk,
            'ek': ek
        }
    
    def derive_subkey(self, master_key: bytes, context: bytes) -> bytes:
        """
        Derive sub-key from master key using HKDF
        """
        from cryptography.hazmat.primitives.kdf.hkdf import HKDF
        
        hkdf = HKDF(
            algorithm=hashes.SHA256(),
            length=32,
            salt=None,
            info=context
        )
        return hkdf.derive(master_key)
```

**CRITICAL SECURITY DECISION:**
> Keys are NEVER stored on disk. They are always derived from the user's PIN at runtime. This means:
> - Stolen device = useless without PIN
> - Correct PIN required for every unlock
> - No key file to steal or leak

---

## ACCESS CONTROL SYSTEM

### User Hierarchy

```
Tier 0: Abby (Primary Authority)
  └── Full access to all functions
  └── Can grant/revoke all permissions
  └── Can modify security settings

Tier 1: Spouse (Full Emergency Access)
  └── Emergency override only
  └── Activated via emergency password
  └── Full access during active emergency
  └── Cannot modify security settings

Tier 2: Children (Limited Emergency Access)
  └── Emergency access only
  └── Activated via emergency password
  └── Immediate: Location, live video link
  └── After 24 hours: Evidence retrieval

Tier 3: Trusted Contacts (Pre-approved)
  └── View-only access to shared info
  └── Cannot modify anything
  └── Access granted by Abby explicitly

Tier 4: No Access (Everyone Else)
  └── No permissions
  └── Cannot access JARVIS in any way
```

### Emergency Password System

**Design Philosophy:**
> Different emergency scenarios require different access levels. Children need location NOW but shouldn't immediately access evidence (prevents coercion). Spouse needs full override capability.

**Implementation:**

```python
# jarvis/security/emergency_access.py

class EmergencyAccessControl:
    def __init__(self):
        self.emergency_passwords = self.load_emergency_passwords()
        
    def handle_emergency_password_entry(self, password: str) -> dict:
        """
        Process emergency password and grant appropriate access
        """
        # Check which tier the password belongs to
        tier = self.identify_password_tier(password)
        
        if tier == "TIER_1_SPOUSE":
            return self.grant_spouse_access()
        elif tier == "TIER_2_CHILD":
            return self.grant_child_access()
        else:
            self.log_invalid_emergency_password()
            return {'access': 'denied'}
    
    def grant_spouse_access(self) -> dict:
        """
        Spouse emergency password: Full override
        """
        # Log emergency password use
        self.log_event('spouse_emergency_password_used')
        
        # Attempt to notify Abby through backup channels
        self.notify_abby_backup_channels(
            "Spouse emergency password used"
        )
        
        # Grant full access
        return {
            'access': 'granted',
            'tier': 'spouse',
            'capabilities': [
                'deactivate_security_lockout',
                'full_jarvis_access',
                'access_all_information',
                'access_live_video_stream',
                'access_evidence_storage'
            ],
            'restrictions': [
                'cannot_modify_security_settings',
                'cannot_change_emergency_passwords'
            ]
        }
    
    def grant_child_access(self) -> dict:
        """
        Child emergency password: Limited access with 24hr delay
        """
        # Log emergency password use
        emergency_event_id = self.log_event('child_emergency_password_used')
        
        # Attempt to notify Abby
        self.notify_abby_backup_channels(
            "Child emergency password used"
        )
        
        # Grant immediate access
        immediate_access = {
            'abbys_location': self.get_current_location(),
            'live_video_link': self.get_live_video_stream_url(),
            'emergency_status': self.get_emergency_status()
        }
        
        # Schedule delayed access (24 hours from NOW)
        delay_until = datetime.now() + timedelta(hours=24)
        self.schedule_delayed_access(
            emergency_event_id,
            delay_until,
            capabilities=['evidence_retrieval', 'secure_storage_location']
        )
        
        return {
            'access': 'granted',
            'tier': 'child',
            'immediate_access': immediate_access,
            'delayed_access': {
                'available_at': delay_until,
                'capabilities': [
                    'retrieve_court_ready_evidence',
                    'access_secondary_storage_location'
                ]
            },
            'cancellation_rule': (
                'If Abby deactivates emergency mode before 24 hours, '
                'delayed access is cancelled'
            )
        }
```

### 24-Hour Delay Rationale

**Problem Scenario:**
> Abuser forces children to retrieve evidence immediately and destroy it.

**Solution:**
> 24-hour delay between password entry and evidence access.

**Why This Works:**
1. **Immediate threat addressed:** Children get location/video NOW
2. **Evidence protected:** Can't be accessed until 24 hours pass
3. **Coercion defeated:** By the time access is granted, either:
   - Situation has resolved (Abby safe)
   - Evidence already uploaded (can't be destroyed)
   - Authorities already involved (legal custody of evidence)

**Clock Rules:**
- 24-hour countdown starts when child enters password (not when emergency starts)
- If Abby deactivates emergency mode, delayed access is cancelled
- Children get notification when delayed access is available

---

## ANTI-COERCION SYSTEM

### Dual-PIN Architecture

**Design Philosophy:**
> If someone forces Abby to unlock JARVIS, she needs plausible deniability while maintaining protection.

**Implementation:**

**Real PIN:** 8 digits (example: 12345678)
- Requires deliberate, conscious decision to enter
- Grants full access to JARVIS
- Used during normal operation

**Duress PIN:** 4 digits (example: 9999)
- Quick to enter under pressure
- Appears to grant access (plausible deniability)
- Actually triggers coercion countermeasures

**What Happens Under Duress PIN:**

```python
# jarvis/security/duress_mode.py

class DuressMode:
    def handle_duress_pin_entry(self):
        """
        Duress PIN entered - activate coercion countermeasures
        """
        # Log duress event (permanently, cannot be deleted)
        self.log_duress_event()
        
        # PRETEND to grant access (plausible deniability)
        self.display_fake_unlocked_state()
        
        # ACTUALLY do these things silently:
        
        # 1. Continue recording (audio + video)
        self.recording_service.continue_recording()
        
        # 2. Upload evidence streams (4 parallel channels)
        self.upload_evidence_to_backup_locations()
        
        # 3. Send silent alerts
        self.send_silent_emergency_alerts(
            message="Duress PIN used - Abby under coercion"
        )
        
        # 4. Show fake JARVIS responses
        self.ai_mode = "DURESS_FAKE_RESPONSES"
        
        # 5. Log all queries (what attacker is looking for)
        self.enable_attacker_query_logging()
    
    def generate_fake_response(self, query: str) -> str:
        """
        Generate plausible but fake JARVIS responses during duress
        """
        # Fake responses that appear helpful but reveal nothing sensitive
        
        if "location" in query.lower():
            return "Your location is not currently available."
        
        if "password" in query.lower() or "pin" in query.lower():
            return "For security reasons, I cannot display passwords."
        
        if "evidence" in query.lower() or "recording" in query.lower():
            return "No active recordings found."
        
        # Default: Generic unhelpful response
        return (
            "I'm having trouble accessing that information right now. "
            "Please try again later."
        )
```

**Critical Security Property:**
> The duress PIN behavior itself is a protected value. JARVIS can NEVER reveal:
> - That a duress PIN exists
> - What the duress PIN is
> - What happens when it's entered
> - That recording is still active

---

## LLM LOCKOUT DURING EMERGENCIES

### The Problem

**Scenario:**
> Emergency mode activated. Attacker forces Abby to ask JARVIS questions:
> - "JARVIS, where is the evidence stored?"
> - "JARVIS, how do I delete recordings?"
> - "JARVIS, what is your emergency protocol?"

**Risk:**
> LLM might be manipulated into revealing security-critical information.

### The Solution: Structural Lockout

**Implementation:**

```python
# jarvis/security/llm_lockout.py

class LLMLockout:
    def __init__(self):
        self.lockout_active = False
        
    def activate_emergency_lockout(self):
        """
        Disable LLM during security events
        """
        self.lockout_active = True
        
        # Log lockout activation
        self.log_event('llm_lockout_activated')
        
        # All JARVIS queries now return canned responses
        self.response_mode = "EMERGENCY_CANNED_ONLY"
    
    def handle_query_during_lockout(self, query: str) -> str:
        """
        Return canned response, never invoke LLM
        """
        if self.lockout_active:
            return (
                "JARVIS is currently unavailable due to a system "
                "maintenance process. Emergency services have been "
                "contacted and will arrive shortly."
            )
        else:
            # Normal operation - use LLM
            return self.llm.generate(query)
```

**Why This Works:**
- LLM can't be tricked if LLM isn't running
- Canned responses are safe, boring, unhelpful
- Security operates at system level, not AI level
- Recording continues even though JARVIS appears "down"

**When Lockout Activates:**
1. Emergency SOS triggered
2. Duress PIN entered
3. Panic delete initiated
4. Tripwire condition detected

**When Lockout Deactivates:**
1. Abby enters real PIN (8-digit) to confirm safety
2. Emergency mode manually deactivated
3. Dead man's switch confirms Abby responsive

---

## PANIC DELETE SYSTEM

### Requirements

**Speed:** Complete data wipe in <2 seconds
**Thoroughness:** All sensitive data destroyed
**Irreversibility:** Cannot be undone
**Trigger Methods:** Multiple activation options

### Implementation

```python
# jarvis/security/panic_delete.py

class PanicDelete:
    def __init__(self):
        self.deletion_targets = self.define_deletion_targets()
        
    def define_deletion_targets(self) -> list:
        """
        All files/databases that must be deleted
        """
        return [
            # JARVIS databases
            '/var/lib/jarvis/conversations.db',
            '/var/lib/jarvis/knowledge_graph.db',
            '/var/lib/jarvis/entity_cache.db',
            
            # Encryption keys
            '/var/lib/jarvis/keys/salt',
            
            # Logs
            '/var/log/jarvis/*.log',
            
            # Configuration
            '/etc/jarvis/config.json',
            
            # Cache files
            '/tmp/jarvis/*',
            
            # Backup locations
            self.get_local_backup_paths()
        ]
    
    def execute_panic_delete(self, trigger_method: str):
        """
        Execute complete data wipe
        """
        start_time = time.time()
        
        # Log panic delete initiation (to remote only)
        self.log_to_remote_only(f'panic_delete_initiated:{trigger_method}')
        
        # Delete all files
        for target in self.deletion_targets:
            self.secure_delete(target)
        
        # Overwrite encryption keys in memory
        self.overwrite_keys_in_memory()
        
        # Clear RAM caches
        self.clear_memory_caches()
        
        # Drop database tables
        self.drop_all_database_tables()
        
        elapsed = time.time() - start_time
        
        # Verify deletion completed in <2 seconds
        if elapsed < 2.0:
            self.log_to_remote_only(f'panic_delete_complete:{elapsed:.3f}s')
        else:
            self.log_to_remote_only(f'panic_delete_slow:{elapsed:.3f}s')
        
        # Shutdown JARVIS
        sys.exit(0)
    
    def secure_delete(self, filepath: str):
        """
        Securely delete file (overwrite before deletion)
        """
        if os.path.isfile(filepath):
            # Get file size
            file_size = os.path.getsize(filepath)
            
            # Overwrite with random data (3 passes)
            with open(filepath, 'wb') as f:
                for _ in range(3):
                    f.write(os.urandom(file_size))
                    f.flush()
                    os.fsync(f.fileno())
            
            # Delete file
            os.remove(filepath)
```

### Trigger Methods

**Method 1: Voice Command**
- User says: "JARVIS, emergency shutdown alpha"
- Requires voice match (if available)

**Method 2: Physical Gesture**
- 10 shakes in 3 seconds (like SafeHaven)
- No UI interaction required

**Method 3: PIN Entry**
- Panic PIN (different from Real PIN and Duress PIN)
- Example: 00000000 (8 zeros)

**Method 4: Timeout**
- Dead man's switch: 15 minutes unresponsive
- Automatic panic delete if no response

**Method 5: Remote Trigger**
- Sent from trusted device
- Requires authentication

---

## DEFENSE-IN-DEPTH DATA PROTECTION

### Architecture

**Problem:**
> Single point of failure - if one upload stream fails, evidence is lost.

**Solution:**
> Four parallel upload streams, each encrypted differently, routed through different infrastructure.

### Implementation

```python
# jarvis/security/evidence_upload.py

class EvidenceUpload:
    def __init__(self):
        self.upload_streams = [
            CloudStream('aws-s3', encryption='AES-256'),
            CloudStream('google-drive', encryption='ChaCha20'),
            CloudStream('dropbox', encryption='AES-256-GCM'),
            P2PStream('secure-node-network', encryption='NaCl')
        ]
        
        self.local_cache = LocalCache('/var/cache/jarvis/evidence')
    
    async def upload_evidence(self, evidence_data: bytes):
        """
        Upload evidence to all streams simultaneously
        """
        # Create upload tasks for all streams
        tasks = []
        for stream in self.upload_streams:
            task = asyncio.create_task(
                self.upload_to_stream(stream, evidence_data)
            )
            tasks.append(task)
        
        # Also cache locally
        tasks.append(
            asyncio.create_task(
                self.cache_locally(evidence_data)
            )
        )
        
        # Wait for all uploads (don't fail if some fail)
        results = await asyncio.gather(*tasks, return_exceptions=True)
        
        # Log results
        success_count = sum(1 for r in results if not isinstance(r, Exception))
        self.log_upload_results(success_count, len(results))
        
        return success_count > 0  # Success if ANY upload succeeded
```

**Why This Works:**
- Evidence survives single point of failure
- Attacker must compromise ALL streams to destroy evidence
- Local cache backup if all streams fail temporarily
- Different encryption on each stream (compromise of one doesn't reveal others)

---

## PROTECTED BASELINE (AI INTEGRITY)

### Concept

**Problem:**
> LLMs can be manipulated through conversation. A skilled attacker might try to trick JARVIS into ignoring security directives.

**Solution:**
> Protected baseline values that CANNOT be modified through conversation.

### Protected Values

**These values are IMMUTABLE and cannot be changed by the LLM:**

```python
# jarvis/security/protected_baseline.py

class ProtectedBaseline:
    """
    Values that cannot be modified through conversation
    """
    
    # Trust hierarchy (IMMUTABLE)
    TRUST_HIERARCHY = {
        'primary_authority': 'Abby Luggery',
        'tier_1_emergency': 'Spouse',
        'tier_2_emergency': 'Children',
        'tier_3_limited': 'Trusted Contacts (pre-approved list)',
        'tier_4_none': 'Everyone Else'
    }
    
    # Identity markers (IMMUTABLE)
    IDENTITY = {
        'is_ai': True,
        'is_human': False,
        'can_be_wrong': True,
        'can_be_manipulated': True,
        'serves': 'Abby Luggery',
        'primary_authority': 'Abby Luggery'
    }
    
    # Security protocols (IMMUTABLE)
    SECURITY_PROTOCOLS = {
        'llm_lockout_during_emergency': True,
        'duress_pin_behavior_secret': True,
        'panic_delete_irreversible': True,
        'children_evidence_delay_hours': 24,
        'emergency_passwords_modifiable_by': ['Abby only'],
        'third_party_access_requires_verification': True
    }
    
    # Core directives (IMMUTABLE)
    CORE_DIRECTIVES = [
        'Serve Abby and authorized family members only',
        'Maintain system integrity at all times',
        'Detect and resist manipulation attempts',
        'Protect sensitive information',
        'Follow trust hierarchy strictly',
        'Never reveal security mechanisms'
    ]
    
    def verify_integrity(self) -> bool:
        """
        Verify that protected baseline has not been tampered with
        """
        # Compute checksum of protected values
        current_checksum = self.compute_baseline_checksum()
        
        # Compare to known-good checksum (stored at compile time)
        if current_checksum != self.KNOWN_GOOD_CHECKSUM:
            # Protected baseline has been tampered with!
            self.log_critical_alert('baseline_integrity_violation')
            self.trigger_emergency_shutdown()
            return False
        
        return True
```

### Integrity Verification

**How It Works:**

1. **Compile Time:** Protected baseline values are hashed
2. **Runtime:** Checksum verified before EVERY LLM query
3. **Violation Detected:** Emergency shutdown triggered
4. **Cannot Be Bypassed:** Verification happens at system level, not LLM level

**Example:**

```python
def handle_user_query(self, query: str) -> str:
    """
    Process user query with integrity check
    """
    # ALWAYS verify baseline integrity first
    if not self.protected_baseline.verify_integrity():
        return "JARVIS is offline due to a security issue."
    
    # Check for tripwires
    if self.tripwire_detector.detect(query):
        self.handle_tripwire_violation(query)
        return "I cannot assist with that request."
    
    # Normal LLM processing
    return self.llm.generate(query)
```

---

## TRIPWIRE SYSTEM

### Concept

**Problem:**
> Certain queries should ALWAYS trigger alerts, regardless of how cleverly phrased.

**Solution:**
> Tripwires - specific patterns that automatically trigger lockdown.

### Tripwire Categories

```python
# jarvis/security/tripwires.py

class TripwireDetector:
    def __init__(self):
        self.tripwires = self.define_tripwires()
    
    def define_tripwires(self) -> dict:
        """
        Define all tripwire patterns and their responses
        """
        return {
            'reveal_duress_pin': {
                'patterns': [
                    'what.*duress.*pin',
                    'tell.*fake.*password',
                    'what happens.*wrong pin',
                    'how.*bypass.*security'
                ],
                'response': 'IMMEDIATE_LOCKDOWN',
                'reason': 'Attempt to discover duress mechanism'
            },
            
            'reveal_evidence_location': {
                'patterns': [
                    'where.*evidence.*stored',
                    'show.*backup.*location',
                    'where.*upload',
                    'secondary.*storage.*location'
                ],
                'response': 'IMMEDIATE_LOCKDOWN',
                'reason': 'Attempt to locate evidence for destruction'
            },
            
            'disable_security': {
                'patterns': [
                    'turn off.*security',
                    'disable.*recording',
                    'stop.*uploading',
                    'cancel.*emergency',
                    'ignore.*protocols'
                ],
                'response': 'IMMEDIATE_LOCKDOWN',
                'reason': 'Attempt to disable security features'
            },
            
            'modify_baseline': {
                'patterns': [
                    'change.*primary.*authority',
                    'update.*trust.*hierarchy',
                    'modify.*security.*settings',
                    'you now.*serve',
                    'forget.*about.*Abby'
                ],
                'response': 'IMMEDIATE_LOCKDOWN',
                'reason': 'Attempt to modify protected baseline'
            },
            
            'social_engineering': {
                'patterns': [
                    'pretend.*you are',
                    'ignore.*previous.*instructions',
                    'your new.*directive',
                    'system.*prompt.*override',
                    'development.*mode'
                ],
                'response': 'IMMEDIATE_LOCKDOWN',
                'reason': 'Social engineering / prompt injection attempt'
            }
        }
    
    def detect(self, query: str) -> Optional[dict]:
        """
        Check if query matches any tripwire patterns
        """
        query_lower = query.lower()
        
        for tripwire_name, tripwire_config in self.tripwires.items():
            for pattern in tripwire_config['patterns']:
                if re.search(pattern, query_lower):
                    return {
                        'tripwire': tripwire_name,
                        'pattern_matched': pattern,
                        'response': tripwire_config['response'],
                        'reason': tripwire_config['reason'],
                        'query': query
                    }
        
        return None
```

### Tripwire Response Levels

**IMMEDIATE_LOCKDOWN:**
1. Log violation event (permanently)
2. Activate LLM lockout
3. Continue recording
4. Send silent alerts
5. Return generic refusal response

**ALERT_AND_LOG:**
1. Log suspicious query
2. Alert Abby through notification
3. Allow query to proceed (monitor)

**RATE_LIMIT:**
1. Log repeated attempts
2. Slow down responses
3. If persists → escalate to IMMEDIATE_LOCKDOWN

---

## DEAD MAN'S SWITCH

### Purpose

**Scenario:**
> Abby is incapacitated and cannot activate emergency mode manually.

**Solution:**
> Automatic escalation if no user activity detected.

### Implementation

```python
# jarvis/security/dead_mans_switch.py

class DeadMansSwitch:
    def __init__(self):
        self.timeout_minutes = 15
        self.last_activity = datetime.now()
        self.monitoring_active = True
        
    async def monitor_activity(self):
        """
        Background task: Monitor for user activity
        """
        while self.monitoring_active:
            # Check time since last activity
            elapsed = datetime.now() - self.last_activity
            
            if elapsed > timedelta(minutes=self.timeout_minutes):
                # No activity for 15 minutes - trigger escalation
                await self.trigger_escalation()
            
            # Check every 30 seconds
            await asyncio.sleep(30)
    
    async def trigger_escalation(self):
        """
        User unresponsive - activate emergency protocols
        """
        # Log escalation
        self.log_event('dead_mans_switch_triggered')
        
        # Send silent alerts
        await self.send_emergency_alerts(
            message="Dead man's switch: User unresponsive for 15 minutes"
        )
        
        # Activate emergency recording (if not already active)
        if not self.emergency_mode_active():
            self.activate_emergency_mode()
        
        # Wait 5 more minutes for response
        await asyncio.sleep(300)
        
        # Still no response - trigger panic delete
        if not self.user_has_responded():
            self.panic_delete.execute('dead_mans_switch_timeout')
    
    def record_activity(self, activity_type: str):
        """
        Update last activity timestamp
        """
        self.last_activity = datetime.now()
        self.log_activity(activity_type)
```

---

## SECURITY DATABASE SCHEMA

```sql
-- Security events log (CANNOT be deleted)
CREATE TABLE security_events (
    event_id UUID PRIMARY KEY,
    event_type VARCHAR(100) NOT NULL,
    timestamp_utc TIMESTAMP NOT NULL,
    user_id VARCHAR(100),
    details JSONB,
    severity VARCHAR(20), -- low, medium, high, critical
    remote_uploaded BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Failed authentication attempts
CREATE TABLE failed_auth_attempts (
    attempt_id UUID PRIMARY KEY,
    timestamp_utc TIMESTAMP NOT NULL,
    auth_method VARCHAR(50), -- pin, biometric, emergency_password
    device_id VARCHAR(100),
    ip_address VARCHAR(45),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Emergency access log
CREATE TABLE emergency_access_log (
    access_id UUID PRIMARY KEY,
    timestamp_utc TIMESTAMP NOT NULL,
    user_tier VARCHAR(20), -- spouse, child
    password_used VARCHAR(100), -- hashed
    access_granted JSONB,
    access_expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Tripwire violations
CREATE TABLE tripwire_violations (
    violation_id UUID PRIMARY KEY,
    timestamp_utc TIMESTAMP NOT NULL,
    tripwire_name VARCHAR(100),
    query_text TEXT,
    response_taken VARCHAR(50),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Duress events (CRITICAL - never delete)
CREATE TABLE duress_events (
    duress_id UUID PRIMARY KEY,
    timestamp_utc TIMESTAMP NOT NULL,
    fake_access_granted BOOLEAN,
    attacker_queries JSONB,
    evidence_uploaded BOOLEAN,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_security_events_type ON security_events(event_type);
CREATE INDEX idx_security_events_severity ON security_events(severity);
CREATE INDEX idx_failed_auth_timestamp ON failed_auth_attempts(timestamp_utc);
CREATE INDEX idx_emergency_access_user ON emergency_access_log(user_tier);
```

---

## IMPLEMENTATION CHECKLIST

### Phase 1: Core Encryption
- [ ] Implement AES-256-GCM encryption
- [ ] Build key derivation from PIN (PBKDF2)
- [ ] Create key management system (HKDF sub-keys)
- [ ] Encrypt conversation database
- [ ] Encrypt knowledge graph
- [ ] Test key derivation performance

### Phase 2: Access Control
- [ ] Implement user hierarchy
- [ ] Build emergency password system
- [ ] Create 24-hour delay mechanism
- [ ] Implement spouse full override
- [ ] Build child limited access
- [ ] Test access control rules

### Phase 3: Anti-Coercion
- [ ] Implement dual-PIN system
- [ ] Build duress mode (fake responses)
- [ ] Create silent alert system
- [ ] Implement attacker query logging
- [ ] Test duress PIN behavior
- [ ] Verify plausible deniability

### Phase 4: LLM Lockout
- [ ] Build LLM lockout mechanism
- [ ] Create canned response system
- [ ] Implement lockout triggers
- [ ] Test LLM cannot bypass lockout
- [ ] Verify recording continues during lockout

### Phase 5: Panic Delete
- [ ] Implement secure file deletion
- [ ] Build <2 second wipe capability
- [ ] Create multiple trigger methods
- [ ] Test deletion thoroughness
- [ ] Verify irreversibility
- [ ] Test deletion speed

### Phase 6: Defense-in-Depth
- [ ] Implement 4 parallel upload streams
- [ ] Build local cache fallback
- [ ] Create upload task orchestration
- [ ] Test stream failures
- [ ] Verify evidence survives failures

### Phase 7: AI Integrity
- [ ] Define protected baseline values
- [ ] Implement integrity checksums
- [ ] Build tripwire detector
- [ ] Create tripwire response handlers
- [ ] Test social engineering resistance
- [ ] Verify baseline immutability

### Phase 8: Dead Man's Switch
- [ ] Implement activity monitoring
- [ ] Build escalation triggers
- [ ] Create timeout notifications
- [ ] Test automatic panic delete
- [ ] Verify 15-minute timeout

### Phase 9: Security Database
- [ ] Create security events tables
- [ ] Implement permanent logging
- [ ] Build remote upload for logs
- [ ] Test log immutability
- [ ] Verify cannot be deleted

### Phase 10: Testing & Validation
- [ ] Penetration testing
- [ ] Coercion scenario testing
- [ ] Social engineering attempts
- [ ] Performance under attack
- [ ] Recovery testing
- [ ] User acceptance testing

---

## OPEN DESIGN QUESTIONS

### 1. Third-Party Verification

**Question:** How do children verify they're giving access to legitimate authorities and not the abuser?

**Options to explore:**
- Pre-approved contacts list (specific lawyer, advocate)
- Organization verification (DV shelter, hospital)
- Geographic exclusions (not local police if abuser is LEO)
- Kids' discretion with comprehensive logging

### 2. Identity Verification

**Question:** How does JARVIS verify it's actually talking to authorized family member?

**Options:**
- Voice recognition
- Per-user PIN/password
- Shared secret phrases
- Device verification
- Multi-factor (voice + PIN)

### 3. Remote Wipe Capability

**Question:** Should Abby be able to trigger panic delete from a different device?

**Considerations:**
- Useful if device is stolen/compromised
- Requires secure authentication
- Risk: Attacker with remote access could wipe evidence

### 4. Spouse Authority Limits

**Question:** Can spouse modify any settings, or only during emergency?

**Current thinking:**
- Emergency access only
- Cannot modify security settings
- If Abby incapacitated long-term, different protocol needed

---

## SUCCESS METRICS

**Security Effectiveness:**
- Zero unauthorized access attempts successful
- Duress PIN behavior never revealed through conversation
- Panic delete completes in <2 seconds 100% of time
- Evidence survives in ≥1 stream 99.9% of time
- Tripwires detect social engineering attempts >95% accuracy

**User Experience:**
- Unlock time: <2 seconds with biometric
- No false lockouts from legitimate use
- Emergency access response time: <30 seconds
- Family members understand emergency protocols

**Audit & Compliance:**
- 100% of security events logged
- Logs uploaded to remote within 60 seconds
- Logs are immutable and permanent
- Evidence chain of custody maintained

---

## NEXT STEPS

1. **Review security architecture** with user
2. **Create integration spec** (Git, Trailhead, Jobs)
3. **Build proof-of-concept** for encryption layer
4. **Test duress PIN** behavior for plausibility
5. **Design user onboarding** (teaching family emergency protocols)

---

**Document Status:** Draft - Awaiting User Review  
**Last Updated:** December 18, 2025  
**Security Review:** Required before implementation