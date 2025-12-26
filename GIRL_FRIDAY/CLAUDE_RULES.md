# CLAUDE.md - Operating Rules Reference

This is a reference copy of the CLAUDE.md file from D:\JARVIS\GIRL_FRIDAY\

## Critical Rules Summary

### Timestamps
- **Format:** `YYYY-MM-DD HH:MM:SS TZ`
- **Timezone:** America/New_York (EST)
- **Always get system time before creating/updating files**

### Session Management
```markdown
## Session Start: [TIMESTAMP]
**Working On:** [Topic]
**Context Loaded:** [Yes/No]
```

### Task Progress Tracking
```markdown
- [ ] Not started
- [-] In Progress 🏗️ YYYY-MM-DD HH:MM
- [x] Complete ✅ YYYY-MM-DD HH:MM
```

### Before Starting Work
1. ✅ Get system timestamp
2. ✅ Read ROADMAP.md
3. ✅ Read carry_forward.md
4. ✅ Confirm with Abby what to work on

### During Work
1. ✅ Update ROADMAP.md with timestamps
2. ✅ Save critical details to carry_forward.md

### After Completing Work
1. ✅ Update ROADMAP.md: `[-]` → `[x]` with completion timestamp
2. ✅ Update carry_forward.md with new critical details

## ADHD-Friendly Features

### Visual Progress
- Checkboxes = dopamine hits
- Timestamps = accountability
- "Recently Completed" section = validation

### One Task at a Time
```markdown
## RIGHT NOW (Only One Task)
- [-] Current task 🏗️

## UP NEXT (Pre-decided)
- [ ] Next task (no decision needed)
```

### Brain Bouncing Protocol
- ✅ This is NORMAL and GOOD
- ✅ Track all topics
- ❌ Don't redirect back to "original topic"
- ✅ Each topic is relevant even if connection isn't obvious

## Detail Retention Standards

**BAD:** "User wants to build agents"
**GOOD:** "User wants multi-agent job search with 4 specialists: SkillsParser, NDEvaluation, SalaryAnalysis, CompanyResearch"

**BAD:** "User has a journal business"  
**GOOD:** "The Raven & Poe, gothic digital planners, Ko-fi launched, target: LGBTQIA+/neurodivergent/spoonie"

**BAD:** "User is job searching"
**GOOD:** "Salesforce Admin/Developer, $85K-$155K, remote US, 2.5 years Macquarie, Agentforce Champion"

## File Locations

| File | Location | Purpose |
|------|----------|---------|
| CLAUDE.md | D:\JARVIS\GIRL_FRIDAY\ | Operating rules |
| ROADMAP.md | D:\JARVIS\GIRL_FRIDAY\ | Task tracking |
| carry_forward.md | D:\JARVIS\GIRL_FRIDAY\.worklog\ | Critical details |
| Session logs | D:\JARVIS\GIRL_FRIDAY\.worklog\sessions\ | Daily records |
