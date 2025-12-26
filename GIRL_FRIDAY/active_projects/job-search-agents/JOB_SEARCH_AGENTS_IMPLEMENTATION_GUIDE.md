# JOB SEARCH AGENTS - COMPLETE IMPLEMENTATION GUIDE
**Created:** 2025-12-23 14:28:38 EST  
**For:** Claude Code (VS Code)  
**Project:** Salesforce Job Search System - Multi-Agent Architecture  
**Developer:** Abby (Salesforce Admin, 2.5 years experience)

---

## 🎯 PROJECT OVERVIEW

### What We're Building
A **multi-agent job parsing system** that replaces the monolithic `JobPostingAnalyzer.cls` with specialized subagents, each handling one specific parsing task with 90%+ accuracy.

### Current State (Verified)
- ✅ **Job_Posting__c** object exists with all required fields
- ✅ **Jobs_Profile__c** object exists (13 fields for user preferences)
- ⚠️ **JobPostingAnalyzer.cls** exists but is monolithic (hard to maintain)
- ⚠️ Salary parsing accuracy: ~50%
- ⚠️ No deduplication (same job posted multiple times)
- ⚠️ Jobs_Profile__c not integrated (manual filtering)

### Goal State (After Implementation)
- ✅ 5 specialized subagents with 90%+ accuracy each
- ✅ Salary parsing: 90%+ accuracy across all formats
- ✅ Deduplication: <5% duplicate rate
- ✅ Jobs_Profile__c integration: Auto-scoring based on user preferences
- ✅ Maintainable: Each agent is <200 lines, single responsibility
- ✅ Testable: 75%+ code coverage per class

---

## 📊 SYSTEM ARCHITECTURE

### Multi-Agent Hierarchy

```
JobPostingCoordinator.cls (NEW - Orchestrator)
    │
    ├─► SalaryExtractionSubagent.cls (NEW - P0)
    │   └─ Handles: "$85k-$95k", "$50/hr", "Competitive", "Up to $155k"
    │
    ├─► LocationParsingSubagent.cls (NEW - P1)
    │   └─ Handles: "Remote", "Austin, TX", "US-based", "Hybrid"
    │
    ├─► ExperienceParsingSubagent.cls (NEW - P1)
    │   └─ Handles: "3-5 years", "Mid-level", "Senior", "Entry"
    │
    ├─► DeduplicationSubagent.cls (NEW - P0)
    │   └─ Detects: Same job across APIs, company name variants
    │
    └─► JobScoringSubagent.cls (NEW - P1)
        └─ Scores: Against Jobs_Profile__c user preferences
```

### Data Flow

```
API Response (JSON) 
    ↓
JobPostingCoordinator receives raw data
    ↓
Parallel Subagent Execution:
    ├─ SalaryExtractionSubagent → min_salary, max_salary
    ├─ LocationParsingSubagent → location, remote_type
    ├─ ExperienceParsingSubagent → min_years, max_years
    └─ (Run simultaneously)
    ↓
DeduplicationSubagent checks if job already exists
    ↓
JobScoringSubagent calculates fit score (0-100)
    ↓
JobPostingCoordinator creates/updates Job_Posting__c record
    ↓
Job saved to Salesforce with all parsed fields + AI_Fit_Score__c
```

---

## 🗂️ JOB_POSTING__C OBJECT SCHEMA

### Fields Available (Verified Dec 23, 2025)

