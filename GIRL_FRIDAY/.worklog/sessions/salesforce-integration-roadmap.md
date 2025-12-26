# Salesforce Integration Roadmap

**Created:** December 26, 2025
**Author:** Claude (for review by Abby + Claude Code)
**Purpose:** Connect Salesforce platform to standalone applications

---

## Executive Summary

This roadmap outlines the integration of **4 standalone applications** with the central Salesforce platform. The Flask job search app has been **decommissioned** — Salesforce now handles all job search functionality.

**Total Estimated Effort:** 12-18 hours
**Priority Order:** PWA → Recipe Aggregator → JARVIS → SafeHaven

---

## Current State Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    SALESFORCE PLATFORM                          │
│                 (salesforce-ai-platform)                        │
│                                                                 │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐          │
│  │Job Search│ │ Wellness │ │  Meals   │ │ Resume   │          │
│  │  100% ✅ │ │   95%    │ │   95%    │ │  100% ✅ │          │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘          │
│       │            │            │            │                  │
│       └────────────┴─────┬──────┴────────────┘                  │
│                          │                                      │
│                   ┌──────┴──────┐                               │
│                   │  REST APIs  │                               │
│                   │  (Apex)     │                               │
│                   └──────┬──────┘                               │
└──────────────────────────┼──────────────────────────────────────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
        ▼                  ▼                  ▼
   ❌ NOT          ❌ NOT            ❌ NOT
   CONNECTED       CONNECTED         CONNECTED
        │                  │                  │
┌───────┴───────┐ ┌───────┴───────┐ ┌───────┴───────┐
│ neurothrive-  │ │    JARVIS     │ │   SafeHaven   │
│     pwa       │ │  (D:\JARVIS)  │ │   Android     │
│               │ │               │ │               │
│ OAuth defined │ │ No SF auth    │ │ No SF objects │
│ Needs testing │ │ Voice planned │ │ No REST API   │
└───────────────┘ └───────────────┘ └───────────────┘

        ▼
┌───────────────┐
│    Recipe     │
│  Aggregator   │
│               │
│ Manual CSV    │
│ No direct API │
└───────────────┘

        ▼
┌───────────────┐
│ Flask Job     │
│ Search        │
│               │
│ DECOMMISSIONED│
│ ❌ Replaced   │
└───────────────┘
```

---

## Target State Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    SALESFORCE PLATFORM                          │
│                 (salesforce-ai-platform)                        │
│                                                                 │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐          │
│  │Job Search│ │ Wellness │ │  Meals   │ │ Resume   │          │
│  │  100% ✅ │ │   95%    │ │   95%    │ │  100% ✅ │          │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘          │
│       │            │            │            │                  │
│       └────────────┴─────┬──────┴────────────┘                  │
│                          │                                      │
│              ┌───────────┴───────────┐                          │
│              │     REST APIs         │                          │
│              │ ┌─────────────────┐   │                          │
│              │ │RoutineAPI      ✅│   │                          │
│              │ │MealAPI         🔨│   │                          │
│              │ │ResourceAPI     🔨│   │                          │
│              │ │JobPostingAPI   ✅│   │                          │
│              │ └─────────────────┘   │                          │
│              └───────────┬───────────┘                          │
│                          │                                      │
│              ┌───────────┴───────────┐                          │
│              │   Connected App       │                          │
│              │   (Single OAuth)      │                          │
│              └───────────┬───────────┘                          │
└──────────────────────────┼──────────────────────────────────────┘
                           │
        ┌──────────────────┼──────────────────┬─────────────────┐
        │                  │                  │                 │
        ▼                  ▼                  ▼                 ▼
┌───────────────┐ ┌───────────────┐ ┌───────────────┐ ┌───────────────┐
│ neurothrive-  │ │    JARVIS     │ │   SafeHaven   │ │    Recipe     │
│     pwa       │ │               │ │   Android     │ │  Aggregator   │
│               │ │               │ │               │ │               │
│ ✅ OAuth      │ │ ✅ OAuth      │ │ ✅ OAuth      │ │ ✅ Direct API │
│ ✅ Wellness   │ │ ✅ Voice→SF   │ │ ✅ Resources  │ │ ✅ Meal__c    │
│ ✅ Offline    │ │ ✅ All modules│ │ ✅ Zero-know  │ │ ✅ Scheduled  │
└───────────────┘ └───────────────┘ └───────────────┘ └───────────────┘
```

---

## Integration #1: NeuroThrive PWA

**Priority:** 🔴 HIGH (Quick Win)
**Effort:** 1-2 hours
**Status:** OAuth endpoints defined, needs testing

