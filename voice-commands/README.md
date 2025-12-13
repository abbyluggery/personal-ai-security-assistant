# Voice Commands Setup Guide
## Quick-Win Implementation for Holistic Claude Assistant

**Platform Support**: iOS (Shortcuts) + Android (Google Assistant)
**Setup Time**: ~30 minutes
**Claude API**: Uses your Claude API key (get from console.anthropic.com)
**Value**: Immediate hands-free access to Claude intelligence

---

## 🎯 Overview

This weekend's quick win: Get 5 core voice commands working that leverage Claude AI with holistic awareness of your context.

### The 5 Core Commands

1. **"Good morning, Claude"** - Daily context overview and schedule
2. **"Run job search routine"** - Review new opportunities with AI insights
3. **"Log my energy"** - Quick energy/mood/pain check-in
4. **"Celebrate today's win"** - Achievement tracking with encouragement
5. **"What's my schedule?"** - Adaptive schedule based on current energy

---

## 📱 Platform-Specific Setup

### iOS (Recommended for Quick Start)

**Requirements**:
- iPhone with iOS 13+ (Shortcuts app pre-installed)
- Claude API key (get from console.anthropic.com)
- ~15 minutes setup time

**Setup Steps**:
1. Open this file on your iPhone: `ios-shortcuts.md`
2. For each of the 5 shortcuts:
   - Tap the iCloud link (creates shortcut automatically)
   - OR manually create using the detailed instructions
3. Test each command with "Hey Siri, [command name]"

**See**: `ios-shortcuts.md` for detailed configurations

---

### Android (Google Assistant)

**Requirements**:
- Android phone with Google Assistant
- Claude API key
- ~20 minutes setup time
- IFTTT account (free) OR Tasker app ($3.49)

**Setup Steps**:
1. Open this file on your Android: `android-assistant.md`
2. Choose your method:
   - **Option A**: IFTTT (easier, cloud-based)
   - **Option B**: Tasker (more powerful, local)
3. For each of the 5 commands:
   - Create routine/applet
   - Configure to call Claude API
   - Test with "Hey Google, [command name]"

**See**: `android-assistant.md` for detailed configurations

---

## 🔐 Security Notes

### API Key Handling

**Getting Your API Key**:
1. Go to https://console.anthropic.com/
2. Navigate to API Keys section
3. Create a new key or copy your existing key
4. Use this key in the setup instructions

**Security Practices**:
- ✅ Stored locally in Shortcuts/Tasker (device-only)
- ✅ Never shared with third parties
- ✅ Not synced to cloud (unless you choose)
- ⚠️ IFTTT option stores key in their cloud (consider risk)
- ✅ Can rotate key anytime at console.anthropic.com

**Recommendation**: Use iOS Shortcuts or Android Tasker for best security (local storage only).

---

## 🧠 How Commands Work

### Basic Flow

```
You speak → Phone captures → Text transcription
                                    ↓
                        Shortcut/Routine runs
                                    ↓
                        Builds Claude API request with:
                        • Your voice input
                        • Current context (date, time)
                        • Relevant skills loaded
                        • Your preferences
                                    ↓
                        Sends to Claude API
                                    ↓
                        Claude responds with:
                        • Personalized insight
                        • Actionable recommendations
                        • Holistic awareness
                                    ↓
                        Phone reads response aloud
                                    ↓
                        (Optional) Logs to PWA for sync
```

### Context Awareness

Each command includes:
- **Current date/time**: "Today is Saturday, November 16, 2025, 9:45am"
- **Your identity**: "You are Abby's personal Claude assistant"
- **Relevant skills**: Skills that match the command type
- **Your goals**: Manifestation targets, job search status, etc.

This context makes Claude responses:
- ✅ Personalized to you specifically
- ✅ Aware of your neurodivergent needs
- ✅ Aligned with your manifestation goals
- ✅ Time-sensitive and actionable

---

## 📋 Command Details

### 1. "Good Morning, Claude"

**Purpose**: Start your day with holistic overview

**What It Does**:
- Greets you by name
- Confirms today's date and day of week
- Provides energy pattern prediction (e.g., "Thursdays are typically high-energy days for you")
- Suggests optimal schedule based on priorities
- Highlights job search actions (if any pending)
- Shares today's affirmation
- Reminds of boundaries (5:15pm hard stop)

