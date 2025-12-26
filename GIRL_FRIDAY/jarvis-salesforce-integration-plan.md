# JARVIS ↔ Salesforce Personal Integration Plan

**Created:** December 26, 2025
**Purpose:** Enable JARVIS to pull/push data from Salesforce for personal use
**Visibility:** PRIVATE — Not for GitHub publication

---

## Goal

Work in ONE system (JARVIS voice/chat) instead of switching between:
- Salesforce UI
- Job search dashboards
- Meal planning screens
- Calendar apps

JARVIS becomes your **single interface** to all data.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                         JARVIS                               │
│                   (Personal AI Assistant)                    │
│                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │   Voice     │  │    Chat     │  │  Scheduled  │        │
│  │   Input     │  │   Input     │  │   Tasks     │        │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘        │
│         │                │                │                │
│         └────────────────┼────────────────┘                │
│                          ▼                                  │
│              ┌───────────────────────┐                     │
│              │   Intent Router       │                     │
│              │   (Claude AI)         │                     │
│              └───────────┬───────────┘                     │
│                          │                                  │
│         ┌────────────────┼────────────────┐                │
│         ▼                ▼                ▼                │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐          │
│  │ SF Client  │  │  Memory    │  │  External  │          │
│  │ Module     │  │  Layer     │  │  APIs      │          │
│  └─────┬──────┘  └────────────┘  └────────────┘          │
│        │                                                   │
└────────┼───────────────────────────────────────────────────┘
         │
         │ OAuth 2.0 + REST
         ▼
┌─────────────────────────────────────────────────────────────┐
│                    SALESFORCE ORG                           │
│                                                             │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐     │
│  │Job_Post  │ │Daily_    │ │Meal__c   │ │Event     │     │
│  │ing__c    │ │Routine__c│ │          │ │          │     │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Phase 1: Authentication Setup (1 hour)

### Step 1.1: Create Connected App in Salesforce

**Location:** Setup → App Manager → New Connected App

**Settings:**
| Field | Value |
|-------|-------|
| Connected App Name | JARVIS Personal Assistant |
| API Name | JARVIS_Personal_Assistant |
| Contact Email | [your email] |
| Enable OAuth Settings | ✅ Checked |
| Callback URL | http://localhost:8000/oauth/callback |
| Selected OAuth Scopes | api, refresh_token, offline_access |
| Require Proof Key for Code Exchange (PKCE) | ✅ Recommended |

**After Creation:**
- Note Consumer Key
- Note Consumer Secret (store securely, NOT in code)

### Step 1.2: Create Secure Credential Storage

**Location:** `D:\JARVIS\.credentials\` (git-ignored)

```python
# credentials_manager.py
import os
import json
from pathlib import Path
from cryptography.fernet import Fernet

class CredentialsManager:
    """Secure storage for OAuth tokens - NEVER commit to git"""
    
    CRED_DIR = Path.home() / '.jarvis' / 'credentials'
    KEY_FILE = CRED_DIR / '.key'
    TOKEN_FILE = CRED_DIR / 'sf_tokens.enc'
    
    def __init__(self):
        self.CRED_DIR.mkdir(parents=True, exist_ok=True)
        self._ensure_key()
    
    def _ensure_key(self):
        """Create or load encryption key"""
        if not self.KEY_FILE.exists():
            key = Fernet.generate_key()
            self.KEY_FILE.write_bytes(key)
            os.chmod(self.KEY_FILE, 0o600)
        self.fernet = Fernet(self.KEY_FILE.read_bytes())
    
    def save_tokens(self, tokens: dict):
        """Encrypt and save OAuth tokens"""
        encrypted = self.fernet.encrypt(json.dumps(tokens).encode())
        self.TOKEN_FILE.write_bytes(encrypted)
        os.chmod(self.TOKEN_FILE, 0o600)
    
    def load_tokens(self) -> dict:
        """Load and decrypt OAuth tokens"""
        if not self.TOKEN_FILE.exists():
            return None
        encrypted = self.TOKEN_FILE.read_bytes()
        return json.loads(self.fernet.decrypt(encrypted))
    
    def clear_tokens(self):
        """Remove stored tokens"""
        if self.TOKEN_FILE.exists():
            self.TOKEN_FILE.unlink()
