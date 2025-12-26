# COMPLETE JOB SEARCH AGENTS BUILD - CLAUDE CODE INSTRUCTIONS
**Created:** 2025-12-23 15:13:18 EST  
**Task:** Build and deploy all 6 job search agents for Salesforce  
**Estimated Time:** 30 minutes

---

## 🎯 YOUR MISSION

Build 6 Salesforce Apex agents for job search automation with correct field names and comprehensive tests.

---

## ✅ CONTEXT - WHAT'S ALREADY DONE

**Fields Added to Salesforce:**
- ✅ Salary_Text__c (Text 255)
- ✅ Is_Duplicate__c (Checkbox)
- ✅ Duplicate_Of__c (Lookup Job_Posting__c)
- ✅ Min_Experience_Years__c (Number 2,0)
- ✅ Max_Experience_Years__c (Number 2,0)

**Objects Verified:**
- ✅ Job_Posting__c (48 fields total)
- ✅ Jobs_Profile__c (13 fields total)

---

## 🚨 CRITICAL - EXACT FIELD NAMES TO USE

**Job_Posting__c Fields (use these EXACT API names):**
- `Title__c` (NOT Position_Title__c)
- `Company__c`
- `Description__c`
- `Location__c`
- `Remote_Policy__c` (NOT Remote_Type__c)
- `Salary_Min__c` (NOT Min_Salary__c)
- `Salary_Max__c` (NOT Max_Salary__c)
- `Salary_Text__c` (NEW)
- `Min_Experience_Years__c` (NEW)
- `Max_Experience_Years__c` (NEW)
- `Apply_URL__c` (NOT Application_URL__c)
- `Application_Status__c`
- `Fit_Score__c` (NOT AI_Fit_Score__c)
- `Provider__c` (NOT Source_API__c)
- `ExternalID__c`
- `Posted_Date__c`
- `Last_Synced__c` (NOT Scraped_Date__c)
- `Is_Duplicate__c` (NEW)
- `Duplicate_Of__c` (NEW)

**Jobs_Profile__c Fields (correct as-is):**
- `User__c`
- `Min_Salary__c`
- `Max_Salary__c`
- `Experience_Years__c`
- `Deal_Breakers__c`
- `Green_Flags__c`
- `Remote_Required__c`
- `Search_Keywords__c`
- `Location_Preference__c`

---

## 📂 FILE STRUCTURE TO CREATE

Create all files in: `force-app/main/default/classes/jobparsing/`

**Total: 24 files (6 agents × 4 files each)**

```
jobparsing/
├── SalaryExtractionSubagent.cls
├── SalaryExtractionSubagent.cls-meta.xml
├── SalaryExtractionSubagentTest.cls
├── SalaryExtractionSubagentTest.cls-meta.xml
│
├── DeduplicationSubagent.cls
├── DeduplicationSubagent.cls-meta.xml
├── DeduplicationSubagentTest.cls
├── DeduplicationSubagentTest.cls-meta.xml
│
├── JobPostingCoordinator.cls
├── JobPostingCoordinator.cls-meta.xml
├── JobPostingCoordinatorTest.cls
├── JobPostingCoordinatorTest.cls-meta.xml
│
├── LocationParsingSubagent.cls
├── LocationParsingSubagent.cls-meta.xml
├── LocationParsingSubagentTest.cls
├── LocationParsingSubagentTest.cls-meta.xml
│
├── ExperienceParsingSubagent.cls
├── ExperienceParsingSubagent.cls-meta.xml
├── ExperienceParsingSubagentTest.cls
├── ExperienceParsingSubagentTest.cls-meta.xml
│
├── JobScoringSubagent.cls
├── JobScoringSubagent.cls-meta.xml
├── JobScoringSubagentTest.cls
└── JobScoringSubagentTest.cls-meta.xml
```

---

## 🔨 BUILD ORDER (DO IN SEQUENCE)

### Agent 1: SalaryExtractionSubagent ✅ ALREADY PROVIDED
Files are already in the outputs. Copy them to the jobparsing folder.

### Agent 2: DeduplicationSubagent
### Agent 3: JobPostingCoordinator
### Agent 4: LocationParsingSubagent
### Agent 5: ExperienceParsingSubagent
### Agent 6: JobScoringSubagent

---

## 📝 AGENT 1: SalaryExtractionSubagent (ALREADY COMPLETE)

**Just copy the 4 files provided:**
- SalaryExtractionSubagent.cls
- SalaryExtractionSubagent.cls-meta.xml
- SalaryExtractionSubagentTest.cls
- SalaryExtractionSubagentTest.cls-meta.xml

---

## 📝 AGENT 2: DeduplicationSubagent - BUILD THIS

**Purpose:** Detect duplicate job postings