| API Name | Type | Purpose |
|----------|------|---------|
| `Company__c` | Text(255) | Company name |
| `Position_Title__c` | Text(255) | Job title |
| `Description__c` | Long Text | Full job description |
| `Location__c` | Text(255) | Job location |
| `Remote_Type__c` | Picklist | Remote/Hybrid/Onsite |
| `Min_Salary__c` | Currency | Minimum salary (annual) |
| `Max_Salary__c` | Currency | Maximum salary (annual) |
| `Salary_Text__c` | Text(255) | Original salary text |
| `Min_Experience_Years__c` | Number(2,0) | Minimum years required |
| `Max_Experience_Years__c` | Number(2,0) | Maximum years required |
| `Application_URL__c` | URL | Apply link |
| `Application_Status__c` | Picklist | Not Applied/Applied/Interview/Offer/Rejected |
| `AI_Fit_Score__c` | Number(3,0) | 0-100 score vs user profile |
| `Source_API__c` | Text(50) | Which API (Adzuna, RemoteOK, etc.) |
| `External_ID__c` | Text(255) | Unique ID from source API |
| `Posted_Date__c` | Date | When job was posted |
| `Scraped_Date__c` | DateTime | When we fetched it |
| `Is_Duplicate__c` | Checkbox | Flagged as duplicate |
| `Duplicate_Of__c` | Lookup(Job_Posting__c) | Links to original |

---

## 📋 JOBS_PROFILE__C OBJECT SCHEMA

### User Preference Fields (13 Total)

| API Name | Type | Purpose |
|----------|------|---------|
| `User__c` | Lookup(User) | Who this profile belongs to |
| `Min_Salary__c` | Currency | Minimum acceptable salary |
| `Max_Salary__c` | Currency | Maximum desired salary |
| `Experience_Years__c` | Number(2,0) | User's years of experience |
| `Deal_Breakers__c` | Long Text | Automatic reject criteria |
| `Green_Flags__c` | Long Text | Bonus points criteria |
| `Remote_Required__c` | Checkbox | Must be remote? |
| `Search_Keywords__c` | Long Text | Comma-separated keywords |
| `Location_Preference__c` | Text(255) | Preferred locations |
| `Name` | Text(80) | Record name (auto) |
| `OwnerId` | Lookup(User) | Record owner (auto) |
| `CreatedById` | Lookup(User) | Created by (auto) |
| `LastModifiedById` | Lookup(User) | Modified by (auto) |

---

## 🔧 IMPLEMENTATION PRIORITY ORDER

### Phase 1: P0 - Critical Foundation (Build First)

#### 1. SalaryExtractionSubagent.cls ⭐ **START HERE**
**Priority:** P0  
**Estimated Time:** 2 hours  
**Complexity:** Medium  
**Test Coverage Required:** 75%+

**Handles These Formats:**
- Annual ranges: "$85k-$95k", "$85,000-$95,000", "85-95K"
- Hourly rates: "$50/hr", "$40-60/hour" (converts to annual: × 2080)
- Single values: "Up to $155k", "$120K+", "Competitive"
- Foreign currency: "£60k-£80k" (GBP→USD ×1.25), "€70k" (EUR→USD ×1.10)
- Edge cases: "DOE", "Competitive", "Not specified"

**Input:**
```apex
String salaryText = "$85k-$95k/year";
```

**Output:**
```apex
Map<String, Object> result = {
    'min_salary' => 85000.00,
    'max_salary' => 95000.00,
    'original_text' => '$85k-$95k/year',
    'confidence' => 0.95,
    'currency' => 'USD'
};
```

**Success Criteria:**
- ✅ 90%+ accuracy on test dataset
- ✅ Handles all common formats
- ✅ Graceful fallback for unparseable text
- ✅ Test coverage 75%+

---

#### 2. DeduplicationSubagent.cls
**Priority:** P0  
**Estimated Time:** 3 hours  
**Complexity:** High  
**Test Coverage Required:** 75%+

**Duplicate Detection Rules:**

1. **Exact Match (100% duplicate):**
   - Same `External_ID__c` from same `Source_API__c`
   - Action: Skip, don't create

2. **High Confidence Match (95%+ duplicate):**
   - Same company + position title (normalized)
   - Same salary range (±5%)
   - Same location
   - Action: Flag as duplicate, link to original

3. **Probable Match (80%+ duplicate):**
   - Fuzzy match on title (Levenshtein distance <3)
   - Same company (normalized: "Apple Inc." = "Apple" = "APPLE INC")
   - Similar salary (±15%)
   - Action: Flag for manual review

**Company Normalization:**
```apex
// "Apple Inc." → "apple"
// "Apple, Inc" → "apple"
// "APPLE INC" → "apple"
// "Salesforce.com" → "salesforce"
```

