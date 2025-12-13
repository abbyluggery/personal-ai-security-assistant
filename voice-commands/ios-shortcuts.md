# iOS Shortcuts Setup Guide
## 5 Core Voice Commands for Holistic Claude Assistant

**Platform**: iPhone (iOS 13+)
**App**: Shortcuts (pre-installed)
**Setup Time**: ~30 minutes total (6 minutes per command)
**Difficulty**: Beginner-friendly

---

## 🎯 Quick Start Checklist

- [ ] Have Shortcuts app installed (should be pre-installed on iOS)
- [ ] Have Claude API key ready (provided below)
- [ ] Have ~30 minutes to set up all 5 commands
- [ ] Test each command after setup

---

## 🔑 Your Claude API Key

**You need to insert your Claude API key in the setup steps below.**

To get your API key:
1. Go to https://console.anthropic.com/
2. Navigate to API Keys
3. Create a new key or copy your existing key
4. Use it in the setup steps marked with `YOUR_CLAUDE_API_KEY`

**⚠️ Security Note**: Your API key will be stored locally on your iPhone only. Not synced to iCloud unless you choose to sync Shortcuts.

---

## 📱 Command 1: "Good Morning, Claude"

### Purpose
Start your day with a personalized holistic overview including schedule, job search status, and daily affirmation.

### Setup Instructions

1. Open **Shortcuts** app
2. Tap **+** (top right) to create new shortcut
3. Name it: **"Good Morning Claude"**
4. Add actions in this order:

#### Action 1: Get Current Date/Time
- Search for: "Date"
- Add: **"Current Date"**
- Format: **"Custom"**
- Format String: `EEEE, MMMM d, yyyy 'at' h:mm a`
- This gives: "Saturday, November 16, 2025 at 9:45 AM"

#### Action 2: Set Variable (for date)
- Search for: "Set Variable"
- Add: **"Set variable"**
- Name it: **"CurrentDateTime"**
- Input: Current Date (from previous action)

#### Action 3: Text (Build Claude Prompt)
- Search for: "Text"
- Add: **"Text"**
- Paste this prompt:

```
You are Abby's personal holistic Claude assistant. Use all 12 skills with awareness of her neurodivergent needs (ADHD, Bipolar), job search goals ($155K manifestation), and daily routine preferences.

Current Context:
- Date/Time: [CurrentDateTime]
- Command: Good Morning Claude
- User: Abby Luggery
- Purpose: Daily holistic overview

Using the following skills:
- personal-manifestation-context
- daily-routine-preferences
- jobsearch
- neurodivergent-job-search
- achievement-tracking

Provide a personalized good morning message that includes:

1. Warm greeting with today's date and day of week
2. Energy pattern prediction for this day (Thursdays typically high-energy)
3. Optimized schedule recommendation based on:
   - Job search priorities (check for new high-fit roles)
   - Certification deadline (Nov 9, 2025 - Salesforce Admin)
   - Wellness boundaries (5:15pm hard stop, garden breaks)
   - Current manifestation goals ($155K salary target)
4. Job search update if any pending actions
5. Today's affirmation related to manifestation goals
6. Gentle reminder of boundaries

Keep tone warm, encouraging, evidence-based, and neurodivergent-affirming.
Limit response to ~200 words for voice delivery.
```

- Replace `[CurrentDateTime]` with: Tap and select **"CurrentDateTime"** variable

#### Action 4: Set Variable (for prompt)
- Add: **"Set variable"**
- Name it: **"Prompt"**

#### Action 5: Get Contents of URL (Claude API Call)
- Search for: "URL"
- Add: **"Get Contents of URL"**
- URL: `https://api.anthropic.com/v1/messages`
- Method: **POST**
- Headers:
  - `x-api-key`: `YOUR_CLAUDE_API_KEY` (paste your actual API key here)
  - `anthropic-version`: `2023-06-01`
  - `content-type`: `application/json`
- Request Body: **JSON**
- JSON:
```json
{
  "model": "claude-sonnet-4-20250514",
  "max_tokens": 1024,
  "messages": [
    {
      "role": "user",
      "content": "Prompt"
    }
  ]
}
```
  - Replace `"Prompt"` with the **Prompt** variable

#### Action 6: Get Dictionary from Input
- Add: **"Get Dictionary from Input"**
- Input: Contents of URL