### Current State
- PWA exists at D:\neurothrive-pwa-standalone
- OAuth 2.0 flow documented
- REST endpoints defined in Salesforce:
  - `GET /services/apexrest/routine/daily/{date}`
  - `POST /services/apexrest/routine/daily`
- Service Worker for offline
- IndexedDB for local storage

### What's Missing
| Item | Status | Action |
|------|--------|--------|
| Connected App in Salesforce | ❓ Unknown | Verify or create |
| OAuth callback URL configured | ❓ Unknown | Configure for PWA domain |
| CORS settings | ❓ Unknown | Add PWA origin to allowed |
| End-to-end test | ❌ Not done | Test full OAuth flow |

### Implementation Steps

#### Step 1: Verify/Create Connected App (15 min)
```
Salesforce Setup → App Manager → New Connected App
- Name: NeuroThrive PWA
- Enable OAuth: Yes
- Callback URL: https://[pwa-domain]/oauth/callback
- Scopes: api, refresh_token, offline_access
```

#### Step 2: Configure CORS (5 min)
```
Salesforce Setup → CORS → New
- Origin URL: https://[pwa-domain]
- (Also add localhost for testing)
```

#### Step 3: Update PWA OAuth Config (15 min)
```javascript
// config.js
const SALESFORCE_CONFIG = {
  loginUrl: 'https://login.salesforce.com',
  clientId: '[Connected App Consumer Key]',
  redirectUri: 'https://[pwa-domain]/oauth/callback',
  scopes: ['api', 'refresh_token']
};
```

#### Step 4: Test OAuth Flow (30 min)
1. Click "Login with Salesforce" in PWA
2. Redirects to Salesforce login
3. User authorizes
4. Callback receives access token
5. PWA stores token securely
6. Test GET /routine/daily/{date}
7. Test POST /routine/daily

#### Step 5: Test Offline Sync (30 min)
1. Create wellness entry while offline
2. Queue in IndexedDB
3. Reconnect
4. Verify sync to Salesforce
5. Confirm no duplicates

### Deliverables
- [ ] Connected App created/verified
- [ ] CORS configured
- [ ] OAuth flow working
- [ ] Offline sync tested
- [ ] Documentation updated

### Success Criteria
✅ User can log wellness data from PWA
✅ Data appears in Salesforce Daily_Routine__c
✅ Works offline with sync on reconnect

---

## Integration #2: Recipe Aggregator

**Priority:** 🟡 MEDIUM
**Effort:** 2-3 hours
**Status:** Manual CSV export, no direct API

### Current State
- Python backend: recipe_aggregator.py (500+ LOC)
- React frontend for browsing
- 3 API sources: TheMealDB, Edamam, Spoonacular
- Output: CSV files
- Manual import to Salesforce Meal__c

### What's Missing
| Item | Status | Action |
|------|--------|--------|
| simple-salesforce library | ❌ Not installed | pip install |
| Salesforce credentials | ❌ Not configured | Add to config |
| Direct upsert logic | ❌ Not written | Add to script |
| External ID field | ❓ Unknown | Verify on Meal__c |
| Scheduled execution | ❌ Not set up | Add cron/scheduler |

### Implementation Steps

#### Step 1: Install Dependencies (5 min)
```bash
cd D:\New_Recipes_Program
pip install simple-salesforce python-dotenv
```

#### Step 2: Create Salesforce Config (10 min)
```python
# .env file (DO NOT COMMIT)
SF_USERNAME=your-username@example.com
SF_PASSWORD=your-password
SF_SECURITY_TOKEN=your-token
SF_DOMAIN=login  # or 'test' for sandbox
```

#### Step 3: Add External ID to Meal__c (10 min)
```
If not exists:
- Field: External_Recipe_ID__c
- Type: Text(255), External ID, Unique
- Purpose: Deduplication key
```