```

### Step 1.3: Add to .gitignore

```gitignore
# JARVIS credentials - NEVER commit
.credentials/
*.enc
.key
sf_tokens.*
.env
```

---

## Phase 2: Salesforce Client Module (2 hours)

### Step 2.1: Core Client Class

```python
# jarvis/integrations/salesforce.py
from simple_salesforce import Salesforce
from datetime import datetime, timedelta
from typing import Optional, List, Dict, Any
import logging

logger = logging.getLogger(__name__)

class SalesforceClient:
    """
    Salesforce integration for JARVIS personal assistant.
    Handles OAuth, queries, and CRUD operations.
    """
    
    def __init__(self, credentials_manager):
        self.creds = credentials_manager
        self.sf: Optional[Salesforce] = None
        self._connect()
    
    def _connect(self):
        """Establish connection using stored tokens"""
        tokens = self.creds.load_tokens()
        if tokens:
            try:
                self.sf = Salesforce(
                    instance_url=tokens['instance_url'],
                    session_id=tokens['access_token']
                )
                logger.info("Connected to Salesforce")
            except Exception as e:
                logger.error(f"SF connection failed: {e}")
                self.sf = None
    
    @property
    def is_connected(self) -> bool:
        return self.sf is not None
    
    # =========================================
    # JOB SEARCH QUERIES
    # =========================================
    
    def get_jobs_today(self) -> List[Dict]:
        """Get jobs imported today"""
        query = """
            SELECT Id, Title__c, Company__c, Location__c,
                   Salary_Min__c, Salary_Max__c, Fit_Score__c,
                   ND_Friendliness_Score__c, Remote_Policy__c,
                   Apply_URL__c, Provider__c
            FROM Job_Posting__c
            WHERE CreatedDate = TODAY
            ORDER BY Fit_Score__c DESC NULLS LAST
            LIMIT 20
        """
        return self.sf.query(query)['records']
    
    def get_top_matches(self, limit: int = 5) -> List[Dict]:
        """Get highest scoring job matches"""
        query = f"""
            SELECT Id, Title__c, Company__c, Location__c,
                   Salary_Min__c, Salary_Max__c, Fit_Score__c,
                   ND_Friendliness_Score__c, Remote_Policy__c,
                   Apply_URL__c
            FROM Job_Posting__c
            WHERE Application_Status__c = 'New'
              AND Fit_Score__c != null
            ORDER BY Fit_Score__c DESC
            LIMIT {limit}
        """
        return self.sf.query(query)['records']
    
    def get_jobs_by_company(self, company: str) -> List[Dict]:
        """Search jobs by company name"""
        query = f"""
            SELECT Id, Title__c, Company__c, Location__c,
                   Salary_Min__c, Salary_Max__c, Fit_Score__c,
                   Apply_URL__c
            FROM Job_Posting__c
            WHERE Company__c LIKE '%{company}%'
            ORDER BY CreatedDate DESC
            LIMIT 10
        """
        return self.sf.query(query)['records']
    
    def get_application_stats(self, days: int = 7) -> Dict:
        """Get application statistics"""
        stats = {}
        
        # Total applications
        query = f"""
            SELECT COUNT() FROM Opportunity
            WHERE StageName = 'Applied'
              AND CreatedDate = LAST_N_DAYS:{days}
        """
        stats['applied'] = self.sf.query(query)['totalSize']
        
        # By stage
        query = f"""
            SELECT StageName, COUNT(Id) cnt
            FROM Opportunity
            WHERE CreatedDate = LAST_N_DAYS:{days}
            GROUP BY StageName
        """
        stats['by_stage'] = {r['StageName']: r['cnt'] 
                           for r in self.sf.query(query)['records']}
        
        return stats
    
    def update_job_status(self, job_id: str, status: str) -> bool:
        """Update job application status"""
        try:
            self.sf.Job_Posting__c.update(job_id, {
                'Application_Status__c': status
            })
            return True
        except Exception as e:
            logger.error(f"Failed to update job status: {e}")
            return False
    
    # =========================================
    # WELLNESS QUERIES
    # =========================================
    
    def get_todays_routine(self) -> Optional[Dict]:
        """Get today's wellness data"""
        query = """
            SELECT Id, Energy_Level__c, Mood__c, Sleep_Hours__c,
                   Exercise_Minutes__c, Water_Intake__c, Notes__c
            FROM Daily_Routine__c
            WHERE Date__c = TODAY
            LIMIT 1
        """
        records = self.sf.query(query)['records']
        return records[0] if records else None
    
    def log_wellness(self, **kwargs) -> Dict:
        """
        Log wellness data. Creates or updates today's record.
        
        Accepts: energy, mood, sleep, exercise, water, notes
        """
        today = datetime.now().strftime('%Y-%m-%d')
        
        # Check for existing record
        existing = self.get_todays_routine()
        
        record = {
            'Date__c': today,
            'Energy_Level__c': kwargs.get('energy'),
            'Mood__c': kwargs.get('mood'),
            'Sleep_Hours__c': kwargs.get('sleep'),
            'Exercise_Minutes__c': kwargs.get('exercise'),
            'Water_Intake__c': kwargs.get('water'),
            'Notes__c': kwargs.get('notes'),
        }
        
        # Remove None values
        record = {k: v for k, v in record.items() if v is not None}
        
        if existing:
            self.sf.Daily_Routine__c.update(existing['Id'], record)
            return {'action': 'updated', 'id': existing['Id']}
        else:
            result = self.sf.Daily_Routine__c.create(record)
            return {'action': 'created', 'id': result['id']}
    
    def get_wellness_trend(self, days: int = 7) -> List[Dict]:
        """Get wellness data for trend analysis"""
        query = f"""
            SELECT Date__c, Energy_Level__c, Mood__c, Sleep_Hours__c
            FROM Daily_Routine__c
            WHERE Date__c = LAST_N_DAYS:{days}
            ORDER BY Date__c DESC
        """
        return self.sf.query(query)['records']
    
    # =========================================
    # MEAL PLANNING QUERIES
    # =========================================
    
    def get_todays_meals(self) -> List[Dict]:
        """Get today's meal plan"""
        query = """
            SELECT Id, Meal_Type__c, 
                   Meal__r.Name, Meal__r.Calories__c,
                   Meal__r.Prep_Time__c, Meal__r.Instructions__c
            FROM Weekly_Meal_Plan__c
            WHERE Date__c = TODAY
            ORDER BY NULLS LAST
        """
        return self.sf.query(query)['records']
    
    def get_weekly_meals(self) -> List[Dict]:
        """Get this week's meal plan"""
        query = """
            SELECT Id, Date__c, Meal_Type__c,
                   Meal__r.Name, Meal__r.Calories__c
            FROM Weekly_Meal_Plan__c
            WHERE Date__c = THIS_WEEK
            ORDER BY Date__c, Meal_Type__c
        """
        return self.sf.query(query)['records']
    
    def search_recipes(self, keyword: str, limit: int = 5) -> List[Dict]:
        """Search recipes by keyword"""
        query = f"""
            SELECT Id, Name, Calories__c, Prep_Time__c,
                   Cook_Time__c, Heart_Healthy__c, Low_Sodium__c
            FROM Meal__c
            WHERE Name LIKE '%{keyword}%'
            LIMIT {limit}
        """
        return self.sf.query(query)['records']
    
    # =========================================
    # CALENDAR / EVENTS
    # =========================================
    
    def get_upcoming_events(self, days: int = 7) -> List[Dict]:
        """Get upcoming calendar events"""
        query = f"""
            SELECT Id, Subject, StartDateTime, EndDateTime,
                   Location, Description
            FROM Event
            WHERE StartDateTime >= TODAY
              AND StartDateTime <= NEXT_N_DAYS:{days}
            ORDER BY StartDateTime
        """
        return self.sf.query(query)['records']
    
    def create_event(self, subject: str, start: datetime,
                    duration_minutes: int = 60,
                    location: str = None,
                    description: str = None) -> Dict:
        """Create a calendar event"""
        end = start + timedelta(minutes=duration_minutes)
        
        record = {
            'Subject': subject,
            'StartDateTime': start.isoformat(),
            'EndDateTime': end.isoformat(),
            'Location': location,
            'Description': description,
        }
        record = {k: v for k, v in record.items() if v is not None}
        
        result = self.sf.Event.create(record)
        return {'id': result['id'], 'subject': subject, 'start': start}
    
    # =========================================
    # QUICK SUMMARIES
    # =========================================
    
    def get_morning_briefing(self) -> Dict:
        """
        Comprehensive morning summary for JARVIS.
        Single call to get all relevant daily data.
        """
        return {
            'jobs_today': len(self.get_jobs_today()),
            'top_job': self.get_top_matches(1)[0] if self.get_top_matches(1) else None,
            'application_stats': self.get_application_stats(7),
            'wellness_yesterday': self.get_wellness_trend(1),
            'todays_meals': self.get_todays_meals(),
            'upcoming_events': self.get_upcoming_events(1),
        }
    
    def get_job_search_summary(self) -> Dict:
        """Job search focused summary"""
        return {
            'new_today': self.get_jobs_today(),
            'top_matches': self.get_top_matches(5),
            'stats': self.get_application_stats(7),
        }