#### Action 7: Get Value for Key
- Add: **"Get Dictionary Value"**
- Key: `content`

#### Action 8: Get Item from List
- Add: **"Get Item from List"**
- Get: **First Item**
- Input: Dictionary Value

#### Action 9: Get Value for Key (again)
- Add: **"Get Dictionary Value"**
- Key: `text`

#### Action 10: Speak Text
- Add: **"Speak Text"**
- Text: Dictionary Value (from previous step)
- Language: **English (US)**
- Rate: **Normal** (or adjust to your preference)
- Pitch: **Normal**
- Wait Until Finished: **Yes**

#### Action 11: Show Result
- Add: **"Show Result"**
- Input: Dictionary Value
- (This shows the text on screen for reference)

### Enable Siri Activation

1. Tap the shortcut name at the top
2. Tap **"Add to Siri"**
3. Record phrase: **"Good morning Claude"** or **"Hey Claude, good morning"**
4. Tap **Done**

### Test It!

Say: **"Hey Siri, good morning Claude"**

Expected: Siri responds with personalized morning briefing including schedule, job search update, and affirmation.

---

## 📱 Command 2: "Run Job Search Routine"

### Purpose
Get AI-powered analysis of new job opportunities with neurodivergent-friendly filtering and fit scores.

### Setup Instructions

1. Create new shortcut: **"Job Search Routine"**
2. Follow same structure as Command 1, but use this prompt:

```
You are Abby's job search AI assistant. Using the jobsearch and neurodivergent-job-search skills:

Current Context:
- Date/Time: [CurrentDateTime]
- Command: Run Job Search Routine
- Current Status: 12 active applications, 1 phone screen scheduled
- Manifestation Goal: $155K base salary (realistic path: $85-110K first)
- Required: Remote, flexible schedule, neurodivergent-friendly
- Expertise: Salesforce Admin, Agentforce Specialist, 99% data integrity

Task: Provide a job search briefing that includes:

1. Current application status summary
2. (Simulated) New high-fit opportunities - create 2-3 fictional but realistic Salesforce roles that would fit Abby's criteria:
   - Company name
   - Position title
   - Salary range
   - Remote/flexibility status
   - Fit score (1-10) with reasoning
   - Green flags (ND-friendly indicators)
   - Yellow/red flags if any
3. Top recommendation with reasoning
4. Estimated time needed for application
5. Next actionable step

Use neurodivergent-affirming language. Be specific and actionable.
Limit to ~250 words for voice delivery.

Note: This is a demonstration - real integration will pull from live job boards.
```

3. Same API call structure
4. Add to Siri with phrase: **"Run job search routine"** or **"Check job opportunities"**

### Test It!

Say: **"Hey Siri, run job search routine"**

Expected: AI-generated job opportunities with fit scores and recommendations.

---

## 📱 Command 3: "Log My Energy"

### Purpose
Quick wellness check-in for energy, mood, and pain tracking.

### Setup Instructions

1. Create new shortcut: **"Log Energy"**
2. Add these actions:

#### Actions 1-2: Get current date/time (same as before)

#### Action 3: Ask for Input
- Add: **"Ask for Input"**
- Question: **"On a scale of 1-10, what's your energy level right now?"**
- Input Type: **Number**
- Default Answer: (leave blank)

#### Action 4: Set Variable
- Name: **"EnergyLevel"**

#### Action 5: Ask for Input
- Question: **"How about your mood? 1-10"**
- Input Type: **Number**

#### Action 6: Set Variable
- Name: **"MoodLevel"**

#### Action 7: Ask for Input
- Question: **"And your pain level? 1-10"**
- Input Type: **Number**

#### Action 8: Set Variable
- Name: **"PainLevel"**

#### Action 9: Text (Build Prompt)
```
You are Abby's wellness tracking AI. Using the neurodivergent-therapy-support and daily-routine-preferences skills:

Current Context:
- Date/Time: [CurrentDateTime]
- Command: Log Energy Check-In
- Data Reported:
  - Energy: [EnergyLevel]/10
  - Mood: [MoodLevel]/10
  - Pain: [PainLevel]/10

Task: Analyze this check-in and provide:

1. Acknowledge the levels
2. Pattern recognition (e.g., "This matches your typical Saturday afternoon pattern" or "This is lower than usual for this time")
3. Schedule adjustment recommendation if needed:
   - If energy <5: Suggest switching to "minimum viable day" mode
   - If pain >7: Recommend extra garden breaks or rest
   - If mood <4: Offer grounding exercises
4. Brief encouragement (neurodivergent-affirming, no toxic positivity)

Keep response brief (~150 words) for voice delivery.
Note: Future version will log to database for trend analysis.
```