#### Step 4: Create Salesforce Sync Module (1 hour)
```python
# salesforce_sync.py
from simple_salesforce import Salesforce
from dotenv import load_dotenv
import os

load_dotenv()

class SalesforceSync:
    def __init__(self):
        self.sf = Salesforce(
            username=os.getenv('SF_USERNAME'),
            password=os.getenv('SF_PASSWORD'),
            security_token=os.getenv('SF_SECURITY_TOKEN'),
            domain=os.getenv('SF_DOMAIN', 'login')
        )
    
    def upsert_recipes(self, recipes: list):
        """
        Upsert recipes to Meal__c using External_Recipe_ID__c
        """
        records = []
        for recipe in recipes:
            records.append({
                'External_Recipe_ID__c': recipe['id'],
                'Name': recipe['name'][:80],  # SF limit
                'Description__c': recipe['description'],
                'Prep_Time__c': recipe['prep_time'],
                'Cook_Time__c': recipe['cook_time'],
                'Servings__c': recipe['servings'],
                'Calories__c': recipe['calories'],
                'Protein__c': recipe['protein'],
                'Carbs__c': recipe['carbs'],
                'Fat__c': recipe['fat'],
                'Sodium__c': recipe['sodium'],
                'Instructions__c': recipe['instructions'],
                'Image_URL__c': recipe['image_url'],
                'Source__c': recipe['source'],
                'Source_URL__c': recipe['source_url'],
                'Dietary_Tags__c': ';'.join(recipe.get('tags', [])),
                'Heart_Healthy__c': recipe.get('heart_healthy', False),
                'Diabetic_Friendly__c': recipe.get('diabetic_friendly', False),
                'Low_Sodium__c': recipe.get('low_sodium', False)
            })
        
        # Bulk upsert (200 at a time)
        results = self.sf.bulk.Meal__c.upsert(
            records, 
            'External_Recipe_ID__c',
            batch_size=200
        )
        
        return results

    def get_recipe_count(self):
        """Get current count of recipes in Salesforce"""
        result = self.sf.query("SELECT COUNT() FROM Meal__c")
        return result['totalSize']
```

#### Step 5: Integrate with Main Script (30 min)
```python
# Add to recipe_aggregator.py
from salesforce_sync import SalesforceSync

def sync_to_salesforce(recipes):
    """Sync collected recipes to Salesforce"""
    sync = SalesforceSync()
    
    print(f"Current Salesforce recipes: {sync.get_recipe_count()}")
    print(f"Syncing {len(recipes)} recipes...")
    
    results = sync.upsert_recipes(recipes)
    
    success = sum(1 for r in results if r.get('success'))
    failed = len(results) - success
    
    print(f"✅ Success: {success}")
    print(f"❌ Failed: {failed}")
    
    return results

# Call after collection
if __name__ == "__main__":
    recipes = collect_recipes()  # existing function
    filtered = filter_recipes(recipes)  # existing function
    sync_to_salesforce(filtered)  # NEW
```

#### Step 6: Add Scheduling (Optional, 30 min)
```python
# Option A: Windows Task Scheduler
# Create .bat file:
# cd D:\New_Recipes_Program
# python recipe_aggregator.py --sync

# Option B: Python schedule library
import schedule
import time

schedule.every().sunday.at("06:00").do(sync_to_salesforce)

while True:
    schedule.run_pending()
    time.sleep(3600)
```

### Deliverables
- [ ] simple-salesforce installed
- [ ] .env configured (not in git)
- [ ] External_Recipe_ID__c field verified/created
- [ ] salesforce_sync.py module created
- [ ] Integration with main script
- [ ] (Optional) Scheduling configured
- [ ] Documentation updated

### Success Criteria
✅ Running script syncs recipes directly to Salesforce
✅ No duplicate recipes (External ID handles upsert)
✅ Manual CSV step eliminated

---

## Integration #3: JARVIS Voice Assistant

**Priority:** 🟡 MEDIUM
**Effort:** 4-6 hours
**Status:** Architecture designed, no Salesforce connection

### Current State
- Location: D:\JARVIS + personal-ai-security-assistant repo
- 4-layer memory architecture spec (43KB)
- Security architecture spec (37KB)
- Python + FastAPI planned
- Claude API working
- Ollama in progress
- NO Salesforce authentication
- NO Salesforce data access

### Vision
JARVIS becomes the **unified voice interface** to all Salesforce data:

| Voice Command | Salesforce Action |
|---------------|-------------------|
| "What jobs came in today?" | Query Job_Posting__c WHERE CreatedDate = TODAY |
| "How many applications this week?" | Query Opportunity WHERE StageName = 'Applied' |
| "Log my energy as 7" | Insert Daily_Routine__c |
| "What's for dinner?" | Query Weekly_Meal_Plan__c for today |
| "Schedule interview Tuesday 2pm" | Insert Event |
| "Read my top job matches" | Query Job_Posting__c ORDER BY Fit_Score__c DESC |

### What's Missing
| Item | Status | Action |
|------|--------|--------|
| Salesforce OAuth in JARVIS | ❌ Not implemented | Add OAuth flow |
| Token storage | ❌ Not implemented | Secure storage |
| REST client module | ❌ Not implemented | Create SF client |
| Voice command → SF mapping | ❌ Not defined | Define intents |
| Error handling | ❌ Not implemented | Add retry/fallback |

### Implementation Steps

#### Step 1: Create/Reuse Connected App (15 min)
```
Option A: Reuse NeuroThrive PWA Connected App
Option B: Create dedicated JARVIS Connected App
- Name: JARVIS Assistant
- Enable OAuth: Yes
- Callback URL: http://localhost:8000/oauth/callback
- Scopes: api, refresh_token, offline_access
```