**Class: DeduplicationSubagent.cls**
```apex
/**
 * @description Detects and prevents duplicate job postings
 * @author Abby (Salesforce Administrator)
 * @date 2025-12-23
 * @group Job Parsing
 */
public with sharing class DeduplicationSubagent {
    
    /**
     * @description Check if a job posting is a duplicate
     * @param company Company name
     * @param title Job title
     * @param salaryMin Minimum salary
     * @param salaryMax Maximum salary
     * @param location Job location
     * @return Map with is_duplicate, confidence, duplicate_of_id, match_reason
     */
    public static Map<String, Object> checkDuplicate(
        String company,
        String title,
        Decimal salaryMin,
        Decimal salaryMax,
        String location
    ) {
        Map<String, Object> result = new Map<String, Object>{
            'is_duplicate' => false,
            'confidence' => 0.0,
            'duplicate_of_id' => null,
            'match_reason' => ''
        };
        
        // Null checks
        if (String.isBlank(company) || String.isBlank(title)) {
            return result;
        }
        
        // Normalize for comparison
        String normalizedCompany = normalizeCompanyName(company);
        String normalizedTitle = normalizeJobTitle(title);
        
        // Query existing jobs (last 90 days, not duplicates)
        List<Job_Posting__c> existingJobs = [
            SELECT Id, Company__c, Title__c, 
                   Salary_Min__c, Salary_Max__c, Location__c
            FROM Job_Posting__c
            WHERE Is_Duplicate__c = false
            AND CreatedDate = LAST_N_DAYS:90
            LIMIT 200
        ];
        
        // Check each job for duplicates
        for (Job_Posting__c existingJob : existingJobs) {
            String existingCompanyNorm = normalizeCompanyName(existingJob.Company__c);
            String existingTitleNorm = normalizeJobTitle(existingJob.Title__c);
            
            // Exact match on company + title
            if (existingCompanyNorm == normalizedCompany && 
                existingTitleNorm == normalizedTitle) {
                
                // Check salary similarity (within 10%)
                if (salariesMatch(salaryMin, salaryMax, 
                                 existingJob.Salary_Min__c, 
                                 existingJob.Salary_Max__c)) {
                    result.put('is_duplicate', true);
                    result.put('confidence', 0.95);
                    result.put('duplicate_of_id', existingJob.Id);
                    result.put('match_reason', 'Same company + title + salary');
                    return result;
                }
            }
            
            // Fuzzy match on title (Levenshtein distance < 3)
            if (existingCompanyNorm == normalizedCompany &&
                levenshteinDistance(existingTitleNorm, normalizedTitle) < 3) {
                
                if (salariesMatch(salaryMin, salaryMax,
                                 existingJob.Salary_Min__c,
                                 existingJob.Salary_Max__c)) {
                    result.put('is_duplicate', true);
                    result.put('confidence', 0.85);
                    result.put('duplicate_of_id', existingJob.Id);
                    result.put('match_reason', 'Similar company + title + salary');
                    return result;
                }
            }
        }
        
        return result;
    }
    
    /**
     * @description Normalize company name for comparison
     */
    private static String normalizeCompanyName(String company) {
        if (String.isBlank(company)) {
            return '';
        }
        
        String normalized = company.toLowerCase().trim();
        
        // Remove common suffixes
        normalized = normalized.replaceAll('\\s+(inc\\.?|llc|corp\\.?|corporation|ltd\\.?)$', '');
        normalized = normalized.replaceAll('[^a-z0-9]', '');
        
        return normalized;
    }
    
    /**
     * @description Normalize job title for comparison
     */
    private static String normalizeJobTitle(String title) {
        if (String.isBlank(title)) {
            return '';
        }
        
        String normalized = title.toLowerCase().trim();
        
        // Remove common variations
        normalized = normalized.replaceAll('\\s+(sr\\.?|jr\\.?|iii?|iv)\\s*', ' ');
        normalized = normalized.replaceAll('\\s+\\(.*?\\)', ''); // Remove parentheticals
        normalized = normalized.replaceAll('[^a-z0-9]', '');
        
        return normalized;
    }
    
    /**
     * @description Check if salaries match (within 10%)
     */
    private static Boolean salariesMatch(
        Decimal salary1Min, 
        Decimal salary1Max,
        Decimal salary2Min,
        Decimal salary2Max
    ) {
        // Handle nulls
        if (salary1Min == null || salary2Min == null) {
            return false;
        }
        
        // Calculate tolerance (10%)
        Decimal tolerance = salary1Min * 0.10;
        
        // Check if mins are within tolerance
        return Math.abs(salary1Min - salary2Min) <= tolerance;
    }
    
    /**
     * @description Calculate Levenshtein distance between two strings
     */
    private static Integer levenshteinDistance(String s1, String s2) {
        Integer len1 = s1.length();
        Integer len2 = s2.length();
        
        List<List<Integer>> dp = new List<List<Integer>>();
        
        for (Integer i = 0; i <= len1; i++) {
            List<Integer> row = new List<Integer>();
            for (Integer j = 0; j <= len2; j++) {
                row.add(0);
            }
            dp.add(row);
        }
        
        for (Integer i = 0; i <= len1; i++) {
            dp[i][0] = i;
        }
        
        for (Integer j = 0; j <= len2; j++) {
            dp[0][j] = j;
        }
        
        for (Integer i = 1; i <= len1; i++) {
            for (Integer j = 1; j <= len2; j++) {
                Integer cost = s1.substring(i-1, i) == s2.substring(j-1, j) ? 0 : 1;
                
                Integer deletion = dp[i-1][j] + 1;
                Integer insertion = dp[i][j-1] + 1;
                Integer substitution = dp[i-1][j-1] + cost;
                
                dp[i][j] = Math.min(Math.min(deletion, insertion), substitution);
            }
        }
        
        return dp[len1][len2];
    }
}
```