- Replace [CurrentDateTime], [EnergyLevel], [MoodLevel], [PainLevel] with respective variables

#### Actions 10-17: Same Claude API call structure as Command 1

3. Add to Siri: **"Log my energy"** or **"Energy check-in"**

### Test It!

Say: **"Hey Siri, log my energy"**

Expected: Interactive prompts for energy/mood/pain, then AI analysis and recommendations.

---

## 📱 Command 4: "Celebrate Today's Win"

### Purpose
Achievement tracking with evidence-based encouragement to combat imposter syndrome.

### Setup Instructions

1. Create shortcut: **"Celebrate Win"**
2. Actions:

#### Actions 1-2: Get current date/time

#### Action 3: Ask for Input
- Question: **"What's today's win? Big or small, progress is progress!"**
- Input Type: **Text**
- Default Answer: (leave blank)

#### Action 4: Set Variable
- Name: **"TodaysWin"**

#### Action 5: Text (Prompt)
```
You are Abby's achievement tracking AI. Using the achievement-tracking and personal-manifestation-context skills:

Current Context:
- Date/Time: [CurrentDateTime]
- Command: Celebrate Today's Win
- Win Reported: [TodaysWin]
- Job Search Status: 12 applications this month (target: 5-15) ✅
- Routine Streak: 22 days of morning foundation routine
- Manifestation Goals: $155K salary, remote work, neurodivergent-friendly culture

Task: Provide genuine celebration that includes:

1. Immediate affirmation of the win
2. Connect this win to larger goals:
   - How does this build toward $155K manifestation?
   - How does this demonstrate competence?
   - What pattern of strength does this show?
3. Evidence-based confidence building:
   - Specific facts that counter imposter syndrome
   - Concrete proof of progress
4. Add this to evidence journal (conceptually)
5. Warm closing encouragement

Use neurodivergent-affirming language. No toxic positivity - ground in facts and evidence.
~200 words for voice delivery.
```

#### Actions 6-13: Same API call structure

3. Add to Siri: **"Celebrate today's win"** or **"Log my win"**

### Test It!

Say: **"Hey Siri, celebrate today's win"**

Expected: Prompt for your win, then evidence-based celebration and encouragement.

---

## 📱 Command 5: "What's My Schedule?"

### Purpose
Adaptive scheduling based on current energy and priorities.

### Setup Instructions

1. Create shortcut: **"My Schedule"**
2. Prompt:

```
You are Abby's adaptive scheduling AI. Using daily-routine-preferences and personal-manifestation-context skills:

Current Context:
- Date/Time: [CurrentDateTime]
- Command: What's My Schedule?
- Assume current energy: moderate (6/10) - (future: will integrate real-time data)
- Job Search: Active - 3 new roles to review
- Certification: Salesforce Admin exam in 13 days (Nov 9, 2025)
- Boundaries: 5:15pm hard stop (non-negotiable)

Task: Generate today's optimized schedule that includes:

1. Current status update (morning routine, energy)
2. Time blocks optimized for:
   - Job search (best time: 9:45-11:30am on Thursdays)
   - Certification study (moderate energy needed)
   - Garden breaks (sensory regulation)
   - Hard stop at 5:15pm
3. For each block:
   - Time range
   - Activity/focus
   - Purpose/reasoning
4. Energy check-in reminder (suggest 3pm check)
5. Adjustment protocol (if energy drops, what changes)

Consider day of week patterns:
- Thursdays: typically high energy
- Mondays: slow start, no meetings before 10am
- Weekends: flexible, recovery-focused

~250 words for voice delivery.
```

3. Same API structure
4. Add to Siri: **"What's my schedule?"** or **"Show my schedule"**

### Test It!

Say: **"Hey Siri, what's my schedule?"**

Expected: Personalized daily schedule optimized for your energy and priorities.

---

## 🎨 Customization Options

### Adjust Voice Speed/Pitch

In the **"Speak Text"** action:
- **Rate**:
  - **Slow**: Better for complex information
  - **Normal**: Standard (recommended)
  - **Fast**: If you prefer quicker delivery