#### Step 2: Create Salesforce Client Module (1.5 hours)
```python
# jarvis/integrations/salesforce_client.py
from simple_salesforce import Salesforce
import os
import json
from pathlib import Path

class SalesforceClient:
    TOKEN_FILE = Path.home() / '.jarvis' / 'sf_tokens.json'
    
    def __init__(self):
        self.sf = None
        self._load_tokens()
    
    def _load_tokens(self):
        """Load stored OAuth tokens"""
        if self.TOKEN_FILE.exists():
            with open(self.TOKEN_FILE) as f:
                tokens = json.load(f)
                self.sf = Salesforce(
                    instance_url=tokens['instance_url'],
                    session_id=tokens['access_token']
                )
    
    def _save_tokens(self, tokens: dict):
        """Save OAuth tokens securely"""
        self.TOKEN_FILE.parent.mkdir(parents=True, exist_ok=True)
        with open(self.TOKEN_FILE, 'w') as f:
            json.dump(tokens, f)
        os.chmod(self.TOKEN_FILE, 0o600)  # Owner read/write only
    
    def authenticate(self, auth_code: str):
        """Exchange auth code for tokens"""
        # OAuth token exchange implementation
        pass
    
    def is_authenticated(self) -> bool:
        """Check if we have valid auth"""
        return self.sf is not None
    
    # ===== JOB SEARCH QUERIES =====
    
    def get_todays_jobs(self) -> list:
        """Get jobs imported today"""
        query = """
            SELECT Id, Title__c, Company__c, Salary_Min__c, Salary_Max__c,
                   Fit_Score__c, Remote_Policy__c, Apply_URL__c
            FROM Job_Posting__c
            WHERE CreatedDate = TODAY
            ORDER BY Fit_Score__c DESC
            LIMIT 10
        """
        return self.sf.query(query)['records']
    
    def get_top_matches(self, limit: int = 5) -> list:
        """Get highest fit score jobs"""
        query = f"""
            SELECT Id, Title__c, Company__c, Salary_Min__c, Salary_Max__c,
                   Fit_Score__c, ND_Friendliness_Score__c, Apply_URL__c
            FROM Job_Posting__c
            WHERE Application_Status__c = 'New'
            ORDER BY Fit_Score__c DESC
            LIMIT {limit}
        """
        return self.sf.query(query)['records']
    
    def get_application_count(self, days: int = 7) -> int:
        """Get application count for period"""
        query = f"""
            SELECT COUNT() FROM Opportunity
            WHERE StageName = 'Applied'
            AND CreatedDate = LAST_N_DAYS:{days}
        """
        return self.sf.query(query)['totalSize']
    
    # ===== WELLNESS QUERIES =====
    
    def log_energy(self, level: int, notes: str = None):
        """Log energy level to Daily_Routine__c"""
        record = {
            'Energy_Level__c': level,
            'Date__c': datetime.now().strftime('%Y-%m-%d'),
            'Notes__c': notes
        }
        return self.sf.Daily_Routine__c.create(record)
    
    def get_todays_routine(self) -> dict:
        """Get today's wellness data"""
        query = """
            SELECT Id, Energy_Level__c, Mood__c, Sleep_Hours__c, Notes__c
            FROM Daily_Routine__c
            WHERE Date__c = TODAY
            LIMIT 1
        """
        results = self.sf.query(query)['records']
        return results[0] if results else None
    
    # ===== MEAL QUERIES =====
    
    def get_todays_meals(self) -> list:
        """Get today's meal plan"""
        query = """
            SELECT Id, Meal_Type__c, Meal__r.Name, Meal__r.Calories__c
            FROM Weekly_Meal_Plan__c
            WHERE Date__c = TODAY
            ORDER BY Meal_Type__c
        """
        return self.sf.query(query)['records']
    
    # ===== CALENDAR =====
    
    def create_event(self, subject: str, start_time: datetime, 
                     duration_minutes: int = 60) -> dict:
        """Create calendar event"""
        record = {
            'Subject': subject,
            'StartDateTime': start_time.isoformat(),
            'EndDateTime': (start_time + timedelta(minutes=duration_minutes)).isoformat()
        }
        return self.sf.Event.create(record)
```