**Test Class: DeduplicationSubagentTest.cls**
```apex
@isTest
private class DeduplicationSubagentTest {
    
    @TestSetup
    static void setup() {
        // Create test jobs
        List<Job_Posting__c> jobs = new List<Job_Posting__c>();
        
        jobs.add(new Job_Posting__c(
            Title__c = 'Salesforce Administrator',
            Company__c = 'Salesforce Inc.',
            Salary_Min__c = 85000,
            Salary_Max__c = 95000,
            Location__c = 'Remote',
            Is_Duplicate__c = false
        ));
        
        jobs.add(new Job_Posting__c(
            Title__c = 'Data Analyst',
            Company__c = 'Microsoft Corporation',
            Salary_Min__c = 75000,
            Salary_Max__c = 85000,
            Location__c = 'Seattle, WA',
            Is_Duplicate__c = false
        ));
        
        insert jobs;
    }
    
    @isTest
    static void testExactDuplicate() {
        Map<String, Object> result = DeduplicationSubagent.checkDuplicate(
            'Salesforce Inc.',
            'Salesforce Administrator',
            85000,
            95000,
            'Remote'
        );
        
        System.assertEquals(true, result.get('is_duplicate'), 'Should detect exact duplicate');
        System.assert((Decimal) result.get('confidence') >= 0.90, 'Should have high confidence');
        System.assertNotEquals(null, result.get('duplicate_of_id'), 'Should return duplicate ID');
    }
    
    @isTest
    static void testCompanyNameVariations() {
        // Test "Salesforce" vs "Salesforce Inc."
        Map<String, Object> result = DeduplicationSubagent.checkDuplicate(
            'Salesforce',
            'Salesforce Administrator',
            85000,
            95000,
            'Remote'
        );
        
        System.assertEquals(true, result.get('is_duplicate'), 'Should normalize company names');
    }
    
    @isTest
    static void testFuzzyTitleMatch() {
        // "Salesforce Admin" should match "Salesforce Administrator"
        Map<String, Object> result = DeduplicationSubagent.checkDuplicate(
            'Salesforce',
            'Salesforce Admin',
            85000,
            95000,
            'Remote'
        );
        
        System.assertEquals(true, result.get('is_duplicate'), 'Should detect fuzzy match');
    }
    
    @isTest
    static void testNotDuplicate() {
        Map<String, Object> result = DeduplicationSubagent.checkDuplicate(
            'Google',
            'Software Engineer',
            120000,
            150000,
            'Mountain View, CA'
        );
        
        System.assertEquals(false, result.get('is_duplicate'), 'Should not flag unique job');
        System.assertEquals(null, result.get('duplicate_of_id'), 'Should not return ID');
    }
    
    @isTest
    static void testNullInputs() {
        Map<String, Object> result = DeduplicationSubagent.checkDuplicate(
            null,
            null,
            null,
            null,
            null
        );
        
        System.assertEquals(false, result.get('is_duplicate'), 'Should handle nulls gracefully');
    }
}
```

**Meta XML Files:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>62.0</apiVersion>
    <status>Active</status>
</ApexClass>
```

---

## 📝 AGENT 3: JobPostingCoordinator - BUILD THIS

**Purpose:** Orchestrate all agents and create Job_Posting__c records

**Class: JobPostingCoordinator.cls**
```apex
/**
 * @description Coordinates all job parsing subagents and creates Job_Posting__c records
 * @author Abby (Salesforce Administrator)
 * @date 2025-12-23
 * @group Job Parsing
 */