- **Pitch**:
  - **Low**: More serious tone
  - **Normal**: Neutral (recommended)
  - **High**: More upbeat

### Adjust Response Length

In each prompt, modify:
- **~150 words**: Very brief (1 minute spoken)
- **~200 words**: Brief (1.5 minutes) ← Recommended
- **~250 words**: Moderate (2 minutes)
- **~300 words**: Detailed (2.5 minutes)

### Add Background Music (Optional)

After **"Speak Text"**, add:
- **"Play Music"** (Apple Music)
- Choose a calming playlist
- Can help with sensory regulation

---

## 🔄 Integration with PWA (Coming Next Week)

### Current State
- Voice commands are standalone
- Use Claude API directly
- No data persistence yet

### Next Week: Adding Data Sync

We'll add these actions to each command:

#### After getting Claude's response:

1. **Save File** action
   - File name: `voice-command-log.json`
   - Location: iCloud Drive / NeuroThrive folder
   - Content:
   ```json
   {
     "timestamp": "[CurrentDateTime]",
     "command": "Good Morning",
     "input": "[user input if any]",
     "response": "[Claude response]",
     "data": {
       "energy": "[EnergyLevel]",
       "mood": "[MoodLevel]",
       "pain": "[PainLevel]",
       "win": "[TodaysWin]"
     }
   }
   ```

2. **Append to File** (not overwrite)

3. PWA will read this file and import to IndexedDB

This creates a sync mechanism without needing a backend server!

---

## 🐛 Troubleshooting

### Issue: "Could not communicate with Shortcuts"
**Fix**: Check internet connection

### Issue: "Invalid API response"
**Fix**:
1. Verify API key is correct (copy-paste from this doc)
2. Check for extra spaces in API key
3. Verify headers are exactly as shown

### Issue: "Response is too generic"
**Fix**:
1. Ensure all variables are correctly inserted into prompt
2. Check that date/time is being captured
3. Verify skills are mentioned in prompt

### Issue: Siri doesn't recognize command
**Fix**:
1. Re-record Siri phrase
2. Speak clearly and slowly
3. Try alternative phrasing

### Issue: Voice response is cut off
**Fix**:
1. Reduce response length in prompt (ask for ~150 words)
2. Check "Wait Until Finished" is enabled
3. Verify phone volume is up

---

## 📊 Testing Checklist

- [ ] Command 1: "Good morning Claude" - Responds with personalized briefing
- [ ] Command 2: "Run job search routine" - Provides job opportunities
- [ ] Command 3: "Log my energy" - Asks for levels, provides analysis
- [ ] Command 4: "Celebrate today's win" - Asks for win, gives encouragement
- [ ] Command 5: "What's my schedule?" - Provides optimized schedule

- [ ] All responses are personalized (include your name, goals, etc.)
- [ ] All responses are spoken aloud clearly
- [ ] No API errors
- [ ] Commands respond within 5 seconds
- [ ] You feel supported by the responses

---

## 🚀 What's Next?

### This Weekend
✅ Get all 5 commands working
✅ Test them in real scenarios
✅ Note what works and what needs adjustment

### Next Week
⏳ Add data logging to files
⏳ Integrate with PWA
⏳ Expand to more commands
⏳ Build custom workflows

---

## 💡 Advanced Tips

### Create Shortcuts for Specific Scenarios

**"Interview Prep Mode"**
- Prompt Claude to help prepare for specific interview
- Include company research
- Generate STAR method examples

**"Energy Crisis Protocol"**
- Triggered when energy <4
- Provides immediate grounding exercise
- Adjusts schedule to minimum viable day
- Reminds of self-compassion

**"Weekly Review"**
- Every Sunday evening
- Summarizes week's wins
- Analyzes patterns
- Sets intentions for next week

### Chain Shortcuts Together

Create a **"Morning Routine"** shortcut that runs:
1. "Good morning Claude" (overview)
2. Starts your favorite morning playlist
3. Sets timer for mindfulness (10 min)
4. When timer ends → "What's my schedule?"

---

## 📞 Need Help?

If you get stuck:
1. Check the Troubleshooting section above
2. Review the example shortcuts again
3. Verify your API key is correct
4. Test with simpler prompts first

Remember: The goal this weekend is to get them working, even if imperfect. We'll refine next week!

---

**You've got this! Start with "Good morning Claude" and go from there.** ☀️✨