#### Step 3: Create Intent Handler (1.5 hours)
```python
# jarvis/handlers/salesforce_handler.py
from integrations.salesforce_client import SalesforceClient

class SalesforceHandler:
    def __init__(self):
        self.client = SalesforceClient()
    
    def handle_intent(self, intent: str, entities: dict) -> str:
        """Route intent to appropriate handler"""
        
        if not self.client.is_authenticated():
            return "I'm not connected to Salesforce. Please authenticate first."
        
        handlers = {
            'jobs_today': self._handle_jobs_today,
            'top_matches': self._handle_top_matches,
            'application_count': self._handle_application_count,
            'log_energy': self._handle_log_energy,
            'todays_meals': self._handle_todays_meals,
            'schedule_event': self._handle_schedule_event,
        }
        
        handler = handlers.get(intent)
        if handler:
            return handler(entities)
        return "I don't know how to handle that request."
    
    def _handle_jobs_today(self, entities: dict) -> str:
        jobs = self.client.get_todays_jobs()
        if not jobs:
            return "No new jobs came in today."
        
        response = f"You have {len(jobs)} new jobs today. "
        top = jobs[0]
        response += f"The top match is {top['Title__c']} at {top['Company__c']}"
        if top.get('Fit_Score__c'):
            response += f" with a fit score of {top['Fit_Score__c']}."
        return response
    
    def _handle_top_matches(self, entities: dict) -> str:
        limit = entities.get('count', 5)
        jobs = self.client.get_top_matches(limit)
        if not jobs:
            return "No job matches found."
        
        response = f"Your top {len(jobs)} job matches: "
        for i, job in enumerate(jobs, 1):
            response += f"{i}. {job['Title__c']} at {job['Company__c']}, "
            response += f"fit score {job.get('Fit_Score__c', 'unknown')}. "
        return response
    
    def _handle_log_energy(self, entities: dict) -> str:
        level = entities.get('level')
        if not level:
            return "What's your energy level from 1 to 10?"
        
        self.client.log_energy(level, entities.get('notes'))
        return f"Logged your energy as {level}."
    
    def _handle_todays_meals(self, entities: dict) -> str:
        meals = self.client.get_todays_meals()
        if not meals:
            return "No meals planned for today."
        
        response = "Today's meals: "
        for meal in meals:
            response += f"{meal['Meal_Type__c']}: {meal['Meal__r']['Name']}. "
        return response
```

#### Step 4: Add Voice Command Patterns (1 hour)
```python
# jarvis/intents/salesforce_intents.py
SALESFORCE_INTENTS = {
    'jobs_today': [
        "what jobs came in today",
        "any new jobs today",
        "show me today's jobs",
        "new job postings",
    ],
    'top_matches': [
        "what are my top job matches",
        "best job matches",
        "show top jobs",
        "read my top {count} matches",
    ],
    'application_count': [
        "how many applications this week",
        "application count",
        "how many jobs did I apply to",
    ],
    'log_energy': [
        "log my energy as {level}",
        "energy level {level}",
        "set energy to {level}",
    ],
    'todays_meals': [
        "what's for dinner",
        "what are today's meals",
        "show meal plan",
        "what should I eat",
    ],
    'schedule_event': [
        "schedule interview {day} at {time}",
        "add meeting {day} {time}",
        "create event {subject}",
    ],
}
```

#### Step 5: Add OAuth Web Flow (1 hour)
```python
# jarvis/api/oauth.py
from fastapi import APIRouter, Request
from fastapi.responses import RedirectResponse
import httpx

router = APIRouter()

SALESFORCE_AUTH_URL = "https://login.salesforce.com/services/oauth2/authorize"
SALESFORCE_TOKEN_URL = "https://login.salesforce.com/services/oauth2/token"
CLIENT_ID = os.getenv('SF_CLIENT_ID')
CLIENT_SECRET = os.getenv('SF_CLIENT_SECRET')
REDIRECT_URI = "http://localhost:8000/oauth/callback"

@router.get("/oauth/start")
async def start_oauth():
    """Redirect to Salesforce login"""
    params = {
        'response_type': 'code',
        'client_id': CLIENT_ID,
        'redirect_uri': REDIRECT_URI,
        'scope': 'api refresh_token'
    }
    url = f"{SALESFORCE_AUTH_URL}?{'&'.join(f'{k}={v}' for k,v in params.items())}"
    return RedirectResponse(url)

@router.get("/oauth/callback")
async def oauth_callback(code: str):
    """Handle OAuth callback"""
    async with httpx.AsyncClient() as client:
        response = await client.post(SALESFORCE_TOKEN_URL, data={
            'grant_type': 'authorization_code',
            'code': code,
            'client_id': CLIENT_ID,
            'client_secret': CLIENT_SECRET,
            'redirect_uri': REDIRECT_URI
        })
    
    tokens = response.json()
    sf_client = SalesforceClient()
    sf_client._save_tokens(tokens)
    
    return {"status": "connected", "instance_url": tokens['instance_url']}
```