public with sharing class JobPostingCoordinator {
    
    /**
     * @description Process a job posting from API response
     * @param apiResponse Map containing job data from external API
     * @return Id of created or existing Job_Posting__c record
     */
    public static Id processJobPosting(Map<String, Object> apiResponse) {
        try {
            // Extract data from API response
            String company = (String) apiResponse.get('company');
            String title = (String) apiResponse.get('title');
            String salaryText = (String) apiResponse.get('salary');
            String location = (String) apiResponse.get('location');
            String description = (String) apiResponse.get('description');
            String applyUrl = (String) apiResponse.get('apply_url');
            String provider = (String) apiResponse.get('provider');
            String externalId = (String) apiResponse.get('external_id');
            
            // Call SalaryExtractionSubagent
            Map<String, Object> salaryData = 
                SalaryExtractionSubagent.extractSalary(salaryText);
            
            // Call LocationParsingSubagent
            Map<String, Object> locationData = 
                LocationParsingSubagent.parseLocation(location);
            
            // Call ExperienceParsingSubagent
            Map<String, Object> experienceData = 
                ExperienceParsingSubagent.parseExperience(description);
            
            // Check for duplicates
            Map<String, Object> dupeCheck = DeduplicationSubagent.checkDuplicate(
                company,
                title,
                (Decimal) salaryData.get('min_salary'),
                (Decimal) salaryData.get('max_salary'),
                location
            );
            
            // If duplicate found, return existing ID
            if ((Boolean) dupeCheck.get('is_duplicate')) {
                return (Id) dupeCheck.get('duplicate_of_id');
            }
            
            // Calculate fit score
            Decimal fitScore = JobScoringSubagent.calculateFitScore(
                salaryData,
                locationData,
                experienceData,
                description
            );
            
            // Create Job_Posting__c record
            Job_Posting__c job = new Job_Posting__c(
                Title__c = title,
                Company__c = company,
                Description__c = description,
                Location__c = (String) locationData.get('location'),
                Remote_Policy__c = (String) locationData.get('remote_type'),
                Salary_Min__c = (Decimal) salaryData.get('min_salary'),
                Salary_Max__c = (Decimal) salaryData.get('max_salary'),
                Salary_Text__c = salaryText,
                Min_Experience_Years__c = (Decimal) experienceData.get('min_years'),
                Max_Experience_Years__c = (Decimal) experienceData.get('max_years'),
                Apply_URL__c = applyUrl,
                Provider__c = provider,
                ExternalID__c = externalId,
                Posted_Date__c = Date.today(),
                Last_Synced__c = DateTime.now(),
                Fit_Score__c = fitScore,
                Is_Duplicate__c = false,
                Application_Status__c = 'Not Applied'
            );
            
            insert job;
            return job.Id;
            
        } catch (Exception e) {
            System.debug('Error in JobPostingCoordinator: ' + e.getMessage());
            throw e;
        }
    }
}
```

**Test Class: JobPostingCoordinatorTest.cls**
```apex
@isTest
private class JobPostingCoordinatorTest {
    
    @TestSetup
    static void setup() {
        // Create Jobs_Profile__c for current user
        Jobs_Profile__c profile = new Jobs_Profile__c(
            User__c = UserInfo.getUserId(),
            Min_Salary__c = 80000,
            Max_Salary__c = 150000,
            Experience_Years__c = 2.5,
            Remote_Required__c = true,
            Search_Keywords__c = 'Salesforce, Admin',
            Green_Flags__c = 'Remote',
            Deal_Breakers__c = 'On-site only'
        );
        insert profile;
    }
    
    @isTest
    static void testFullPipeline() {
        Map<String, Object> apiResponse = new Map<String, Object>{
            'company' => 'Salesforce',
            'title' => 'Salesforce Administrator',
            'salary' => '$85k-$95k',
            'location' => 'Remote (US-based)',
            'description' => 'Looking for 3-5 years Salesforce experience',
            'apply_url' => 'https://salesforce.com/careers/123',
            'provider' => 'Adzuna',
            'external_id' => 'adzuna_123'
        };
        
        Test.startTest();
        Id jobId = JobPostingCoordinator.processJobPosting(apiResponse);
        Test.stopTest();
        
        Job_Posting__c job = [
            SELECT Title__c, Salary_Min__c, Salary_Max__c, 
                   Remote_Policy__c, Fit_Score__c, Is_Duplicate__c
            FROM Job_Posting__c
            WHERE Id = :jobId
        ];
        
        System.assertEquals('Salesforce Administrator', job.Title__c);
        System.assertEquals(85000, job.Salary_Min__c);
        System.assertEquals(95000, job.Salary_Max__c);
        System.assertEquals('Remote', job.Remote_Policy__c);
        System.assertEquals(false, job.Is_Duplicate__c);
        System.assert(job.Fit_Score__c > 0, 'Should have fit score');
    }
    
    @isTest
    static void testDuplicateDetection() {
        // Create first job
        Map<String, Object> apiResponse1 = new Map<String, Object>{
            'company' => 'Test Company',
            'title' => 'Test Job',
            'salary' => '$80k',
            'location' => 'Remote',
            'description' => '2 years experience',
            'apply_url' => 'https://test.com/1',
            'provider' => 'Test',
            'external_id' => 'test_1'
        };
        
        Id job1Id = JobPostingCoordinator.processJobPosting(apiResponse1);
        
        // Create duplicate
        Map<String, Object> apiResponse2 = new Map<String, Object>{
            'company' => 'Test Company',
            'title' => 'Test Job',
            'salary' => '$80k',
            'location' => 'Remote',
            'description' => '2 years experience',
            'apply_url' => 'https://test.com/2',
            'provider' => 'Test',
            'external_id' => 'test_2'
        };
        
        Test.startTest();
        Id job2Id = JobPostingCoordinator.processJobPosting(apiResponse2);
        Test.stopTest();
        
        System.assertEquals(job1Id, job2Id, 'Should return same ID for duplicate');
        
        List<Job_Posting__c> jobs = [SELECT Id FROM Job_Posting__c];
        System.assertEquals(1, jobs.size(), 'Should only have one job record');
    }
}
```

---

## 📝 AGENT 4: LocationParsingSubagent - BUILD THIS

**Class: LocationParsingSubagent.cls**
```apex
/**
 * @description Parses location text and determines remote policy
 * @author Abby (Salesforce Administrator)
 * @date 2025-12-23
 * @group Job Parsing
 */