**Example Response**:
> "Good morning, Abby! Today is Saturday, November 16th - a typically medium-energy day for you.
>
> I see your morning routine is complete - excellent! You're on a 22-day streak.
>
> For today's schedule, I recommend:
> - 9:45-11:30am: Prime job search time (3 new high-fit roles posted yesterday)
> - 12:30pm: Garden lunch break for sensory regulation
> - 2:00-4:30pm: Certification study (exam in 13 days)
> - 5:15pm: Hard stop
>
> Your affirmation for today: 'I am manifesting a $155K+ role that honors my worth.'
>
> Ready to make today count?"

---

### 2. "Run Job Search Routine"

**Purpose**: AI-powered job opportunity review

**What It Does**:
- Summarizes current application status
- Reports new high-fit opportunities (if any)
- Provides company research snippets
- Calculates fit scores (1-10)
- Highlights neurodivergent-friendly signals
- Recommends next actions
- Estimates time needed

**Example Response**:
> "Job search update: You have 12 active applications, 1 phone screen scheduled for Monday.
>
> I found 3 new opportunities posted in the last 24 hours:
>
> 1. Salesforce Admin at TechCorp - $95-115K, remote, fit score 8.5/10
>    Green flags: Remote, flexible schedule
>    Yellow flag: Early meetings mentioned - verify Monday policy
>
> 2. Agentforce Specialist at InnovateCo - $105-125K, remote, fit score 9.2/10 ⭐
>    Green flags: Remote, neurodivergent-friendly stated, Agentforce focus
>    This is a HIGH PRIORITY opportunity!
>
> 3. SF Business Analyst at EnterpriseCo - $85-100K, hybrid, fit score 6.8/10
>    Yellow flags: Below target salary, heavy meeting culture
>
> My recommendation: Focus on InnovateCo today. It hits all your criteria and leverages your Agentforce expertise.
>
> Estimated time: 60 minutes (company research 15 min, resume tailoring 30 min, application 15 min).
>
> Ready to begin?"

---

### 3. "Log My Energy"

**Purpose**: Quick wellness check-in

**What It Does**:
- Prompts for energy level (1-10)
- Prompts for mood (1-10)
- Prompts for pain level (1-10)
- Optional: brief note
- Analyzes patterns
- Provides insights
- Adjusts schedule if needed

**Example Interaction**:
> **Claude**: "Let's check in. On a scale of 1-10, how's your energy right now?"
>
> **You**: "About a 6"
>
> **Claude**: "Got it, energy level 6. How about your mood?"
>
> **You**: "7"
>
> **Claude**: "Good. And pain level?"
>
> **You**: "4"
>
> **Claude**: "Thanks, Abby. I've logged: Energy 6/10, Mood 7/10, Pain 4/10.
>
> Analysis: Your energy is moderate, which matches your typical Saturday pattern. Pain is manageable.
>
> Based on this, your schedule stays as planned. If energy drops below 5, I'll suggest switching to a lighter routine.
>
> Keep up the good self-awareness!"

---

### 4. "Celebrate Today's Win"

**Purpose**: Achievement tracking and encouragement

**What It Does**:
- Prompts for today's win
- Provides genuine encouragement
- Connects win to larger goals
- Adds to achievement log
- Checks for milestones
- Builds evidence against imposter syndrome

