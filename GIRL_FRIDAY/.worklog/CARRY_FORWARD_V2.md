# Carry Forward - Critical Details Reference

Last synced from D:\JARVIS\GIRL_FRIDAY\.worklog\carry_forward.md on December 26, 2025

---

## 🎉 LATEST STATUS - Job Search System OPERATIONAL

**Completed:** December 23, 2025, 22:07 EST
**Bug Fixed:** December 26, 2025 (Queueable limit)

### What's Running
- ✅ Job Search Hourly (automated)
- ✅ Data Retention Weekly (automated)
- ✅ 5-agent pipeline processing all jobs
- ✅ 112 tests passing (100%)

### Accomplishments (Dec 23)
1. Built 6 modular agents
2. Integrated archive retention
3. Integrated agents into production
4. Activated scheduled automation
5. Fixed multiple test failures
6. Verified production deployment

### Remaining
- ⏳ Dashboard (2-3 hours)

**Progress:** 75% (3 of 4 steps complete)

---

## 👤 User Profile - Abby

### Professional
- **Current Role:** Job searching (unemployed since March 2025)
- **Experience:** 2.5 years Salesforce at Macquarie Capital
- **Key Achievement:** 99% data integrity, 1,000+ client records
- **Target Salary:** $85K minimum, $155K goal
- **Location:** Remote US (Jacksonville, FL)

### Certifications
- 110 Trailhead Badges (Ranger Rank) - All earned March-Dec 2025
- Agentblazer Champion & Innovator Status ✅
- Agentforce Specialist - Exam December 30, 2025
- Administrator - Planned Early 2026

### Neurodivergent Profile
- ADHD (diagnosed)
- Bipolar disorder
- Autism spectrum (late diagnosis)
- CPTSD, Major Depressive Disorder, Anxiety

### Energy Patterns
- **Best hours:** 8-11 AM, 2-5 PM
- **Avoid:** Early morning meetings, late evening work
- **Brain bouncing:** Normal and productive - track all topics

### Communication Preferences
- ✅ Direct and concise
- ✅ Visual progress (checkboxes)
- ✅ Celebrate wins
- ✅ Numerical precision
- ❌ No overwhelming options
- ❌ No productivity guilt
- ❌ No "you should" language

---

## 👥 Beta Tester - Matthew Luggery

- **Email:** mjl@luggery.com
- **Role:** Senior Business Analyst
- **Industries:** Manufacturing, Supply Chain, Logistics, Tech
- **Salary Range:** $120,000 - $180,000
- **Location:** 100% Remote US
- **Setup Status:** ✅ Complete (Permission Set assigned)

---

## 🔧 Technical Context

### Salesforce Org
- **Edition:** Developer Edition
- **Custom Objects:** 37
- **Apex Classes:** 85+
- **LWC Components:** 11
- **Flows:** 21+
- **Triggers:** 9
- **API Integrations:** 11

### Key Objects

#### Jobs_Profile__c (13 fields)
1. User__c (Lookup)
2. Min_Salary__c (Currency)
3. Max_Salary__c (Currency)
4. Experience_Years__c (Number)
5. Deal_Breakers__c (Long Text)
6. Green_Flags__c (Long Text)
7. Remote_Required__c (Checkbox)
8. Search_Keywords__c (Long Text)
9. Location_Preference__c (Text)
10-13. Standard fields

**MISSING:** Flexible_Schedule_Required__c (Checkbox)

#### Resume_Package__c - NEEDS FIELDS
- Opportunity__c (Lookup) - NOT YET ADDED
- Job_Posting__c (Lookup) - NOT YET ADDED
- PDF_Version_URL__c (URL) - NOT YET ADDED
- ATS_Version_URL__c (URL) - NOT YET ADDED
- Tailoring_Score__c (Number) - NOT YET ADDED
- Generated_Date__c (DateTime) - NOT YET ADDED

### Architecture Decisions
1. **AI Model:** Claude Sonnet 4 (`claude-sonnet-4-20250514`)
2. **Pattern:** Multi-agent (not monolithic)
3. **Task Tracking:** ROADMAP.md
4. **Timezone:** America/New_York (EST)
5. **Code Standards:** Bulkification, 75%+ coverage, no SOQL in loops

---

## 📋 Active Projects

### 1. Job Search System (89% complete)
- **Status:** OPERATIONAL ✅
- **Remaining:** Dashboard only
- **Location:** Salesforce org

### 2. JARVIS Voice Assistant
- **Status:** Architecture complete, awaiting implementation
- **Location:** D:\JARVIS\
- **Start:** After Agentforce exam (Dec 30)

### 3. The Raven & Poe (Journal Business)
- **Status:** Launched on Ko-fi
- **Products:** Gilded Cage Collection
- **Needs:** Social media automation

### 4. Girl Friday Integration
- **Status:** Files in place, bridge not built
- **Location:** D:\JARVIS\GIRL_FRIDAY\

---

## 🐛 Known Issues

### Fixed
- ✅ Queueable limit in batch context (Dec 26)
- ✅ Meal type mismatch in MealPlanGenerator (Dec 23)
- ✅ Remote_Policy__c picklist values

### Outstanding
1. Jobs_Profile__c not integrated into analyzer
2. Resume_Package__c missing lookup fields
3. Flexible_Schedule_Required__c field missing
4. JobPostingAnalyzer.cls still monolithic (agents built but analyzer not refactored)

---

## 📚 Documentation Created

### December 23, 2025
- Job Parsing Agent Architecture
- Resume Generation Agent Architecture
- Content Automation Agent Architecture
- Girl Friday / JARVIS Integration Spec
- CLAUDE.md, ROADMAP.md, carry_forward.md

### December 26, 2025
- JOB_SEARCH_QUEUEABLE_FIX_DEC26.md

---

## 🚀 Next Session Checklist

When starting next conversation, Claude should:

1. Reference this skill for context
2. Check what Abby wants to work on
3. Use conversation_search if needed for specific details
4. Follow CLAUDE.md operating rules
5. Update carry_forward when new critical details emerge

**Top Priorities:**
1. Dashboard (completes Job Search system)
2. Jobs_Profile__c field addition
3. Resume_Package__c fields
4. LinkedIn Post Generator