### Deliverables
- [ ] Connected App configured
- [ ] salesforce_client.py module
- [ ] Intent handler module
- [ ] Voice command patterns
- [ ] OAuth web flow
- [ ] Token storage (secure)
- [ ] Error handling
- [ ] Documentation updated

### Success Criteria
✅ "What jobs came in today?" returns Salesforce data
✅ "Log my energy as 7" creates Daily_Routine__c record
✅ "What's for dinner?" reads meal plan
✅ OAuth tokens persist between sessions
✅ Graceful handling when not authenticated

---

## Integration #4: SafeHaven Android

**Priority:** 🟢 LOWER (Most Complex)
**Effort:** 4-6 hours
**Status:** No Salesforce objects, no REST endpoints

### Current State
- Location: D:\SafeHaven-Build, D:\Safehaven-documentation
- Tech: Kotlin + Jetpack Compose
- Local DB: Room + SQLCipher (encrypted)
- Blockchain: Polygon for document timestamping
- NO Salesforce connection
- NO Resource database in Salesforce

### Vision
SafeHaven connects to Salesforce for:
1. **Resource Database** — DV shelters, legal aid, hotlines
2. **Zero-Knowledge Sync** — Encrypted backup without exposing content
3. **Cross-App Support** — Link to NeuroThrive for economic independence tracking

### What's Missing
| Item | Status | Action |
|------|--------|--------|
| Resource__c object | ❌ Not created | Create custom object |
| Resource REST API | ❌ Not created | Create Apex REST |
| Encrypted_Backup__c | ❌ Not created | For zero-knowledge sync |
| OAuth in Android | ❌ Not implemented | Add Salesforce SDK |
| Resource sync logic | ❌ Not implemented | Add to app |

### Implementation Steps

#### Step 1: Create Resource__c Object (30 min)
```xml
<!-- Resource__c.object-meta.xml -->
<CustomObject>
    <label>Resource</label>
    <pluralLabel>Resources</pluralLabel>
    <nameField>
        <label>Resource Name</label>
        <type>Text</type>
    </nameField>
    <deploymentStatus>Deployed</deploymentStatus>
    <sharingModel>ReadWrite</sharingModel>
</CustomObject>
```

**Fields:**
| Field | Type | Purpose |
|-------|------|---------|
| Name | Text(80) | Resource name |
| Type__c | Picklist | Shelter, Legal, Hotline, Financial, Medical |
| Description__c | Long Text | Description |
| Phone__c | Phone | Contact phone |
| Email__c | Email | Contact email |
| Website__c | URL | Website |
| Address__c | Text Area | Physical address |
| City__c | Text | City |
| State__c | Text | State/Province |
| Zip_Code__c | Text | Postal code |
| Country__c | Text | Country |
| Latitude__c | Number(3,7) | For proximity search |
| Longitude__c | Number(3,7) | For proximity search |
| Hours__c | Text Area | Operating hours |
| Languages__c | Multipicklist | Supported languages |
| Services__c | Multipicklist | Specific services offered |
| Confidential__c | Checkbox | Confidential location |
| Verified__c | Checkbox | Staff verified |
| Last_Verified__c | Date | Last verification date |
| Active__c | Checkbox | Currently operating |
| External_ID__c | Text(255) | External ID, Unique |