public with sharing class LocationParsingSubagent {
    
    /**
     * @description Parse location and determine remote policy
     * @param locationText Raw location text from job posting
     * @return Map with location, remote_type, confidence
     */
    public static Map<String, Object> parseLocation(String locationText) {
        Map<String, Object> result = new Map<String, Object>{
            'location' => '',
            'remote_type' => 'Onsite',
            'confidence' => 0.0
        };
        
        if (String.isBlank(locationText)) {
            return result;
        }
        
        String lowerText = locationText.toLowerCase();
        
        // Check for remote indicators
        if (lowerText.contains('remote') || 
            lowerText.contains('work from home') ||
            lowerText.contains('wfh') ||
            lowerText.contains('fully remote')) {
            
            result.put('remote_type', 'Remote');
            
            if (lowerText.contains('us-based') || lowerText.contains('usa')) {
                result.put('location', 'United States');
            } else {
                result.put('location', 'Remote');
            }
            
            result.put('confidence', 0.90);
            return result;
        }
        
        // Check for hybrid indicators
        if (lowerText.contains('hybrid') ||
            lowerText.contains('remote optional') ||
            lowerText.contains('flexible location')) {
            
            result.put('remote_type', 'Hybrid');
            result.put('location', extractCityState(locationText));
            result.put('confidence', 0.85);
            return result;
        }
        
        // Default: Onsite with location
        result.put('remote_type', 'Onsite');
        result.put('location', extractCityState(locationText));
        result.put('confidence', 0.80);
        
        return result;
    }
    
    /**
     * @description Extract city and state from location text
     */
    private static String extractCityState(String locationText) {
        if (String.isBlank(locationText)) {
            return '';
        }
        
        // Remove common prefixes/suffixes
        String cleaned = locationText.trim();
        cleaned = cleaned.replaceAll('(?i)(hybrid|remote|onsite)\\s*[-–]?\\s*', '');
        cleaned = cleaned.replaceAll('\\(.*?\\)', '').trim();
        
        return cleaned;
    }
}
```

**Test Class: LocationParsingSubagentTest.cls**
```apex
@isTest
private class LocationParsingSubagentTest {
    
    @isTest
    static void testRemote() {
        Map<String, Object> result = LocationParsingSubagent.parseLocation('Remote');
        
        System.assertEquals('Remote', result.get('remote_type'));
        System.assertEquals('Remote', result.get('location'));
        System.assert((Decimal) result.get('confidence') >= 0.80);
    }
    
    @isTest
    static void testRemoteUSBased() {
        Map<String, Object> result = LocationParsingSubagent.parseLocation('Remote (US-based)');
        
        System.assertEquals('Remote', result.get('remote_type'));
        System.assertEquals('United States', result.get('location'));
    }
    
    @isTest
    static void testHybrid() {
        Map<String, Object> result = LocationParsingSubagent.parseLocation('Hybrid - Austin, TX');
        
        System.assertEquals('Hybrid', result.get('remote_type'));
        System.assert(((String) result.get('location')).contains('Austin'));
    }
    
    @isTest
    static void testOnsite() {
        Map<String, Object> result = LocationParsingSubagent.parseLocation('San Francisco, CA');
        
        System.assertEquals('Onsite', result.get('remote_type'));
        System.assertEquals('San Francisco, CA', result.get('location'));
    }
    
    @isTest
    static void testNull() {
        Map<String, Object> result = LocationParsingSubagent.parseLocation(null);
        
        System.assertNotEquals(null, result);
        System.assertEquals('', result.get('location'));
    }
}
```

---

## 📝 AGENT 5: ExperienceParsingSubagent - BUILD THIS

**Class: ExperienceParsingSubagent.cls**
```apex
/**
 * @description Extracts years of experience from job description
 * @author Abby (Salesforce Administrator)
 * @date 2025-12-23
 * @group Job Parsing
 */
