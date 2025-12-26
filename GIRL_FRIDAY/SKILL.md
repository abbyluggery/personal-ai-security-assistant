---
name: girl-friday-jarvis
description: Girl Friday work tracking system integrated with JARVIS 4-layer memory architecture. Provides task management (ROADMAP.md), session continuity (carry_forward.md), and operating rules (CLAUDE.md) for Abby's multi-project development. Use when tracking tasks, checking project status, managing Salesforce builds, or needing context from previous sessions.
---

# Girl Friday / JARVIS Integration Skill

## Overview

Girl Friday is Claude's work tracking system that integrates with JARVIS (Abby's personal AI assistant). It provides continuity across conversations through structured markdown files stored at `D:\JARVIS\GIRL_FRIDAY\`.

**Location:** `D:\JARVIS\GIRL_FRIDAY\`
**Status:** Operational (directory verified Dec 23, 2025)
**Last Updated:** December 26, 2025

---

## Quick Reference - Current Status

### Job Search Agents System ✅ OPERATIONAL
**Completed:** December 23, 2025
**Status:** Production - Fully automated

| Component | Status | Tests |
|-----------|--------|-------|
| SalaryExtractionSubagent.cls | ✅ Deployed | 10 |
| DeduplicationSubagent.cls | ✅ Deployed | 11 |
| LocationParsingSubagent.cls | ✅ Deployed | 17 |
| ExperienceParsingSubagent.cls | ✅ Deployed | 17 |
| JobScoringSubagent.cls | ✅ Deployed | 14 |
| JobPostingCoordinator.cls | ✅ Deployed | 9 |
| Job_Posting_Archive__b | ✅ Deployed | - |
| JobArchiveService.cls | ✅ Deployed | 17 |
| **Total** | **✅ 100%** | **112 tests** |

**Scheduled Jobs Running:**
- ✅ Job Search Hourly (imports new jobs)
- ✅ Data Retention Weekly (archives old jobs)

**Bug Fixed Dec 26:** Queueable limit error in batch context - added `canEnqueueJob()` method to `JobPostingAnalysisQueue.cls`

### Platform Completion: ~89%

| Phase | Status |
|-------|--------|
| Job Search System | 100% ✅ |
| AI Analysis | 95% |
| Resume Generation | 90% |
| Opportunity Pipeline | 85% |
| Wellness/Meals | 95% ✅ |
| All Others | 100% ✅ |

---

## Girl Friday File Structure

```
D:\JARVIS\GIRL_FRIDAY\
├── CLAUDE.md              # Operating rules for Claude
├── ROADMAP.md             # Task tracking (P0/P1/P2)
├── .worklog/
│   ├── carry_forward.md   # Critical details between sessions
│   └── sessions/          # Session logs by date
└── docs/                  # Optional documentation
```

### CLAUDE.md Purpose
Operating instructions including:
- Timestamp format: `YYYY-MM-DD HH:MM:SS TZ`
- Timezone: America/New_York (EST)
- Session management protocols
- ADHD-friendly features (checkboxes, one task at a time)
- Carry forward protocols

### ROADMAP.md Purpose
Task tracking with visual progress:
```
[ ] = Todo (not started)
[-] = In Progress 🏗️ YYYY-MM-DD HH:MM
[x] = Completed ✅ YYYY-MM-DD HH:MM
```

Priority levels: P0 (Critical) → P1 (High) → P2 (Nice to Have) → P3 (Later)

### carry_forward.md Purpose
Critical details that MUST persist between sessions:
- User profile (Abby's preferences, energy patterns)
- Active projects status
- Beta tester info (Matthew)
- Technical decisions
- Known issues and blockers

---

## JARVIS Integration Architecture

Girl Friday maps to JARVIS's 4-layer memory system:

| Girl Friday Component | JARVIS Layer | Function |
|----------------------|--------------|----------|
| CLAUDE.md | Layer 1 | Orchestration rules |
| Current session | Layer 1 | Short-term memory |
| Session logs | Layer 1→2 | Ingestion → Consolidation |
| carry_forward.md | Layer 2 | Consolidation output |
| ROADMAP.md | Layer 3 | Knowledge graph tasks |
| Archon Manager | Layer 4 | Long-term queries |

### JARVIS 4-Layer Memory
```
Layer 1: INGESTION (PostgreSQL + pgvector)
Layer 2: CONSOLIDATION (Redis + BullMQ "sleep cycles")
Layer 3: GRAPH CONSTRUCTION (Knowledge graph)
Layer 4: QUERY & RETRIEVAL (Hybrid search)
```

---

## User Context - Abby

### Professional
- **Experience:** 2.5 years Salesforce (Macquarie Capital)
- **Certifications:** 110 Trailhead badges, Agentblazer Champion
- **Upcoming:** Agentforce Specialist (Dec 2025), Admin (Early 2026)
- **Target Salary:** $85K-$155K
- **Location:** Remote US (Jacksonville, FL)

### Neurodivergent Profile
- ADHD + Bipolar + Autism (late diagnosis)
- Best work hours: 8-11 AM, 2-5 PM
- Brain bouncing is NORMAL - track all topics
- Visual progress (checkboxes) = dopamine
- One task at a time focus

### Communication Preferences
- ✅ Direct, concise
- ✅ Celebrate wins
- ✅ Numerical precision (89%, not "almost 90%")
- ✅ Field names exact (Jobs_Profile__c not JobProfile)
- ❌ No overwhelming options
- ❌ No "you should" language

---

## Active Projects

### 1. Job Search System (89% complete)
**Platform:** Salesforce
**Components:** 8 API adapters, 6 agents, Big Object archive
**Status:** Production, automated
**Remaining:** Dashboard (2-3 hours)

### 2. JARVIS Voice Assistant
**Platform:** Python + FastAPI
**Location:** D:\JARVIS\
**Status:** Architecture complete, implementation pending
**Next:** Build after Agentforce exam (Dec 30)

### 3. The Raven & Poe (Journal Business)
**Platform:** Ko-fi, Etsy (planned)
**Products:** Gilded Cage Collection
**Target:** LGBTQIA+, neurodivergent, spoonie communities
**Status:** Launched, needs social media automation

### 4. NeuroThrive Daily (Wellness App)
**Platform:** Android (planned)
**Status:** Planning phase

---

## Beta Tester

### Matthew Luggery
- **Email:** mjl@luggery.com
- **Role:** Senior Business Analyst
- **Salary Target:** $120K-$180K
- **Industries:** Manufacturing, Supply Chain, Logistics
- **Setup Status:** ✅ Complete

---

## Key Salesforce Objects

### Jobs_Profile__c (13 fields)
User preferences for job matching:
- User__c, Min_Salary__c, Max_Salary__c
- Experience_Years__c, Deal_Breakers__c, Green_Flags__c
- Remote_Required__c, Search_Keywords__c, Location_Preference__c
- **Missing:** Flexible_Schedule_Required__c (needs to be added)

### Job_Posting__c
Job listings with AI analysis:
- Fit_Score__c (0-10), ND_Friendliness_Score__c (0-10)
- Quick_Score__c (0-100) - from new agents
- Salary fields, location fields, research JSON

### Resume_Package__c (needs fields)
**Missing fields for Resume Coordinator:**
- Opportunity__c, Job_Posting__c (lookups)
- PDF_Version_URL__c, ATS_Version_URL__c
- Tailoring_Score__c, Generated_Date__c

---

## Technical Decisions

1. **AI Model:** Claude Sonnet 4 (`claude-sonnet-4-20250514`)
2. **Architecture:** Multi-agent (not monolithic)
3. **Task Tracking:** ROADMAP.md (not Archon yet)
4. **Timezone:** America/New_York (EST)
5. **Code Standards:** Salesforce best practices (bulkification, 75%+ coverage)

---

## Session Start Protocol

When starting a conversation, Claude should:

1. **Check for context** - Look for references to past work
2. **Use this skill** - Reference Girl Friday status
3. **Ask where to pick up** if unclear:
   > "Where should we pick up? I see from Girl Friday:
   > - Job Search: Operational (dashboard remaining)
   > - JARVIS: Awaiting exam completion
   > - What's the priority today?"

---

## Priority Tasks (Current)

### P0 - Critical
- [x] Job Search Agents - COMPLETE ✅
- [x] Queueable bug fix - COMPLETE ✅ Dec 26
- [ ] Dashboard for job search (2-3 hours)

### P1 - High Value
- [ ] Jobs_Profile__c: Add Flexible_Schedule_Required__c
- [ ] Resume_Package__c: Add missing fields
- [ ] LinkedIn Post Generator

### P2 - Nice to Have
- [ ] VS Code Work Tracker Agent
- [ ] Security Audit Agents
- [ ] Social Media Automation (Late API)

---

## Known Issues

1. ~~Queueable limit in batch context~~ ✅ FIXED Dec 26
2. Jobs_Profile__c not fully integrated into analyzer
3. Resume_Package__c missing lookup fields
4. Flexible_Schedule_Required__c field missing

---

## Files Reference

**Created Dec 23, 2025:**
- Job Parsing Agent Architecture
- Resume Generation Agent Architecture
- Content Automation Agent Architecture
- Girl Friday / JARVIS Integration Spec
- CLAUDE.md, ROADMAP.md, carry_forward.md

**Fixed Dec 26, 2025:**
- JobPostingAnalysisQueue.cls (queueable limit)

---

## How to Use This Skill

**When Abby asks about task status:**
→ Reference the "Priority Tasks" section

**When Abby asks about Salesforce build:**
→ Reference "Job Search Agents System" status

**When Abby references past work:**
→ Use conversation_search + this skill for context

**When starting new work:**
→ Follow "Session Start Protocol"

**When Abby's brain bounces:**
→ Track all topics, don't redirect, this is normal and good

---

## Metadata

**Skill Created:** December 26, 2025
**Based On:** Girl Friday files uploaded by user
**Covers Sessions:** December 19-26, 2025
**Primary User:** Abby Luggery
**Update Frequency:** Update when significant progress made