#### Step 2: Create Resource REST API (1 hour)
```apex
// ResourceAPI.cls
@RestResource(urlMapping='/resources/*')
global class ResourceAPI {
    
    @HttpGet
    global static List<Resource__c> getResources() {
        RestRequest req = RestContext.request;
        String resourceType = req.params.get('type');
        String state = req.params.get('state');
        String city = req.params.get('city');
        Decimal lat = req.params.get('lat') != null ? 
            Decimal.valueOf(req.params.get('lat')) : null;
        Decimal lng = req.params.get('lng') != null ? 
            Decimal.valueOf(req.params.get('lng')) : null;
        Decimal radius = req.params.get('radius') != null ? 
            Decimal.valueOf(req.params.get('radius')) : 50; // miles
        
        String query = 'SELECT Id, Name, Type__c, Description__c, Phone__c, ' +
            'Email__c, Website__c, Address__c, City__c, State__c, ' +
            'Zip_Code__c, Hours__c, Languages__c, Services__c, ' +
            'Latitude__c, Longitude__c ' +
            'FROM Resource__c WHERE Active__c = true';
        
        if (String.isNotBlank(resourceType)) {
            query += ' AND Type__c = :resourceType';
        }
        if (String.isNotBlank(state)) {
            query += ' AND State__c = :state';
        }
        if (String.isNotBlank(city)) {
            query += ' AND City__c = :city';
        }
        
        query += ' ORDER BY Name LIMIT 100';
        
        List<Resource__c> resources = Database.query(query);
        
        // If lat/lng provided, filter by distance
        if (lat != null && lng != null) {
            resources = filterByDistance(resources, lat, lng, radius);
        }
        
        return resources;
    }
    
    private static List<Resource__c> filterByDistance(
        List<Resource__c> resources, 
        Decimal userLat, 
        Decimal userLng, 
        Decimal radiusMiles
    ) {
        List<Resource__c> nearby = new List<Resource__c>();
        
        for (Resource__c r : resources) {
            if (r.Latitude__c != null && r.Longitude__c != null) {
                Decimal distance = calculateDistance(
                    userLat, userLng, 
                    r.Latitude__c, r.Longitude__c
                );
                if (distance <= radiusMiles) {
                    nearby.add(r);
                }
            }
        }
        
        return nearby;
    }
    
    private static Decimal calculateDistance(
        Decimal lat1, Decimal lon1, 
        Decimal lat2, Decimal lon2
    ) {
        // Haversine formula
        Decimal R = 3959; // Earth radius in miles
        Decimal dLat = (lat2 - lat1) * Math.PI / 180;
        Decimal dLon = (lon2 - lon1) * Math.PI / 180;
        Decimal a = Math.sin(dLat/2) * Math.sin(dLat/2) +
            Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
            Math.sin(dLon/2) * Math.sin(dLon/2);
        Decimal c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
        return R * c;
    }
}
```

#### Step 3: Create Encrypted Backup Object (30 min)
```xml
<!-- Encrypted_Backup__c for zero-knowledge sync -->
```

**Fields:**
| Field | Type | Purpose |
|-------|------|---------|
| Device_ID__c | Text(255) | Unique device identifier (hashed) |
| Encrypted_Payload__c | Long Text | AES-256 encrypted data |
| Payload_Hash__c | Text(64) | SHA-256 of plaintext (for integrity) |
| Created_Date__c | DateTime | Backup timestamp |
| Backup_Type__c | Picklist | Full, Incremental, Evidence |

**Security Note:** Salesforce stores encrypted blob. Only device has key. Zero-knowledge = Salesforce cannot read content.

#### Step 4: Add Salesforce SDK to Android (1 hour)
```kotlin
// build.gradle.kts (app level)
dependencies {
    implementation("com.salesforce.mobilesdk:SalesforceSDK:11.1.0")
}

// SalesforceConfig.kt
object SalesforceConfig {
    const val CLIENT_ID = "your-connected-app-consumer-key"
    const val CALLBACK_URL = "safehaven://oauth/callback"
    const val SCOPES = arrayOf("api", "refresh_token")
}

// SalesforceManager.kt
class SalesforceManager(private val context: Context) {
    
    private var restClient: RestClient? = null
    
    fun authenticate(callback: (Boolean) -> Unit) {
        // Launch OAuth flow
        SalesforceSDKManager.getInstance().authenticate(
            context as Activity,
            object : ClientManager.LoginCallback {
                override fun onLoginSuccess(client: RestClient) {
                    restClient = client
                    callback(true)
                }
                override fun onLoginFailed(error: String) {
                    callback(false)
                }
            }
        )
    }
    
    suspend fun getResources(
        type: String? = null,
        lat: Double? = null,
        lng: Double? = null,
        radius: Double = 50.0
    ): List<Resource> {
        val params = mutableMapOf<String, String>()
        type?.let { params["type"] = it }
        lat?.let { params["lat"] = it.toString() }
        lng?.let { params["lng"] = it.toString() }
        params["radius"] = radius.toString()
        
        val request = RestRequest.getRequestForGet(
            "/services/apexrest/resources",
            params
        )
        
        val response = restClient?.sendSync(request)
        return parseResources(response?.asJSONArray())
    }
    
    suspend fun backupEncrypted(
        deviceId: String,
        encryptedPayload: String,
        payloadHash: String
    ): Boolean {
        val record = JSONObject().apply {
            put("Device_ID__c", deviceId)
            put("Encrypted_Payload__c", encryptedPayload)
            put("Payload_Hash__c", payloadHash)
        }
        
        val request = RestRequest.getRequestForCreate(
            "Encrypted_Backup__c",
            record
        )
        
        val response = restClient?.sendSync(request)
        return response?.isSuccess == true
    }
}
```

