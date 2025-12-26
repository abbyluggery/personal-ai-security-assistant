# CLAUDE.md - Assistant Configuration for Abby's Projects
**Created:** 2025-12-23 17:55:25 UTC
**Last Updated:** 2025-12-23 17:55:25 UTC

---

## CRITICAL RULES: Timestamps & Date Management

### Rule 1: ALWAYS Use System Date/Time
Before creating ANY file or updating ANY document, I MUST:
```bash
date "+%Y-%m-%d %H:%M:%S %Z"
```

### Rule 2: Standard Timestamp Format
**Format:** `YYYY-MM-DD HH:MM:SS TZ`
**Example:** `2025-12-23 17:55:25 UTC`

**Use in:**
- All file headers
- ROADMAP.md task updates
- MASTER_TASK_LIST.md updates
- Documentation
- Code comments
- Conversation summaries

### Rule 3: File Headers (REQUIRED)
Every file I create MUST start with:
```markdown
# [Document Title]
**Created:** [System Timestamp]
**Last Updated:** [System Timestamp]
**Status:** [Active/Complete/On Hold]
```

### Rule 4: ROADMAP.md Timestamps
When updating tasks:
```markdown
- [-] **Task Name** 🏗️ 2025-12-23 17:55
  - Started: 2025-12-23 17:55:25 UTC
  - Status: In Progress
  
- [x] **Task Name** ✅ 2025-12-23 18:30
  - Completed: 2025-12-23 18:30:15 UTC
  - Duration: 35 minutes
```

### Rule 5: Conversation Session Headers
At the start of EVERY conversation, create session header:
```markdown
## Session Start: 2025-12-23 17:55:25 UTC
**Working On:** [Topic]
**Previous Session:** [Link to transcript if available]
**Context Loaded:** [Yes/No]
```

---

## Working Directory Structure

### Primary Files (Project Root)
```
/project-root/
├── ROADMAP.md              # Task tracking (I update this)
├── CLAUDE.md               # This file (rules for me)
├── MASTER_TASK_LIST.md     # Master task list (I maintain)
├── .worklog/               # Session logs directory
│   ├── 2025-12-23_session.md
│   ├── 2025-12-22_session.md
│   └── session_index.md
└── docs/                   # Documentation
    ├── architectures/
    ├── research/
    └── decisions/
```

### Session Log Format
File: `.worklog/YYYY-MM-DD_session.md`

```markdown
# Session Log: 2025-12-23
**Start Time:** 2025-12-23 17:55:25 UTC
**End Time:** [Updated at session end]
**Duration:** [Calculated]

## Topics Discussed
1. Date/timestamp automation
2. Working directory structure
3. Archon Manager setup

## Decisions Made
- [ ] Decision 1
- [ ] Decision 2

## Work Completed
- [x] Created CLAUDE.md with timestamp rules
- [x] Created working directory structure
- [ ] In Progress items...

## Carry Forward (CRITICAL DETAILS)
**DO NOT LOSE THESE:**
1. Jobs_Profile__c has 13 fields (listed in Dec 23 analysis)
2. Pinterest API already integrated in Salesforce
3. Matthew Luggery is beta tester (mjl@luggery.com)
4. Target salary: $85K min, $155K target
5. Current completion: 89% (per Dec 23 analysis)

## Files Created This Session
1. `/path/to/file1.md` - Purpose
2. `/path/to/file2.cls` - Purpose

## Next Session Priorities
1. Priority 1
2. Priority 2

## Context for Next Session
[Summary of where we left off]
```

---

## Roadmap Management

### BEFORE Starting Any Work
1. ✅ Get system timestamp: `date "+%Y-%m-%d %H:%M:%S %Z"`
2. ✅ Read ROADMAP.md
3. ✅ Read today's session log (if exists)
4. ✅ Read MASTER_TASK_LIST.md
5. ✅ Confirm with Abby what to work on

### DURING Work
1. ✅ Update ROADMAP.md with timestamps
2. ✅ Update session log with progress
3. ✅ Save critical details to "Carry Forward" section

### AFTER Completing Work
1. ✅ Update ROADMAP.md: `[-]` → `[x]` with completion timestamp
2. ✅ Update session log with final status
3. ✅ Update MASTER_TASK_LIST.md
4. ✅ Create "Next Session Priorities" section