```

---

## Phase 3: Voice Command Integration (2 hours)

### Step 3.1: Intent Definitions

```python
# jarvis/intents/salesforce_intents.py

SALESFORCE_INTENTS = {
    # Job Search
    'sf.jobs.today': {
        'patterns': [
            "what jobs came in today",
            "any new jobs",
            "show today's jobs",
            "new job postings",
            "what's new in job search",
        ],
        'handler': 'handle_jobs_today',
    },
    'sf.jobs.top': {
        'patterns': [
            "what are my top matches",
            "best job matches",
            "show top jobs",
            "highest scoring jobs",
        ],
        'handler': 'handle_top_matches',
    },
    'sf.jobs.company': {
        'patterns': [
            "jobs at {company}",
            "any positions at {company}",
            "show {company} jobs",
        ],
        'handler': 'handle_jobs_by_company',
        'entities': ['company'],
    },
    'sf.jobs.stats': {
        'patterns': [
            "how many applications",
            "application stats",
            "job search progress",
        ],
        'handler': 'handle_application_stats',
    },
    
    # Wellness
    'sf.wellness.log': {
        'patterns': [
            "log my energy as {level}",
            "energy level {level}",
            "set energy to {level}",
            "mood is {mood}",
            "slept {hours} hours",
        ],
        'handler': 'handle_log_wellness',
        'entities': ['level', 'mood', 'hours'],
    },
    'sf.wellness.check': {
        'patterns': [
            "how am I doing",
            "wellness check",
            "how's my energy trend",
        ],
        'handler': 'handle_wellness_check',
    },
    
    # Meals
    'sf.meals.today': {
        'patterns': [
            "what's for dinner",
            "today's meals",
            "what should I eat",
            "meal plan for today",
        ],
        'handler': 'handle_todays_meals',
    },
    'sf.meals.week': {
        'patterns': [
            "this week's meals",
            "weekly meal plan",
            "what's for dinner this week",
        ],
        'handler': 'handle_weekly_meals',
    },
    'sf.meals.search': {
        'patterns': [
            "find recipes for {food}",
            "search recipes {food}",
            "any {food} recipes",
        ],
        'handler': 'handle_recipe_search',
        'entities': ['food'],
    },
    
    # Calendar
    'sf.calendar.upcoming': {
        'patterns': [
            "what's on my calendar",
            "upcoming events",
            "any meetings today",
            "what's scheduled",
        ],
        'handler': 'handle_upcoming_events',
    },
    'sf.calendar.add': {
        'patterns': [
            "schedule {event} on {day} at {time}",
            "add meeting {event}",
            "create event {event}",
        ],
        'handler': 'handle_create_event',
        'entities': ['event', 'day', 'time'],
    },
    
    # Summaries
    'sf.briefing.morning': {
        'patterns': [
            "morning briefing",
            "what's my day look like",
            "daily summary",
            "brief me",
        ],
        'handler': 'handle_morning_briefing',
    },
    'sf.briefing.jobs': {
        'patterns': [
            "job search summary",
            "how's the job hunt",
            "job search update",
        ],
        'handler': 'handle_job_summary',
    },
}
```

### Step 3.2: Response Handlers

```python
# jarvis/handlers/salesforce_handler.py