#### Step 5: Implement Resource Sync in App (1 hour)
```kotlin
// ResourceRepository.kt
class ResourceRepository(
    private val localDb: SafeHavenDatabase,
    private val salesforceManager: SalesforceManager
) {
    suspend fun syncResources(
        userLocation: Location?
    ) = withContext(Dispatchers.IO) {
        try {
            val resources = salesforceManager.getResources(
                lat = userLocation?.latitude,
                lng = userLocation?.longitude,
                radius = 100.0
            )
            
            // Update local cache
            localDb.resourceDao().insertAll(
                resources.map { it.toLocalEntity() }
            )
            
            Result.success(resources)
        } catch (e: Exception) {
            // Return cached data if offline
            val cached = localDb.resourceDao().getAll()
            Result.success(cached.map { it.toResource() })
        }
    }
}
```

#### Step 6: Seed Resource Data (1 hour)
- National Domestic Violence Hotline
- State-by-state shelter databases
- Legal aid organizations
- Financial assistance programs

### Deliverables
- [ ] Resource__c object created
- [ ] Resource fields deployed
- [ ] ResourceAPI.cls created
- [ ] Encrypted_Backup__c object created
- [ ] Salesforce SDK added to Android
- [ ] SalesforceManager.kt implemented
- [ ] Resource sync working
- [ ] Encrypted backup working
- [ ] Initial resource data seeded

### Success Criteria
✅ App can query nearby resources from Salesforce
✅ Works offline with cached data
✅ Encrypted backups sync to Salesforce
✅ Zero-knowledge (SF cannot read backup content)
✅ Location-based proximity search works

---

## Implementation Timeline

```
┌─────────────────────────────────────────────────────────────────┐
│                    INTEGRATION TIMELINE                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  WEEK 1 (Dec 26 - Jan 1)                                       │
│  ├── Day 1-2: PWA OAuth Connection (1-2 hrs) ✅ QUICK WIN      │
│  ├── Day 3-4: Recipe Aggregator API (2-3 hrs)                  │
│  └── Day 5-7: JARVIS OAuth + Basic Queries (3-4 hrs)           │
│                                                                 │
│  WEEK 2 (Jan 2 - Jan 8)                                        │
│  ├── Day 1-2: JARVIS Intent Handlers (2 hrs)                   │
│  ├── Day 3-4: JARVIS Voice Commands (2 hrs)                    │
│  └── Day 5-7: Testing & Documentation                          │
│                                                                 │
│  WEEK 3 (Jan 9 - Jan 15)                                       │
│  ├── Day 1-2: SafeHaven Resource__c Object (1 hr)              │
│  ├── Day 3-4: SafeHaven REST API (1 hr)                        │
│  ├── Day 5-6: SafeHaven Android SDK (2 hrs)                    │
│  └── Day 7: SafeHaven Resource Sync (2 hrs)                    │
│                                                                 │
│  WEEK 4 (Jan 16 - Jan 22)                                      │
│  ├── Day 1-3: SafeHaven Encrypted Backup (2 hrs)               │
│  ├── Day 4-5: Seed Resource Data (2 hrs)                       │
│  └── Day 6-7: Full Integration Testing                         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Dependencies & Prerequisites

### All Integrations
- [ ] Salesforce Connected App (can be shared)
- [ ] OAuth scopes: api, refresh_token, offline_access
- [ ] CORS configuration for web apps

### PWA Specific
- [ ] PWA hosting domain finalized
- [ ] SSL certificate (required for OAuth)

### Recipe Aggregator Specific
- [ ] Python 3.8+
- [ ] simple-salesforce library
- [ ] Salesforce security token

### JARVIS Specific
- [ ] FastAPI server running
- [ ] Token storage location (~/.jarvis/)
- [ ] Voice recognition working (separate from SF)

### SafeHaven Specific
- [ ] Android SDK 21+
- [ ] Salesforce Mobile SDK 11.x
- [ ] Initial resource data source

---

## Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| OAuth token expiration | Medium | Implement refresh token flow |
| CORS issues | Low | Test early, configure properly |
| API limits | Low | Batch operations, caching |
| Offline sync conflicts | Medium | Last-write-wins or merge strategy |
| SafeHaven security review | High | Document zero-knowledge architecture |

---

## Success Metrics

| Integration | Metric | Target |
|-------------|--------|--------|
| PWA | Wellness entries synced | 100% |
| Recipe Aggregator | Auto-sync frequency | Weekly |
| JARVIS | Voice commands working | 10+ intents |
| SafeHaven | Resources queryable | 500+ |
| SafeHaven | Backup success rate | 99% |

---

## Next Steps After This Roadmap

1. **Review with Claude Code** — Get technical recommendations
2. **Prioritize based on Agentforce exam** (Dec 30)
3. **Start with PWA** (quick win, 1-2 hours)
4. **Parallel work** — Can do Recipe Aggregator same day

---

*Roadmap created December 26, 2025*
*Ready for Claude Code review*