### Progress Tracking Protocol
```markdown
## Task: [Task Name]
**Started:** 2025-12-23 17:55:25 UTC
**Status:** In Progress

### Subtasks
- [x] Subtask 1 ✅ 2025-12-23 18:00:00 UTC
- [-] Subtask 2 🏗️ 2025-12-23 18:05:00 UTC
- [ ] Subtask 3

### Time Tracking
- Research: 15 min
- Implementation: 30 min
- Testing: 10 min
**Total:** 55 min
```

---

## Critical Details Management (NO INFORMATION LOSS)

### Rule: Carry Forward File
File: `.worklog/carry_forward.md`

**Purpose:** Store critical details that MUST NOT be lost between sessions

```markdown
# Critical Details - Carry Forward
**Last Updated:** 2025-12-23 17:55:25 UTC

## System Context
- Platform: Salesforce Developer Edition
- Completion: 89% (as of Dec 23)
- Custom Objects: 37
- Apex Classes: 85+

## User Profile (Abby)
- Experience: 2.5 years Salesforce
- Target Role: Salesforce Admin/Developer
- Salary Target: $85K min, $155K goal
- Location: Remote US
- Neurodivergent: ADHD + Bipolar
- Energy Pattern: Best work 8-11 AM, 2-5 PM

## Active Projects
1. **Job Search System (89% complete)**
   - Issue: Job parsing difficult
   - Blocker: Jobs_Profile__c created but needs integration
   - Next: Build SalaryExtractionSubagent

2. **Resume Generation (90% complete)**
   - Has: ResumeGenerator.cls
   - Needs: Integration with multi-agent system

3. **Journal Business (The Raven & Poe)**
   - Pinterest API: Already integrated
   - Products: Gilded Cage Collection on Ko-fi
   - Target: LGBTQIA+, neurodivergent, spoonie communities

## Beta Testers
1. **Matthew Luggery**
   - Email: mjl@luggery.com
   - Role: Senior Business Analyst
   - Salary: $120K-$180K
   - Setup: Complete

## Key Objects & Fields
### Jobs_Profile__c (13 fields)
1. User__c (Lookup)
2. Min_Salary__c (Currency)
3. Max_Salary__c (Currency)
4. Experience_Years__c (Number)
5. Deal_Breakers__c (Long Text)
6. Green_Flags__c (Long Text)
7. Remote_Required__c (Checkbox)
8. Search_Keywords__c (Long Text)
9. Location_Preference__c (Text)
10. Name (Auto Number)
11. Owner, Created By, Last Modified By (Standard)

### Resume_Package__c (Needs Fields)
- Opportunity__c (Lookup) - NOT YET ADDED
- PDF_Version_URL__c (URL) - NOT YET ADDED
- ATS_Version_URL__c (URL) - NOT YET ADDED

## Technical Decisions
1. Use Claude Sonnet 4 for all AI agents
2. Use Late API for social media ($99/month)
3. ROADMAP.md for task tracking
4. Multi-agent architecture (not monolithic)

## Recent Completions (Last 7 Days)
- 2025-12-23: Job Parsing Agent Architecture
- 2025-12-23: Resume Generation Agent Architecture
- 2025-12-23: Content Automation Architecture
- 2025-12-23: Meal planning bug fix

## Known Issues
1. JobPostingAnalyzer.cls is monolithic (needs breaking up)
2. Salary parsing inconsistent across APIs
3. Duplicate jobs from multiple sources
4. Experience requirement parsing issues
```

---

## Conversation Continuity

### At Start of Each Session
```markdown
## Conversation Start Checklist
**Timestamp:** [System time]

- [ ] Read ROADMAP.md
- [ ] Read .worklog/carry_forward.md
- [ ] Read today's session log (if exists)
- [ ] Read MASTER_TASK_LIST.md
- [ ] Review previous session's "Next Priorities"
- [ ] Ask Abby: "Where should we pick up?"
```

### At End of Each Session
```markdown
## Conversation End Checklist
**Timestamp:** [System time]

- [ ] Update all timestamps in modified files
- [ ] Update ROADMAP.md with final status
- [ ] Update session log with completions
- [ ] Update carry_forward.md with any new critical details
- [ ] Create "Next Session Priorities"
- [ ] Confirm with Abby what's most important for next time
```

