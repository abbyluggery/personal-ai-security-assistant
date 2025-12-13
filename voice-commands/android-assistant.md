# Android Google Assistant Setup Guide
## 5 Core Voice Commands for Holistic Claude Assistant

**Platform**: Android (8.0+)
**App**: Google Assistant (pre-installed)
**Additional Apps**: IFTTT (free) OR Tasker ($3.49)
**Setup Time**: ~40 minutes total
**Difficulty**: Intermediate

---

## 🎯 Quick Start Checklist

- [ ] Have Android phone with Google Assistant
- [ ] Choose integration method (IFTTT or Tasker)
- [ ] Have Claude API key ready (provided below)
- [ ] Have ~40 minutes for setup
- [ ] Test each command after setup

---

## 🔑 Your Claude API Key

**You need to insert your Claude API key in the setup steps below.**

To get your API key:
1. Go to https://console.anthropic.com/
2. Navigate to API Keys
3. Create a new key or copy your existing key
4. Use it in the setup steps marked with `YOUR_CLAUDE_API_KEY`

---

## 🤔 Which Method Should You Choose?

### Option A: IFTTT (Easier, Cloud-Based)

**Pros**:
- ✅ Easier to set up (no coding)
- ✅ Free tier available
- ✅ Visual interface
- ✅ Web-based (access from anywhere)

**Cons**:
- ⚠️ API key stored in IFTTT's cloud
- ⚠️ Requires internet always
- ⚠️ Less customization
- ⚠️ Slower response time

**Best For**: Quick setup, less technical users

---

### Option B: Tasker (More Powerful, Local)

**Pros**:
- ✅ API key stays on your device
- ✅ More control and customization
- ✅ Can work offline (with cached responses)
- ✅ Faster response time

**Cons**:
- ⚠️ Costs $3.49 (one-time)
- ⚠️ Steeper learning curve
- ⚠️ Requires AutoVoice plugin ($2.99)
- ⚠️ More complex setup

**Best For**: Privacy-conscious, technical users

---

## 📱 Option A: IFTTT Setup

### Prerequisites

1. **Create IFTTT Account**:
   - Go to ifttt.com
   - Sign up (free tier is sufficient)
   - Connect Google Assistant

2. **Install IFTTT App** (optional):
   - Google Play Store → Search "IFTTT"
   - Install and log in

---

### Command 1: "Good Morning Claude"

#### Step 1: Create New Applet

1. Open IFTTT website or app
2. Click **"Create"**
3. Click **"If This"**

#### Step 2: Configure Trigger

1. Search for: **"Google Assistant"**
2. Choose: **"Say a simple phrase"**
3. Configure:
   - **What do you want to say?**: "Good morning Claude"
   - **Alternative 1**: "Hey Claude, good morning"
   - **Alternative 2**: "Morning briefing"
   - **What do you want the Assistant to say?**: "Getting your morning briefing from Claude..."

#### Step 3: Configure Action

1. Click **"Then That"**
2. Search for: **"Webhooks"**
3. Choose: **"Make a web request"**
4. Configure:

**URL**:
```
https://api.anthropic.com/v1/messages
```

**Method**: `POST`

**Content Type**: `application/json`

**Body**:
```json
{
  "model": "claude-sonnet-4-20250514",
  "max_tokens": 1024,
  "messages": [
    {
      "role": "user",
      "content": "You are Abby's personal holistic Claude assistant. Current time: {{CreatedAt}}. Provide a good morning briefing including: 1) Today's date and day of week 2) Energy prediction for today 3) Optimized schedule (job search 9:45-11:30am, garden break 12:30pm, certification study 2-5:15pm, hard stop 5:15pm) 4) Job search update (12 active applications, 1 phone screen scheduled) 5) Today's affirmation related to $155K manifestation goal 6) Boundary reminder (5:15pm hard stop). Keep response ~200 words for voice delivery. Use warm, neurodivergent-affirming tone."
    }
  ]
}
```