**Example Interaction**:
> **Claude**: "What's today's win? It can be big or small - progress is progress."
>
> **You**: "I applied to that Agentforce role at InnovateCo"
>
> **Claude**: "That's fantastic, Abby! Applying to InnovateCo is a SIGNIFICANT win. Here's why:
>
> 1. It's your 12th quality application this month - you've hit your target!
> 2. This role has a 9.2/10 fit score - you're being strategic, not desperate
> 3. It leverages your Agentforce Superbadge certification (your differentiator)
> 4. At $105-125K, it's 68% toward your $155K manifestation goal
>
> This is evidence of:
> - Your competence (you can identify high-fit opportunities)
> - Your discipline (you followed through despite executive function challenges)
> - Your worth (you're not settling for roles below your target)
>
> You're building a track record. This application represents real progress.
>
> I've logged this win. You should be proud. 💙"

---

### 5. "What's My Schedule?"

**Purpose**: Adaptive scheduling based on current state

**What It Does**:
- Checks current energy/mood/pain levels
- Reviews today's priorities
- Considers historical patterns
- Applies neurodivergent-friendly principles
- Generates optimized schedule
- Respects boundaries (5:15pm hard stop)
- Adjusts if mid-day energy changes

**Example Response**:
> "Based on your current energy (6/10) and that it's Saturday, here's your optimized schedule:
>
> **Morning (Now - 12:30pm)**:
> - 9:45-11:30am: Job search time
>   Focus: InnovateCo application (high priority)
>   You have 90 minutes of moderate-energy focus time
>
> **Midday (12:30-2:00pm)**:
> - Garden lunch break
>   Purpose: Sensory regulation, movement, midday reset
>
> **Afternoon (2:00-5:15pm)**:
> - 2:00-4:30pm: Certification study
>   Focus: Data Management module (exam in 13 days)
>   Moderate-energy task, aligns with afternoon capacity
>
> **Evening Boundary**:
> - 5:15pm: HARD STOP
>   No exceptions. This protects your sustainability.
>
> **Energy Check-In**: I'll remind you at 3pm to reassess. If energy drops below 5, we'll switch to lighter tasks.
>
> This schedule honors your energy, priorities, and boundaries. Sound good?"

---

## 🔄 Integration with PWA (Future)

### Current State (This Weekend)
- Voice commands are standalone
- Use Claude API directly
- Don't sync with PWA (yet)
- Still provide immediate value

### Next Week (Integration)
- Voice commands can update PWA data
- PWA can export context for voice commands
- Bidirectional sync via cloud or local file
- Single source of truth

### How Integration Will Work
```
Voice Command: "Log my energy: 6"
        ↓
Calls Claude API (gets insight)
        ↓
Writes to shared JSON file or API endpoint
        ↓
PWA detects new data
        ↓
Imports to IndexedDB
        ↓
Dashboard updates automatically
```

---

## 🧪 Testing Your Commands

### Test Plan (This Weekend)

**Test Each Command**:
1. Speak the command clearly
2. Verify phone hears correctly
3. Check response is relevant
4. Confirm Claude used correct context
5. Note any issues

**Test Scenarios**:
- Morning (9am): "Good morning, Claude"
- Mid-morning (10am): "Run job search routine"
- Afternoon (2pm): "Log my energy"
- Evening (7pm): "Celebrate today's win"
- Anytime: "What's my schedule?"

**Success Criteria**:
- ✅ All 5 commands respond within 5 seconds
- ✅ Responses are personalized and relevant
- ✅ No API errors
- ✅ Voice quality is clear and natural
- ✅ You feel supported by the system

---

## 🐛 Troubleshooting

### Common Issues

**Issue**: "Shortcut failed to run"
- **Fix**: Check API key is correct (no spaces, full key)
- **Fix**: Verify internet connection
- **Fix**: Check Anthropic API status

**Issue**: "Response is generic, not personalized"
- **Fix**: Ensure context template is included in request
- **Fix**: Verify skills are referenced in prompt
- **Fix**: Check date/time is being passed

**Issue**: "Voice recognition fails"
- **Fix**: Speak clearly and slowly
- **Fix**: Reduce background noise
- **Fix**: Try typing command instead (for testing)

**Issue**: "API rate limit exceeded"
- **Fix**: Claude API allows 50 requests/min (unlikely to hit)
- **Fix**: Wait 60 seconds and try again
- **Fix**: Check for infinite loops in shortcut

---

## 📊 Expected Costs

### Claude API Pricing
- Model: Claude Sonnet 4
- Input: ~$3 per 1M tokens
- Output: ~$15 per 1M tokens

### Typical Command Costs
- "Good morning": ~1,000 tokens total ≈ $0.015 per call
- "Job search routine": ~1,500 tokens ≈ $0.02 per call
- "Log energy": ~500 tokens ≈ $0.005 per call
- "Celebrate win": ~800 tokens ≈ $0.01 per call
- "What's my schedule": ~1,200 tokens ≈ $0.015 per call

### Monthly Estimate
- **Usage**: 5 commands/day × 30 days = 150 calls/month
- **Cost**: ~$2-3 per month

**Very affordable for the value!**

---

## 🚀 Next Steps

### This Weekend (Nov 16-17)
1. ✅ Read this README
2. ⏳ Choose your platform (iOS or Android)
3. ⏳ Open the platform-specific guide
4. ⏳ Set up first command: "Good morning, Claude"
5. ⏳ Test and refine
6. ⏳ Set up remaining 4 commands
7. ⏳ Use them Sunday morning!

### Next Week (Nov 18-24)
1. Integrate with PWA
2. Add data sync
3. Expand to more commands
4. Build custom workflows

---

## 📚 Additional Resources

- `ios-shortcuts.md` - Complete iOS setup guide
- `android-assistant.md` - Complete Android setup guide
- `claude-prompts.md` - Prompt templates for each command
- `context-template.md` - Context format for API calls

---

**Ready to get started? Open your platform-specific guide and let's build your first voice command!** 🎤✨