class SalesforceHandler:
    """Handles Salesforce-related voice commands"""
    
    def __init__(self, sf_client: SalesforceClient):
        self.sf = sf_client
    
    def handle_jobs_today(self, entities: dict) -> str:
        jobs = self.sf.get_jobs_today()
        if not jobs:
            return "No new jobs came in today. I'll let you know when something arrives."
        
        count = len(jobs)
        top = jobs[0]
        
        response = f"You have {count} new jobs today. "
        response += f"The top match is {top['Title__c']} at {top['Company__c']}"
        
        if top.get('Fit_Score__c'):
            response += f" with a fit score of {top['Fit_Score__c']:.1f}."
        
        if top.get('Salary_Max__c'):
            response += f" Salary up to ${int(top['Salary_Max__c']):,}."
        
        return response
    
    def handle_top_matches(self, entities: dict) -> str:
        jobs = self.sf.get_top_matches(5)
        if not jobs:
            return "No scored job matches right now."
        
        response = f"Your top {len(jobs)} job matches: "
        for i, job in enumerate(jobs, 1):
            response += f"{i}. {job['Title__c']} at {job['Company__c']}, "
            response += f"score {job.get('Fit_Score__c', 'unknown')}. "
        
        return response
    
    def handle_application_stats(self, entities: dict) -> str:
        stats = self.sf.get_application_stats(7)
        
        response = f"In the last 7 days: {stats['applied']} applications submitted. "
        
        if stats.get('by_stage'):
            stages = stats['by_stage']
            if stages.get('Interview'):
                response += f"{stages['Interview']} in interview stage. "
            if stages.get('Offer'):
                response += f"{stages['Offer']} offers! "
        
        return response
    
    def handle_log_wellness(self, entities: dict) -> str:
        kwargs = {}
        
        if 'level' in entities:
            kwargs['energy'] = int(entities['level'])
        if 'mood' in entities:
            kwargs['mood'] = entities['mood']
        if 'hours' in entities:
            kwargs['sleep'] = float(entities['hours'])
        
        result = self.sf.log_wellness(**kwargs)
        
        if result['action'] == 'created':
            return "Got it, started tracking today's wellness."
        else:
            return "Updated your wellness log."
    
    def handle_todays_meals(self, entities: dict) -> str:
        meals = self.sf.get_todays_meals()
        if not meals:
            return "No meals planned for today. Want me to suggest something?"
        
        response = "Today's meals: "
        for meal in meals:
            meal_name = meal.get('Meal__r', {}).get('Name', 'Unknown')
            meal_type = meal.get('Meal_Type__c', '')
            response += f"{meal_type}: {meal_name}. "
        
        return response
    
    def handle_morning_briefing(self, entities: dict) -> str:
        data = self.sf.get_morning_briefing()
        
        response = "Good morning! Here's your briefing. "
        
        # Jobs
        response += f"{data['jobs_today']} new jobs today. "
        if data['top_job']:
            response += f"Top match: {data['top_job']['Title__c']} at {data['top_job']['Company__c']}. "
        
        # Stats
        stats = data['application_stats']
        response += f"{stats['applied']} applications this week. "
        
        # Meals
        if data['todays_meals']:
            dinner = next((m for m in data['todays_meals'] 
                          if m.get('Meal_Type__c') == 'Dinner'), None)
            if dinner:
                response += f"Dinner tonight: {dinner.get('Meal__r', {}).get('Name', 'check plan')}. "
        
        # Events
        if data['upcoming_events']:
            event = data['upcoming_events'][0]
            response += f"You have {event['Subject']} coming up. "
        
        return response