public with sharing class ExperienceParsingSubagent {
    
    /**
     * @description Parse experience requirements from description
     * @param description Job description text
     * @return Map with min_years, max_years, confidence
     */
    public static Map<String, Object> parseExperience(String description) {
        Map<String, Object> result = new Map<String, Object>{
            'min_years' => null,
            'max_years' => null,
            'confidence' => 0.0
        };
        
        if (String.isBlank(description)) {
            return result;
        }
        
        String lowerDesc = description.toLowerCase();
        
        // Check for level keywords first
        if (lowerDesc.contains('entry level') || lowerDesc.contains('entry-level')) {
            result.put('min_years', 0);
            result.put('max_years', 2);
            result.put('confidence', 0.75);
            return result;
        }
        
        if (lowerDesc.contains('mid-level') || lowerDesc.contains('mid level')) {
            result.put('min_years', 3);
            result.put('max_years', 7);
            result.put('confidence', 0.75);
            return result;
        }
        
        if (lowerDesc.contains('senior')) {
            result.put('min_years', 7);
            result.put('max_years', null);
            result.put('confidence', 0.75);
            return result;
        }
        
        // Pattern: "3-5 years"
        Pattern rangePattern = Pattern.compile('(\\d+)\\s*[-–to]+\\s*(\\d+)\\s*years?');
        Matcher rangeMatcher = rangePattern.matcher(lowerDesc);
        
        if (rangeMatcher.find()) {
            result.put('min_years', Integer.valueOf(rangeMatcher.group(1)));
            result.put('max_years', Integer.valueOf(rangeMatcher.group(2)));
            result.put('confidence', 0.90);
            return result;
        }
        
        // Pattern: "5+ years"
        Pattern plusPattern = Pattern.compile('(\\d+)\\+\\s*years?');
        Matcher plusMatcher = plusPattern.matcher(lowerDesc);
        
        if (plusMatcher.find()) {
            result.put('min_years', Integer.valueOf(plusMatcher.group(1)));
            result.put('max_years', null);
            result.put('confidence', 0.85);
            return result;
        }
        
        // Pattern: "minimum 3 years"
        Pattern minPattern = Pattern.compile('minimum\\s+(?:of\\s+)?(\\d+)\\s*years?');
        Matcher minMatcher = minPattern.matcher(lowerDesc);
        
        if (minMatcher.find()) {
            result.put('min_years', Integer.valueOf(minMatcher.group(1)));
            result.put('max_years', null);
            result.put('confidence', 0.80);
            return result;
        }
        
        return result;
    }
}
```

**Test Class: ExperienceParsingSubagentTest.cls**
```apex
@isTest
private class ExperienceParsingSubagentTest {
    
    @isTest
    static void testRangeFormat() {
        Map<String, Object> result = ExperienceParsingSubagent.parseExperience(
            'Looking for 3-5 years of experience'
        );
        
        System.assertEquals(3, result.get('min_years'));
        System.assertEquals(5, result.get('max_years'));
        System.assert((Decimal) result.get('confidence') >= 0.85);
    }
    
    @isTest
    static void testPlusFormat() {
        Map<String, Object> result = ExperienceParsingSubagent.parseExperience(
            'Requires 5+ years experience'
        );
        
        System.assertEquals(5, result.get('min_years'));
        System.assertEquals(null, result.get('max_years'));
    }
    
    @isTest
    static void testEntryLevel() {
        Map<String, Object> result = ExperienceParsingSubagent.parseExperience(
            'This is an entry-level position'
        );
        
        System.assertEquals(0, result.get('min_years'));
        System.assertEquals(2, result.get('max_years'));
    }
    
    @isTest
    static void testMidLevel() {
        Map<String, Object> result = ExperienceParsingSubagent.parseExperience(
            'Mid-level position available'
        );
        
        System.assertEquals(3, result.get('min_years'));
        System.assertEquals(7, result.get('max_years'));
    }
    
    @isTest
    static void testSenior() {
        Map<String, Object> result = ExperienceParsingSubagent.parseExperience(
            'Senior developer needed'
        );
        
        System.assertEquals(7, result.get('min_years'));
        System.assertEquals(null, result.get('max_years'));
    }
    
    @isTest
    static void testNoExperience() {
        Map<String, Object> result = ExperienceParsingSubagent.parseExperience(
            'Great opportunity to work with us'
        );
        
        System.assertEquals(null, result.get('min_years'));
        System.assertEquals(null, result.get('max_years'));
    }
}
```

---

## 📝 AGENT 6: JobScoringSubagent - BUILD THIS

**Class: JobScoringSubagent.cls**
```apex
/**
 * @description Calculates fit score for job posting against user profile
 * @author Abby (Salesforce Administrator)
 * @date 2025-12-23
 * @group Job Parsing
 */