**Title Normalization:**
```apex
// "Salesforce Administrator" → "salesforce administrator"
// "Sr. Salesforce Admin" → "salesforce administrator"
// "Salesforce Admin (Remote)" → "salesforce administrator"
```

**Input:**
```apex
Map<String, Object> newJob = {
    'company' => 'Apple Inc.',
    'title' => 'Salesforce Administrator',
    'min_salary' => 85000,
    'max_salary' => 95000,
    'location' => 'Austin, TX'
};
```

**Output:**
```apex
Map<String, Object> result = {
    'is_duplicate' => true,
    'confidence' => 0.95,
    'duplicate_of_id' => 'a0X7e000002YvNzEAK',
    'match_reason' => 'Same company + title + salary range'
};
```

**Success Criteria:**
- ✅ <5% duplicate rate after implementation
- ✅ Handles company name variations
- ✅ Efficient (queries limited to last 90 days)
- ✅ Test coverage 75%+

---

#### 3. JobPostingCoordinator.cls (Orchestrator)
**Priority:** P0  
**Estimated Time:** 2 hours  
**Complexity:** Low  
**Test Coverage Required:** 75%+

**Responsibilities:**
- Accept raw API response (JSON)
- Call each subagent in parallel (if possible) or sequence
- Aggregate results
- Create/update Job_Posting__c record
- Handle errors gracefully

**Method Signature:**
```apex
public class JobPostingCoordinator {
    
    public static Id processJobPosting(Map<String, Object> apiResponse) {
        // 1. Extract raw data
        String company = (String) apiResponse.get('company');
        String title = (String) apiResponse.get('title');
        String salaryText = (String) apiResponse.get('salary');
        String location = (String) apiResponse.get('location');
        // ... etc
        
        // 2. Call subagents
        Map<String, Object> salaryData = 
            SalaryExtractionSubagent.extractSalary(salaryText);
        
        Map<String, Object> locationData = 
            LocationParsingSubagent.parseLocation(location);
        
        Map<String, Object> experienceData = 
            ExperienceParsingSubagent.parseExperience(description);
        
        // 3. Check for duplicates
        Map<String, Object> dupeCheck = 
            DeduplicationSubagent.checkDuplicate(company, title, salaryData);
        
        if ((Boolean) dupeCheck.get('is_duplicate')) {
            // Handle duplicate
            return (Id) dupeCheck.get('duplicate_of_id');
        }
        
        // 4. Calculate fit score
        Decimal fitScore = 
            JobScoringSubagent.calculateFitScore(/* all parsed data */);
        
        // 5. Create Job_Posting__c record
        Job_Posting__c job = new Job_Posting__c(
            Company__c = company,
            Position_Title__c = title,
            Min_Salary__c = (Decimal) salaryData.get('min_salary'),
            Max_Salary__c = (Decimal) salaryData.get('max_salary'),
            Salary_Text__c = salaryText,
            Location__c = (String) locationData.get('location'),
            Remote_Type__c = (String) locationData.get('remote_type'),
            AI_Fit_Score__c = fitScore
            // ... etc
        );
        
        insert job;
        return job.Id;
    }
}
```