**Additional Configuration**:
- **Headers** (click "Add ingredient" for each):
  - **Header**: `x-api-key`
  - **Value**: `YOUR_CLAUDE_API_KEY` (paste your actual API key here)

  - **Header**: `anthropic-version`
  - **Value**: `2023-06-01`

  - **Header**: `content-type`
  - **Value**: `application/json`

#### Step 4: Add Response Notification

1. Click **"Add action"**
2. Search for: **"Notifications"**
3. Choose: **"Send a notification from the IFTTT app"**
4. Message: `{{Value}}` (this will contain Claude's response)

#### Step 5: Save and Test

1. Click **"Continue"**
2. Name it: **"Good Morning Claude"**
3. Click **"Finish"**
4. Test by saying: **"Hey Google, good morning Claude"**

**Note**: IFTTT doesn't support text-to-speech directly. You'll receive Claude's response as a notification. To hear it spoken:
- Use Google Assistant Routines (see below)
- OR install "Tasker" for better integration

---

### IFTTT Limitation Workaround: Google Assistant Routines

To get spoken responses with IFTTT:

1. Open **Google Home** app
2. Tap **"Routines"**
3. Tap **"+"** to create new routine
4. Configure:
   - **When**: "When I say 'Good morning Claude'"
   - **Then**:
     1. **Trigger IFTTT applet** (select your applet)
     2. **Wait**: 5 seconds
     3. **Read notification**: From IFTTT app

This will trigger IFTTT, wait for response, then read it aloud!

---

### Commands 2-5: Repeat for Other Commands

Use the same IFTTT structure but change:
- Trigger phrase
- Claude prompt in the body
- Applet name

**Command 2 - "Run job search routine"**:
```
Phrase: "Run job search routine"
Prompt: [Use prompt from claude-prompts.md]
```

**Command 3 - "Log my energy"**:
```
Phrase: "Log my energy"
Prompt: [Use prompt from claude-prompts.md]
Note: IFTTT limitation - can't ask follow-up questions
Workaround: Use Tasker OR create separate applets for each energy level
```

**Command 4 - "Celebrate today's win"**:
```
Phrase: "Celebrate today's win"
Prompt: [Adapt prompt - IFTTT can't capture custom input easily]
Workaround: Use pre-defined wins or Tasker for custom input
```

**Command 5 - "What's my schedule?"**:
```
Phrase: "What's my schedule?"
Prompt: [Use prompt from claude-prompts.md]
```

---

## 📱 Option B: Tasker Setup (Recommended for Full Features)

### Prerequisites

1. **Purchase and Install Tasker**:
   - Google Play Store → Search "Tasker"
   - Purchase ($3.49)
   - Install and grant permissions

2. **Install AutoVoice Plugin**:
   - Google Play Store → Search "AutoVoice"
   - Purchase ($2.99)
   - Install and link to Google Assistant

3. **Configure AutoVoice**:
   - Open AutoVoice app
   - Enable Google Assistant integration
   - Grant microphone permissions

---

### Command 1: "Good Morning Claude"

#### Step 1: Create New Task

1. Open **Tasker** app
2. Go to **"Tasks"** tab
3. Tap **"+"** to create new task
4. Name it: **"Good Morning Claude"**

#### Step 2: Add Actions to Task

**Action 1: Set Variable** (Current Date/Time)
- Action Category: **Variables**
- Action: **Variable Set**
- Name: `%CurrentDateTime`
- To: `%DATE %TIME`

**Action 2: HTTP Request** (Call Claude API)
- Action Category: **Net**
- Action: **HTTP Request**
- Method: `POST`
- URL: `https://api.anthropic.com/v1/messages`
- Headers:
  ```
  x-api-key:YOUR_CLAUDE_API_KEY
  anthropic-version:2023-06-01
  Content-Type:application/json
  ```
  (Replace `YOUR_CLAUDE_API_KEY` with your actual API key)
- Body:
  ```json
  {
    "model": "claude-sonnet-4-20250514",
    "max_tokens": 1024,
    "messages": [
      {
        "role": "user",
        "content": "You are Abby's personal holistic Claude assistant. Current time: %CurrentDateTime. Provide a good morning briefing including: 1) Today's date and day of week 2) Energy prediction 3) Optimized schedule 4) Job search update (12 applications, 1 phone screen) 5) Today's affirmation 6) 5:15pm boundary reminder. ~200 words, warm tone."
      }
    ]
  }
  ```
- Timeout: `30`
- Output Variable: `%ClaudeResponse`

**Action 3: JavaScript** (Parse JSON Response)
- Action Category: **Code**
- Action: **JavaScriptlet**
- Code:
  ```javascript
  var response = JSON.parse(global('ClaudeResponse'));
  var text = response.content[0].text;
  setGlobal('ClaudeText', text);
  ```

**Action 4: Say** (Speak Response)
- Action Category: **Alert**
- Action: **Say**
- Text: `%ClaudeText`
- Engine:Voice: **Default:Default**
- Stream: **Media**
- Respect Audio Focus: **Yes**

**Action 5: Notify** (Show Text)
- Action Category: **Alert**
- Action: **Notify**
- Title: `Claude: Good Morning`
- Text: `%ClaudeText`
- Icon: (choose any)

#### Step 3: Create Profile (Voice Trigger)

1. Go to **"Profiles"** tab
2. Tap **"+"** to create new profile
3. Name it: **"Good Morning Claude Trigger"**

**Context**:
- Select: **Event**
- Category: **Plugin**
- Plugin: **AutoVoice Recognized**
- Configuration:
  - **Command Filter**: `good morning claude`
  - **Exact Command**: **No**
  - **Use Regex**: **No**

**Link to Task**:
- Select the task you created: **"Good Morning Claude"**

#### Step 4: Test

1. Say: **"Hey Google, ask AutoVoice to good morning claude"**
2. OR: **"Hey Google, tell AutoVoice good morning claude"**

Expected: Claude responds with your morning briefing!

---

### Commands 2-5: Tasker Templates

Create similar tasks for each command. Here are the key differences:

#### Command 2: "Run Job Search Routine"

**Profile Trigger**: `run job search routine`
**Claude Prompt**: [Use full prompt from claude-prompts.md]
**Parse**: Same structure

#### Command 3: "Log My Energy"

**Profile Trigger**: `log my energy`
**Special Actions**:

**Before HTTP Request**, add:
- **Input Dialog**:
  - Title: `Energy Level`
  - Text: `On a scale of 1-10, what's your energy?`
  - Variable: `%EnergyLevel`

- **Input Dialog**:
  - Title: `Mood Level`
  - Text: `How about your mood? 1-10`
  - Variable: `%MoodLevel`

- **Input Dialog**:
  - Title: `Pain Level`
  - Text: `And pain level? 1-10`
  - Variable: `%PainLevel`

**Claude Prompt** (include variables):
```
Analyze this check-in: Energy %EnergyLevel/10, Mood %MoodLevel/10, Pain %PainLevel/10
[rest of prompt from claude-prompts.md]
```

#### Command 4: "Celebrate Today's Win"

**Profile Trigger**: `celebrate today's win`
**Before HTTP Request**:
- **Input Dialog**:
  - Title: `Today's Win`
  - Text: `What's today's win? Big or small!`
  - Variable: `%TodaysWin`

**Claude Prompt**:
```
Win reported: %TodaysWin
[rest of prompt from claude-prompts.md]
```

#### Command 5: "What's My Schedule?"

**Profile Trigger**: `what's my schedule`
**Claude Prompt**: [Use full prompt from claude-prompts.md]

---

## 🔄 Data Logging (Future Integration)

### Add to Each Tasker Task:

After receiving Claude's response, log to file for PWA sync:

**Action: Write File**
- File: `NeuroThrive/voice-commands.json`
- Append: **Yes**
- Add Newline: **Yes**
- Text:
```json
{
  "timestamp": "%TIMES",
  "command": "Good Morning",
  "input": {
    "energy": "%EnergyLevel",
    "mood": "%MoodLevel",
    "pain": "%PainLevel",
    "win": "%TodaysWin"
  },
  "response": "%ClaudeText"
}
```

This creates a log file that your PWA can import!

---

## 🎨 Customization Options

### Adjust Voice

In the **"Say"** action:
- **Engine**: Try different TTS engines (Google, Samsung, etc.)
- **Pitch**: 0.5-2.0 (1.0 is default)
- **Speed**: 0.5-2.0 (1.0 is default)

### Add Vibration Feedback

Before "Say" action, add:
- **Vibrate**
- Pattern: `200,500,200`
- (200ms on, 500ms off, 200ms on)

### Add Visual Notification

Customize the **Notify** action:
- **LED**: Choose color
- **Vibration**: Custom pattern
- **Sound**: Notification sound
- **Actions**: Add buttons like "More details"

---

## 🐛 Troubleshooting

### Issue: "AutoVoice didn't recognize command"
**Fix**:
- Open AutoVoice app → Natural Language
- Train with your voice
- Try alternative phrasings in Command Filter

### Issue: "HTTP Request failed"
**Fix**:
- Check API key (no extra spaces)
- Verify internet connection
- Check Claude API status

### Issue: "JSON Parse error"
**Fix**:
- Flash: `%ClaudeResponse` to see raw output
- Verify JSON structure
- Check for timeout (increase to 60 seconds)

### Issue: "Voice sounds robotic"
**Fix**:
- Install Google TTS (highest quality)
- Adjust speech rate to 0.9 (slightly slower)
- Use Media stream (better quality than notification stream)

---

## 📊 Comparison: IFTTT vs Tasker

| Feature | IFTTT | Tasker |
|---------|-------|--------|
| **Cost** | Free | $6.48 total |
| **Privacy** | Cloud storage | Local only |
| **Customization** | Limited | Extensive |
| **Input Prompts** | No | Yes |
| **Response Speed** | Slower | Faster |
| **Voice Output** | Via workaround | Native |
| **Data Logging** | Limited | Full control |
| **Ease of Setup** | Easier | Harder |
| **Best For** | Quick start | Full features |

---

## 🚀 Next Steps

### This Weekend
1. ✅ Choose your method (IFTTT or Tasker)
2. ⏳ Set up Command 1: "Good morning Claude"
3. ⏳ Test and refine
4. ⏳ Set up remaining 4 commands
5. ⏳ Use Sunday morning!

### Next Week
1. Add data logging
2. Integrate with PWA
3. Expand to more commands
4. Build custom workflows

---

## 💡 Advanced: Creating Custom Commands

Once you're comfortable, create commands like:

**"Interview Prep for [Company]"**
- Trigger: "Interview prep for %company"
- AutoVoice captures company name
- Claude researches company
- Generates STAR examples
- Creates interview strategy

**"Energy Crisis Protocol"**
- Trigger: "Energy crisis"
- Immediate grounding exercise
- Adjusts schedule to minimum viable
- Reminds of self-compassion

**"Weekly Review"**
- Trigger: "Weekly review"
- Scheduled for Sunday 8pm
- Summarizes week's data
- Identifies patterns
- Sets intentions

---

## 🔗 Resources

- **Tasker Wiki**: tasker.joaoapps.com/userguide/en/
- **AutoVoice Guide**: joaoapps.com/autovoice/
- **IFTTT Help**: help.ifttt.com
- **Claude API Docs**: docs.anthropic.com

---

**You're ready to build! Choose your method and start with "Good morning Claude".** 🤖✨