public with sharing class JobScoringSubagent {
    
    /**
     * @description Calculate fit score (0-100) against user's Jobs_Profile__c
     * @param salaryData Map from SalaryExtractionSubagent
     * @param locationData Map from LocationParsingSubagent
     * @param experienceData Map from ExperienceParsingSubagent
     * @param description Job description text
     * @return Decimal score from 0-100
     */
    public static Decimal calculateFitScore(
        Map<String, Object> salaryData,
        Map<String, Object> locationData,
        Map<String, Object> experienceData,
        String description
    ) {
        // Base score
        Decimal score = 50;
        
        // Get user profile
        List<Jobs_Profile__c> profiles = [
            SELECT Min_Salary__c, Max_Salary__c, Experience_Years__c,
                   Remote_Required__c, Location_Preference__c,
                   Search_Keywords__c, Green_Flags__c, Deal_Breakers__c
            FROM Jobs_Profile__c
            WHERE User__c = :UserInfo.getUserId()
            LIMIT 1
        ];
        
        if (profiles.isEmpty()) {
            return score; // Return base score if no profile
        }
        
        Jobs_Profile__c profile = profiles[0];
        String descLower = description != null ? description.toLowerCase() : '';
        
        // Check deal breakers first (auto-reject)
        if (String.isNotBlank(profile.Deal_Breakers__c)) {
            List<String> dealBreakers = profile.Deal_Breakers__c.toLowerCase().split(',');
            for (String dealBreaker : dealBreakers) {
                if (descLower.contains(dealBreaker.trim())) {
                    return 0; // Auto-reject
                }
            }
        }
        
        // Salary match (20 points)
        score += scoreSalary(
            (Decimal) salaryData.get('min_salary'),
            (Decimal) salaryData.get('max_salary'),
            profile.Min_Salary__c,
            profile.Max_Salary__c
        );
        
        // Experience match (15 points)
        score += scoreExperience(
            (Decimal) experienceData.get('min_years'),
            (Decimal) experienceData.get('max_years'),
            profile.Experience_Years__c
        );
        
        // Location/Remote match (10 points)
        score += scoreLocation(
            (String) locationData.get('remote_type'),
            profile.Remote_Required__c
        );
        
        // Keywords match (10 points)
        if (String.isNotBlank(profile.Search_Keywords__c)) {
            score += scoreKeywords(descLower, profile.Search_Keywords__c);
        }
        
        // Green flags (15 points)
        if (String.isNotBlank(profile.Green_Flags__c)) {
            score += scoreGreenFlags(descLower, profile.Green_Flags__c);
        }
        
        // Cap at 100
        return Math.min(score, 100);
    }
    
    private static Decimal scoreSalary(
        Decimal jobMin, 
        Decimal jobMax,
        Decimal userMin,
        Decimal userMax
    ) {
        if (jobMin == null || userMin == null) {
            return 0;
        }
        
        // Job salary within user range: +20
        if (jobMin >= userMin && (userMax == null || jobMax <= userMax)) {
            return 20;
        }
        
        // Below user min: -10
        if (jobMax < userMin) {
            return -10;
        }
        
        // Above user max: +5 (bonus!)
        if (jobMin > userMax) {
            return 5;
        }
        
        return 0;
    }
    
    private static Decimal scoreExperience(
        Decimal jobMin,
        Decimal jobMax,
        Decimal userYears
    ) {
        if (jobMin == null || userYears == null) {
            return 0;
        }
        
        // User matches required: +15
        if (userYears >= jobMin && (jobMax == null || userYears <= jobMax)) {
            return 15;
        }
        
        // User under-qualified: -15
        if (userYears < jobMin) {
            return -15;
        }
        
        // User over-qualified: -5
        if (jobMax != null && userYears > jobMax) {
            return -5;
        }
        
        return 0;
    }
    
    private static Decimal scoreLocation(String remoteType, Boolean remoteRequired) {
        if (remoteRequired == true && remoteType == 'Remote') {
            return 10;
        }
        return 0;
    }
    
    private static Decimal scoreKeywords(String description, String keywords) {
        Decimal points = 0;
        List<String> keywordList = keywords.toLowerCase().split(',');
        
        for (String keyword : keywordList) {
            if (description.contains(keyword.trim())) {
                points += 2;
                if (points >= 10) {
                    return 10; // Max 10 points
                }
            }
        }
        
        return points;
    }
    
    private static Decimal scoreGreenFlags(String description, String greenFlags) {
        Decimal points = 0;
        List<String> flagList = greenFlags.toLowerCase().split(',');
        
        for (String flag : flagList) {
            if (description.contains(flag.trim())) {
                points += 5;
                if (points >= 15) {
                    return 15; // Max 15 points
                }
            }
        }
        
        return points;
    }
}
```

**Test Class: JobScoringSubagentTest.cls**
```apex
@isTest
private class JobScoringSubagentTest {
    
    @TestSetup
    static void setup() {
        Jobs_Profile__c profile = new Jobs_Profile__c(
            User__c = UserInfo.getUserId(),
            Min_Salary__c = 80000,
            Max_Salary__c = 150000,
            Experience_Years__c = 3,
            Remote_Required__c = true,
            Search_Keywords__c = 'Salesforce, Admin',
            Green_Flags__c = 'Remote, Flexible',
            Deal_Breakers__c = 'On-site only, Travel required'
        );
        insert profile;
    }
    