**Success Criteria:**
- ✅ Handles all API response formats
- ✅ Graceful error handling (logs but doesn't fail)
- ✅ Returns Job_Posting__c Id
- ✅ Test coverage 75%+

---

### Phase 2: P1 - Enhanced Parsing (Build Second)

#### 4. LocationParsingSubagent.cls
**Priority:** P1  
**Estimated Time:** 2 hours  
**Complexity:** Medium  

**Handles These Formats:**
- "Remote" → location: "Remote", remote_type: "Remote"
- "Austin, TX" → location: "Austin, TX", remote_type: "Onsite"
- "Remote (US-based)" → location: "United States", remote_type: "Remote"
- "Hybrid - San Francisco" → location: "San Francisco, CA", remote_type: "Hybrid"
- "Austin, TX (Remote possible)" → location: "Austin, TX", remote_type: "Hybrid"

**Input:**
```apex
String locationText = "Remote (US-based)";
```

**Output:**
```apex
Map<String, Object> result = {
    'location' => 'United States',
    'remote_type' => 'Remote',
    'confidence' => 0.90
};
```

---

#### 5. ExperienceParsingSubagent.cls
**Priority:** P1  
**Estimated Time:** 1.5 hours  
**Complexity:** Low  

**Handles These Formats:**
- "3-5 years" → min: 3, max: 5
- "5+ years" → min: 5, max: null
- "Mid-level" → min: 3, max: 7
- "Senior" → min: 7, max: null
- "Entry level" → min: 0, max: 2

**Input:**
```apex
String description = "Looking for a candidate with 3-5 years of Salesforce experience...";
```

**Output:**
```apex
Map<String, Object> result = {
    'min_years' => 3,
    'max_years' => 5,
    'confidence' => 0.85
};
```

---

#### 6. JobScoringSubagent.cls
**Priority:** P1  
**Estimated Time:** 2 hours  
**Complexity:** Medium  

**Scoring Algorithm:**

```
Base Score: 50 points

Salary Match:
- Within range: +20 points
- Below min: -10 points
- Above max: +5 points (bonus!)

Experience Match:
- Match user's years: +15 points
- Under-qualified: -15 points
- Over-qualified: -5 points

Location Match:
- Remote + user wants remote: +10 points
- Location matches preference: +5 points
- No match: 0 points

Keywords Match:
- Each matching keyword: +2 points (max +10)

Green Flags:
- Each green flag match: +5 points (max +15)

Deal Breakers:
- Any deal breaker match: Score = 0 (auto-reject)

Final Score: Sum all (capped at 100)
```

**Input:**
```apex
Map<String, Object> jobData = {
    'min_salary' => 85000,
    'max_salary' => 95000,
    'min_years' => 3,
    'max_years' => 5,
    'remote_type' => 'Remote',
    'description' => 'Looking for Salesforce Admin with...'
};

Jobs_Profile__c userProfile = [SELECT ... FROM Jobs_Profile__c WHERE User__c = :UserInfo.getUserId()];
```

**Output:**
```apex
Map<String, Object> result = {
    'fit_score' => 85,
    'breakdown' => {
        'salary_points' => 20,
        'experience_points' => 15,
        'location_points' => 10,
        'keywords_points' => 8,
        'green_flags_points' => 10,
        'deal_breakers' => []
    },
    'recommendation' => 'Strong Match'
};
```

---

## 📝 IMPLEMENTATION STEPS

### Step 1: Set Up Development Environment

```bash
# In VS Code with Claude Code
cd /path/to/salesforce/project

# Verify you're in the right directory
ls -la
# Should see: force-app/ directory
```

### Step 2: Create Subagent Classes (In Order)

**File Structure:**
```
force-app/main/default/classes/
├── jobparsing/
│   ├── SalaryExtractionSubagent.cls           # Build 1st (P0)
│   ├── SalaryExtractionSubagent.cls-meta.xml
│   ├── SalaryExtractionSubagentTest.cls       # Test 1st
│   ├── SalaryExtractionSubagentTest.cls-meta.xml
│   │
│   ├── DeduplicationSubagent.cls              # Build 2nd (P0)
│   ├── DeduplicationSubagent.cls-meta.xml
│   ├── DeduplicationSubagentTest.cls          # Test 2nd
│   ├── DeduplicationSubagentTest.cls-meta.xml
│   │
│   ├── JobPostingCoordinator.cls              # Build 3rd (P0)
│   ├── JobPostingCoordinator.cls-meta.xml
│   ├── JobPostingCoordinatorTest.cls          # Test 3rd
│   ├── JobPostingCoordinatorTest.cls-meta.xml
│   │
│   ├── LocationParsingSubagent.cls            # Build 4th (P1)
│   ├── LocationParsingSubagent.cls-meta.xml
│   ├── LocationParsingSubagentTest.cls        # Test 4th
│   ├── LocationParsingSubagentTest.cls-meta.xml
│   │
│   ├── ExperienceParsingSubagent.cls          # Build 5th (P1)
│   ├── ExperienceParsingSubagent.cls-meta.xml
│   ├── ExperienceParsingSubagentTest.cls      # Test 5th
│   ├── ExperienceParsingSubagentTest.cls-meta.xml
│   │
│   └── JobScoringSubagent.cls                 # Build 6th (P1)
│       ├── JobScoringSubagent.cls-meta.xml
│       ├── JobScoringSubagentTest.cls         # Test 6th
│       └── JobScoringSubagentTest.cls-meta.xml
```

### Step 3: Deploy & Test Each Agent

**For each agent:**
1. Write the class
2. Write test class (75%+ coverage)
3. Deploy to Salesforce
4. Run tests
5. Verify in Developer Console
6. Move to next agent

### Step 4: Integration Testing

After all agents are built:
1. Test full pipeline with real API responses
2. Verify Jobs_Profile__c integration
3. Check deduplication accuracy
4. Validate AI_Fit_Score__c calculations

---

## 🧪 TESTING STRATEGY

### Test Data Sets Required

**Salary Test Cases (20+ examples):**
```apex
@TestSetup
static void setupSalaryTestData() {
    List<String> testCases = new List<String>{
        '$85k-$95k',
        '$85,000-$95,000',
        '85-95K',
        '$50/hr',
        '$40-60/hour',
        'Up to $155k',
        '$120K+',
        'Competitive',
        '£60k-£80k',
        '€70k',
        'DOE',
        'Not specified',
        '$85K - $95K per year',
        '85000-95000 USD',
        '$50.00/hour',
        '$40-$60 per hour',
        'Salary range: $85,000 to $95,000',
        '85-95k annually',
        'From £60,000 to £80,000',
        '€70,000 per annum'
    };
}
```

**Company Normalization Test Cases:**
```apex
@TestSetup
static void setupCompanyTestData() {
    List<String> testCases = new List<String>{
        'Apple Inc.',
        'Apple, Inc',
        'APPLE INC',
        'Salesforce.com',
        'Salesforce',
        'SALESFORCE INC',
        'Microsoft Corporation',
        'Microsoft',
        'MSFT'
    };
}
```

### Minimum Test Coverage Per Class

**Each subagent class must have:**
- ✅ Happy path tests (valid inputs)
- ✅ Edge case tests (boundary conditions)
- ✅ Error handling tests (invalid inputs)
- ✅ Null safety tests
- ✅ 75%+ code coverage (Salesforce requirement)

---

## 🎯 SUCCESS METRICS

### Phase 1 Complete When:
- ✅ SalaryExtractionSubagent: 90%+ accuracy
- ✅ DeduplicationSubagent: <5% duplicate rate
- ✅ JobPostingCoordinator: Successfully creates Job_Posting__c records
- ✅ All P0 classes deployed
- ✅ All P0 tests passing (75%+ coverage)

### Phase 2 Complete When:
- ✅ LocationParsingSubagent: 85%+ accuracy
- ✅ ExperienceParsingSubagent: 90%+ accuracy
- ✅ JobScoringSubagent: Scores correlate with manual review
- ✅ Jobs_Profile__c integration working
- ✅ All P1 classes deployed
- ✅ All P1 tests passing (75%+ coverage)

### Final System Complete When:
- ✅ All 6 agents deployed and tested
- ✅ End-to-end pipeline tested with real API data
- ✅ Matthew (beta tester) successfully using system
- ✅ Documentation complete
- ✅ Overall system accuracy: 90%+ across all parsing tasks

---

## 🚨 CRITICAL REMINDERS FOR CLAUDE CODE

### 1. Salesforce Apex Best Practices
- **ALWAYS** use `with sharing` for classes that query data
- **ALWAYS** bulkify code (no SOQL/DML in loops)
- **ALWAYS** handle null values gracefully
- **ALWAYS** use try-catch for external operations
- **ALWAYS** log errors (System.debug or custom logging)

### 2. Governor Limits to Watch
- **SOQL Queries:** Max 100 per transaction
- **DML Statements:** Max 150 per transaction
- **Heap Size:** Max 6MB (synchronous), 12MB (asynchronous)
- **CPU Time:** Max 10 seconds

### 3. Code Quality Standards
- **Line Length:** Max 120 characters
- **Method Length:** Max 50 lines (prefer smaller)
- **Class Size:** Max 300 lines (prefer smaller)
- **Cyclomatic Complexity:** Max 10 per method

### 4. Testing Requirements
- **Coverage:** 75% minimum (aim for 85%+)
- **Assertions:** Every test must have meaningful asserts
- **Test Data:** Use @TestSetup for efficiency
- **Governor Limits:** Test with realistic data volumes

---

## 📚 REFERENCE MATERIALS

### Salesforce Documentation
- [Apex Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/)
- [Apex Best Practices](https://developer.salesforce.com/wiki/apex_code_best_practices)
- [Testing Best Practices](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_testing_best_practices.htm)

### Skills Available
- **Salesforce Apex Developer Skill** (comprehensive Apex coding guidelines)
- **Job Search Session Skill** (Dec 19-20 comprehensive notes)
- **Girl Friday** (task tracking and session management)

### Previous Work Completed
- ✅ Job_Posting__c object verified (all fields present)
- ✅ Jobs_Profile__c object verified (13 fields)
- ✅ Multi-agent architecture designed
- ✅ Integration specification complete

---

## 🎯 YOUR FIRST TASK: SalaryExtractionSubagent

**When you start coding, begin here:**

1. Create `SalaryExtractionSubagent.cls`
2. Implement these methods:
   - `extractSalary(String salaryText)` → Map<String, Object>
   - `parseAnnualRange(String text)` → Decimal[] (private)
   - `parseHourlyRate(String text)` → Decimal[] (private)
   - `convertToUSD(Decimal amount, String currency)` → Decimal (private)
   - `normalizeSalaryText(String text)` → String (private)

3. Create `SalaryExtractionSubagentTest.cls`
4. Test all 20+ salary formats
5. Deploy and verify 90%+ accuracy

**Estimated Time:** 2 hours  
**Priority:** P0 (Do this first!)

---

## ✅ CHECKLIST FOR CLAUDE CODE

Before starting implementation:
- [ ] Read this entire document
- [ ] Review Salesforce Apex Developer skill
- [ ] Verify Salesforce CLI is connected to correct org
- [ ] Create `jobparsing/` directory in force-app
- [ ] Start with SalaryExtractionSubagent.cls

During implementation:
- [ ] Follow Apex best practices
- [ ] Write tests alongside code (not after)
- [ ] Deploy each agent individually
- [ ] Verify in Developer Console before moving to next
- [ ] Update Girl Friday ROADMAP after each completion

After implementation:
- [ ] Run all tests (verify 75%+ coverage)
- [ ] Test with real API data
- [ ] Document any edge cases discovered
- [ ] Update this guide with lessons learned

---

## 📞 SUPPORT & QUESTIONS

**If you encounter issues:**
1. Check Salesforce governor limits
2. Review error logs in Developer Console
3. Verify object schema matches this document
4. Test with simpler data first
5. Ask Abby for clarification if needed

**Common Issues:**
- **"Field does not exist"** → Verify field API names match Job_Posting__c schema
- **"SOQL query limit exceeded"** → Bulkify code, reduce queries
- **"Heap size limit exceeded"** → Process in batches
- **"Test coverage below 75%"** → Add more test methods

---

**Status:** Ready for Implementation  
**Next Step:** Create SalaryExtractionSubagent.cls  
**Estimated Total Time:** 12-15 hours for all 6 agents  
**Expected Completion:** By Dec 27, 2025 (given 2-3 hours/day)

**Good luck!** 🚀 You've got this! The architecture is solid, the requirements are clear, and you have everything you need to build this system.

---

**Document Version:** 1.0  
**Last Updated:** 2025-12-23 14:28:38 EST  
**Author:** Claude (Girl Friday) + Abby  
**For:** Claude Code (VS Code) Implementation