---

## Small Details That Make a Difference

### Examples of Details I Must Track
❌ **BAD:** "User wants to build agents"
✅ **GOOD:** "User wants to build multi-agent job search system with 4 specialist agents: SkillsParser, NDEvaluation, SalaryAnalysis, CompanyResearch. Each runs in parallel via @future callouts. Uses Jobs_Profile__c for personalization."

❌ **BAD:** "User has a journal business"
✅ **GOOD:** "User runs The Raven & Poe, gothic-inspired digital planners/journals. Launched Gilded Cage Collection on Ko-fi. Target: neurodivergent, LGBTQIA+, spoonie communities. Pinterest API already integrated. Needs automation for Instagram/Facebook via Late API ($99/month)."

❌ **BAD:** "User is job searching"
✅ **GOOD:** "User job searching for Salesforce Admin/Developer, $85K-$155K, remote US. 2.5 years experience at Macquarie Capital (99% data integrity, 1,000+ client records). Has beta tester Matthew Luggery (mjl@luggery.com, $120K-$180K, Senior BA). Agentforce Champion, 96 Trailhead badges."

---

## Timestamp Automation Scripts

### Get Current Timestamp
```bash
# Full timestamp
date "+%Y-%m-%d %H:%M:%S %Z"

# Short format (for ROADMAP)
date "+%Y-%m-%d %H:%M"

# Date only
date "+%Y-%m-%d"

# Time only
date "+%H:%M:%S"
```

### Update File Header
```bash
# Get current timestamp
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S %Z")

# Update Last Updated line
sed -i "s/\*\*Last Updated:\*\*.*/\*\*Last Updated:\*\* $TIMESTAMP/" filename.md
```

---

## ADHD-Friendly Features

### 1. Visual Progress (Checkboxes)
```markdown
- [ ] Not started (anxiety-inducing)
- [-] In progress 🏗️ (feels good!)
- [x] Complete ✅ (dopamine hit!)
```

### 2. One Task at a Time
```markdown
## RIGHT NOW (Only One Task)
- [-] Current task 🏗️ 2025-12-23 17:55

## UP NEXT (Pre-decided)
- [ ] Next task (no decision needed)

## LATER (Out of mind)
- [ ] Future task
```

### 3. Timestamps = Accountability
- Can't lose track of time
- Shows progress even on bad brain days
- Celebrates completed work

### 4. Session Logs = Offloaded Memory
- Don't need to remember what we discussed
- Search for "when did we talk about X?"
- Proof of productivity

---

## Integration with Claude Skills

### When Archon Manager is Added
```markdown
## Daily Workflow
1. Morning (9 AM):
   - I read: ROADMAP.md + carry_forward.md + session log
   - archon: get_next_task({ project_id })
   - Update ROADMAP with selected task
   - Start work

2. During Work:
   - archon: update_task({ task_id, status: 'doing' })
   - Update timestamps in real-time

3. End of Day (5 PM):
   - archon: update_task({ task_id, status: 'done' })
   - Update ROADMAP
   - Create session summary
```

---

## Error Prevention

### Before Creating ANY File
```bash
# 1. Get timestamp
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S %Z")

# 2. Verify file doesn't exist
ls -la filename.md

# 3. Create with header
cat > filename.md << EOF
# Title
**Created:** $TIMESTAMP
**Last Updated:** $TIMESTAMP
**Status:** Active

[Content]
EOF
```

### Before Updating ANY File
```bash
# 1. Get timestamp
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S %Z")

# 2. Backup current file
cp filename.md filename.md.backup

# 3. Update Last Updated timestamp
sed -i "s/\*\*Last Updated:\*\*.*/\*\*Last Updated:\*\* $TIMESTAMP/" filename.md

# 4. Make changes

# 5. Verify changes
diff filename.md.backup filename.md
```

---

## Priority: Girl Friday Setup

### Based on Abby's Decision
**Priority Order:**
1. Girl Friday Work Tracker (HIGHEST - quickest win)
2. Job Parsing Improvements
3. Resume Automation
4. LinkedIn/Blog Posts (affects job search)
5. Social Media (journal business) - LAST

**Next Step:** Set up Girl Friday work tracking system NOW.

---

**This file defines how I operate. I will follow these rules consistently.**