    @isTest
    static void testPerfectMatch() {
        Map<String, Object> salaryData = new Map<String, Object>{
            'min_salary' => 85000,
            'max_salary' => 95000
        };
        
        Map<String, Object> locationData = new Map<String, Object>{
            'remote_type' => 'Remote'
        };
        
        Map<String, Object> experienceData = new Map<String, Object>{
            'min_years' => 2,
            'max_years' => 5
        };
        
        String description = 'Salesforce Admin position with flexible schedule';
        
        Decimal score = JobScoringSubagent.calculateFitScore(
            salaryData,
            locationData,
            experienceData,
            description
        );
        
        System.assert(score >= 80, 'Perfect match should score high: ' + score);
    }
    
    @isTest
    static void testDealBreaker() {
        Map<String, Object> salaryData = new Map<String, Object>{
            'min_salary' => 100000,
            'max_salary' => 120000
        };
        
        Map<String, Object> locationData = new Map<String, Object>{
            'remote_type' => 'Onsite'
        };
        
        Map<String, Object> experienceData = new Map<String, Object>{
            'min_years' => 3,
            'max_years' => 5
        };
        
        String description = 'On-site only position with travel required';
        
        Decimal score = JobScoringSubagent.calculateFitScore(
            salaryData,
            locationData,
            experienceData,
            description
        );
        
        System.assertEquals(0, score, 'Deal breaker should result in 0 score');
    }
    
    @isTest
    static void testNoProfile() {
        // Delete profile
        delete [SELECT Id FROM Jobs_Profile__c];
        
        Map<String, Object> salaryData = new Map<String, Object>{
            'min_salary' => 85000,
            'max_salary' => 95000
        };
        
        Map<String, Object> locationData = new Map<String, Object>{
            'remote_type' => 'Remote'
        };
        
        Map<String, Object> experienceData = new Map<String, Object>{
            'min_years' => 3,
            'max_years' => 5
        };
        
        Decimal score = JobScoringSubagent.calculateFitScore(
            salaryData,
            locationData,
            experienceData,
            'Test description'
        );
        
        System.assertEquals(50, score, 'Should return base score with no profile');
    }
}
```

---

## 🔧 META.XML TEMPLATE (Use for ALL classes)

**For each .cls file, create matching .cls-meta.xml:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>62.0</apiVersion>
    <status>Active</status>
</ApexClass>
```

---

## ✅ DEPLOYMENT STEPS

1. **Create directory structure:**
   ```
   mkdir -p force-app/main/default/classes/jobparsing
   ```

2. **Create all 24 files** in the jobparsing folder

3. **Deploy to Salesforce:**
   ```bash
   sf project deploy start --source-dir force-app/main/default/classes/jobparsing
   ```

4. **Run all tests:**
   ```bash
   sf apex run test --test-level RunLocalTests --result-format human
   ```

5. **Verify coverage:**
   - Each class should have 75%+ coverage
   - All tests should pass

---

## 🧪 FINAL INTEGRATION TEST

After all agents deployed, run this in Developer Console:

```apex
// Create profile first (one time)
Jobs_Profile__c profile = new Jobs_Profile__c(
    User__c = UserInfo.getUserId(),
    Min_Salary__c = 80000,
    Max_Salary__c = 150000,
    Experience_Years__c = 2.5,
    Remote_Required__c = true,
    Search_Keywords__c = 'Salesforce, Admin',
    Green_Flags__c = 'Remote, Flexible',
    Deal_Breakers__c = 'On-site only'
);
insert profile;

// Test full pipeline
Map<String, Object> apiResponse = new Map<String, Object>{
    'company' => 'Salesforce',
    'title' => 'Salesforce Administrator',
    'salary' => '$85k-$95k',
    'location' => 'Remote (US-based)',
    'description' => 'Looking for 3-5 years Salesforce Admin experience. Remote with flexible schedule.',
    'apply_url' => 'https://salesforce.com/careers/12345',
    'provider' => 'Adzuna',
    'external_id' => 'adzuna_test_123',
    'posted_date' => '2025-12-23'
};

Id jobId = JobPostingCoordinator.processJobPosting(apiResponse);

Job_Posting__c job = [
    SELECT Title__c, Salary_Min__c, Salary_Max__c,
           Remote_Policy__c, Fit_Score__c
    FROM Job_Posting__c
    WHERE Id = :jobId
];

System.debug('=== SUCCESS ===');
System.debug('Job: ' + job.Title__c);
System.debug('Salary: $' + job.Salary_Min__c + ' - $' + job.Salary_Max__c);
System.debug('Remote: ' + job.Remote_Policy__c);
System.debug('Fit Score: ' + job.Fit_Score__c + '/100');
```

---

## ✅ SUCCESS CHECKLIST

- [ ] All 24 files created in jobparsing folder
- [ ] All files deployed successfully
- [ ] All tests passing (6 test classes)
- [ ] Code coverage 75%+ for each class
- [ ] Integration test passes
- [ ] No compilation errors

---

**Total Time:** 30 minutes  
**Total Files:** 24  
**Total Lines of Code:** ~3,000

**LET'S BUILD!** 🚀