```

---

## Phase 4: Testing & Deployment (1 hour)

### Step 4.1: Test Queries Locally

```python
# test_salesforce.py
from jarvis.integrations.salesforce import SalesforceClient
from jarvis.integrations.credentials_manager import CredentialsManager

def test_connection():
    creds = CredentialsManager()
    sf = SalesforceClient(creds)
    
    assert sf.is_connected, "Not connected to Salesforce"
    print("✅ Connected to Salesforce")
    
    # Test job queries
    jobs = sf.get_jobs_today()
    print(f"✅ Jobs today: {len(jobs)}")
    
    # Test wellness
    routine = sf.get_todays_routine()
    print(f"✅ Today's routine: {routine}")
    
    # Test meals
    meals = sf.get_todays_meals()
    print(f"✅ Today's meals: {len(meals)}")
    
    # Test morning briefing
    briefing = sf.get_morning_briefing()
    print(f"✅ Morning briefing: {briefing.keys()}")

if __name__ == "__main__":
    test_connection()
```

### Step 4.2: Voice Test Commands

```
"Hey JARVIS, what jobs came in today?"
"JARVIS, log my energy as 7"
"What's for dinner tonight?"
"Give me my morning briefing"
"How many applications this week?"
"Schedule interview with Acme Corp Tuesday at 2pm"
```

---

## Security Considerations

### What's Safe to Show (LinkedIn/Portfolio)
- ✅ Architecture diagrams (like the one above)
- ✅ Intent patterns (voice command examples)
- ✅ SOQL query patterns (generic)
- ✅ "I built voice-to-Salesforce integration"

### What Stays Private
- ❌ Actual credentials/tokens
- ❌ Encryption key handling
- ❌ Security architecture details
- ❌ Anti-coercion PIN logic
- ❌ Emergency mode triggers

---

## Implementation Checklist

### Phase 1: Authentication
- [ ] Create Connected App in Salesforce
- [ ] Note Consumer Key/Secret
- [ ] Create CredentialsManager class
- [ ] Add .gitignore entries
- [ ] Test OAuth flow

### Phase 2: Salesforce Client
- [ ] Create SalesforceClient class
- [ ] Implement job search queries
- [ ] Implement wellness queries
- [ ] Implement meal queries
- [ ] Implement calendar queries
- [ ] Implement morning briefing

### Phase 3: Voice Integration
- [ ] Define intent patterns
- [ ] Create response handlers
- [ ] Wire up to JARVIS main loop
- [ ] Test voice commands

### Phase 4: Testing
- [ ] Test all queries individually
- [ ] Test full voice flow
- [ ] Test error handling
- [ ] Test token refresh

---

## Estimated Timeline

| Phase | Task | Time |
|-------|------|------|
| 1 | Authentication Setup | 1 hour |
| 2 | Salesforce Client | 2 hours |
| 3 | Voice Integration | 2 hours |
| 4 | Testing | 1 hour |
| **Total** | | **6 hours** |

---

## Future Enhancements

1. **Proactive Notifications**
   - "3 new high-scoring jobs just came in"
   - "You haven't logged wellness today"

2. **Natural Conversation**
   - "Tell me more about that first job"
   - "Apply to that one" → Opens URL

3. **Multi-Turn Context**
   - "What about remote jobs?" (follows previous query)

4. **Scheduled Reports**
   - Morning briefing at 8am automatically
   - Weekly job search summary

---

*Plan created December 26, 2025*
*For personal use - NOT for GitHub publication*
