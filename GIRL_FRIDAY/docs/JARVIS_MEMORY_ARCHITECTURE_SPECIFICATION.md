# JARVIS MEMORY ARCHITECTURE SPECIFICATION
## Personal AI Assistant - Memory System Design
**Version:** 2.0  
**Date:** December 18, 2025  
**Status:** Planning Phase - Ready for Implementation

---

## EXECUTIVE SUMMARY

JARVIS (Just A Rather Very Intelligent System) is a personal AI assistant designed to solve the AI consistency problem through persistent memory, contextual understanding, and relationship tracking.

**Core Problem Being Solved:**
- AI assistants give inconsistent analysis across sessions
- No memory between conversations
- No grounding in objective data
- User must repeat context constantly

**Solution Architecture:**
- **Sleep Cycles** for background memory consolidation
- **Knowledge Graph** for relationship tracking
- **Dual-layer memory** (short-term + long-term)
- **Timestamp-aware** conversation tracking
- **Cross-domain insights** (projects, emotions, goals)

---

## MEMORY ARCHITECTURE OVERVIEW

```
JARVIS Memory System
├── Layer 1: INGESTION (Immediate - Short-Term Memory)
│   ├── Conversation vectorization (pgvector)
│   ├── Immediate response to user
│   └── Queue background processing
│
├── Layer 2: CONSOLIDATION (Background - "Sleep Cycles")
│   ├── Entity extraction (Redis + BullMQ worker)
│   ├── Relationship identification
│   ├── Pattern analysis
│   └── Semantic enrichment
│
├── Layer 3: GRAPH CONSTRUCTION (Knowledge Building)
│   ├── Knowledge Graph (Neo4j or PostgreSQL)
│   ├── Entity nodes (Projects, People, Skills, Goals, Emotions)
│   ├── Relationship edges (RELATES_TO, REQUIRES, IMPACTS, etc.)
│   └── Temporal tracking (WHEN, DURATION, FREQUENCY)
│
└── Layer 4: QUERY & RETRIEVAL
    ├── Vector similarity search (fast retrieval)
    ├── Graph traversal (relationship discovery)
    ├── Temporal queries (time-based patterns)
    └── Hybrid results (combined context)
```

---

## CRITICAL REQUIREMENT: TIMESTAMPS

### The Problem (User Feedback - Dec 18, 2025)

**Current State:**
- Claude has NO visible timestamps in conversations
- Cannot reference when events occurred
- "Yesterday" becomes meaningless without actual dates
- Pattern analysis impossible without time data

**Impact:**
- "What did I do yesterday?" → Cannot answer without timestamps
- Energy pattern tracking → Requires actual time data
- Project progress → Need to know WHEN milestones were hit
- Cross-session continuity → Broken without temporal context

### The Solution: Comprehensive Timestamp System

**Every conversation entry MUST include:**

```json
{
  "timestamp_utc": "2025-12-18T14:32:15.123Z",
  "timestamp_local": "2025-12-18 09:32:15 EST",
  "user_timezone": "America/New_York",
  "conversation_id": "uuid-string",
  "session_id": "uuid-string",
  "message_number": 47,
  "day_of_week": "Wednesday",
  "time_of_day": "morning",
  "relative_time": {
    "since_last_message": "2 hours 15 minutes",
    "since_session_start": "47 minutes"
  },
  "user_input": "I'm struggling today",
  "jarvis_response": "I see you're having a rough day...",
  "context": {
    "energy_level": 3,
    "emotional_state": "struggling",
    "current_project": "Agentforce exam prep",
    "depression_phase": true,
    "work_mode": "study"
  }
}
```

**Enables Queries:**
- "What did I accomplish yesterday?" (actual date-based)
- "Show my progress over the last week" (7-day range)
- "When did I last work on SafeHaven?" (exact timestamp)
- "I always struggle on Wednesdays" (pattern detection)
- "Morning vs afternoon energy patterns" (time-of-day analysis)

---

## LAYER 1: INGESTION (Immediate - Short-Term Memory)

### Purpose
Provide immediate response to user while capturing conversation for background processing.

### Implementation

**Technology:**
- **Vector Database:** PostgreSQL with pgvector extension
- **Embedding Model:** OpenAI ada-002 or similar
- **Storage:** Local PostgreSQL instance (encrypted)

**Process Flow:**

```python
# jarvis/memory/ingestion.py

class ConversationIngestion:
    def store_interaction(
        self,
        user_input: str,
        jarvis_response: str,
        context: dict
    ) -> str:
        """
        Immediately store conversation with full temporal context
        Returns: conversation_id for reference
        """
        # Generate timestamp data
        timestamp_data = self.generate_timestamp_data()
        
        # Generate embedding
        embedding = self.embedding_model.encode(
            user_input + " " + jarvis_response
        )
        
        # Store in vector database
        conversation_id = self.db.execute("""
            INSERT INTO conversations (
                timestamp_utc,
                timestamp_local,
                user_timezone,
                conversation_id,
                session_id,
                message_number,
                day_of_week,
                time_of_day,
                user_input,
                jarvis_response,
                embedding,
                context_json,
                processing_status
            ) VALUES (
                %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, 'queued'
            ) RETURNING conversation_id
        """, (
            timestamp_data['utc'],
            timestamp_data['local'],
            timestamp_data['timezone'],
            uuid.uuid4(),
            self.session_id,
            self.message_counter,
            timestamp_data['day_of_week'],
            self.determine_time_of_day(timestamp_data['local']),
            user_input,
            jarvis_response,
            embedding,
            json.dumps(context)
        ))
        
        # Queue for background processing
        self.queue_background_processing(conversation_id)
        
        return conversation_id
    
    def generate_timestamp_data(self) -> dict:
        """Generate comprehensive timestamp information"""
        now_utc = datetime.utcnow()
        user_tz = pytz.timezone(self.user_timezone)
        now_local = now_utc.astimezone(user_tz)
        
        return {
            'utc': now_utc.isoformat(),
            'local': now_local.isoformat(),
            'timezone': str(user_tz),
            'day_of_week': now_local.strftime('%A'),
            'date': now_local.date().isoformat(),
            'time': now_local.time().isoformat()
        }
    
    def determine_time_of_day(self, timestamp) -> str:
        """Categorize time of day for pattern analysis"""
        hour = timestamp.hour
        if 5 <= hour < 12:
            return "morning"
        elif 12 <= hour < 17:
            return "afternoon"
        elif 17 <= hour < 21:
            return "evening"
        else:
            return "night"
```

**Database Schema:**

```sql
CREATE TABLE conversations (
    conversation_id UUID PRIMARY KEY,
    session_id UUID NOT NULL,
    timestamp_utc TIMESTAMP WITH TIME ZONE NOT NULL,
    timestamp_local TIMESTAMP NOT NULL,
    user_timezone VARCHAR(50) NOT NULL,
    day_of_week VARCHAR(10) NOT NULL,
    time_of_day VARCHAR(10) NOT NULL,
    message_number INTEGER NOT NULL,
    user_input TEXT NOT NULL,
    jarvis_response TEXT NOT NULL,
    embedding VECTOR(1536), -- pgvector type
    context_json JSONB,
    processing_status VARCHAR(20) DEFAULT 'queued',
    processed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_conversations_timestamp_utc ON conversations(timestamp_utc);
CREATE INDEX idx_conversations_session ON conversations(session_id);
CREATE INDEX idx_conversations_embedding ON conversations USING ivfflat (embedding vector_cosine_ops);
CREATE INDEX idx_conversations_day_of_week ON conversations(day_of_week);
CREATE INDEX idx_conversations_time_of_day ON conversations(time_of_day);
CREATE INDEX idx_conversations_context ON conversations USING gin (context_json);
```

---

## LAYER 2: CONSOLIDATION (Background - "Sleep Cycles")

### Purpose
Background processing to extract entities, identify relationships, and enrich semantic understanding without blocking user interaction.

### Architecture: Redis + BullMQ Worker Pattern

**Why This Approach:**
- **Asynchronous:** Processing doesn't block user interaction
- **Scalable:** Can add more workers as needed
- **Reliable:** BullMQ handles retries, failures, dead letter queues
- **Observable:** Can monitor job status, processing time

### Implementation

**Technology:**
- **Message Queue:** Redis with BullMQ
- **Worker Process:** Python async worker
- **LLM:** Claude API for entity extraction

**Process Flow:**

```python
# jarvis/memory/sleep_cycles.py

from bullmq import Worker, Job
import asyncio

class SleepCycleWorker:
    def __init__(self):
        self.entity_extractor = EntityExtractor()
        self.relationship_builder = RelationshipBuilder()
        self.pattern_analyzer = PatternAnalyzer()
    
    async def process_conversation(self, job: Job):
        """
        Background job: Process conversation during 'sleep'
        """
        conversation_id = job.data['conversation_id']
        
        # Step 1: Load conversation
        conversation = await self.load_conversation(conversation_id)
        
        # Step 2: Extract entities
        entities = await self.entity_extractor.extract(conversation)
        
        # Step 3: Build relationships
        relationships = await self.relationship_builder.build(
            entities, 
            conversation
        )
        
        # Step 4: Analyze patterns
        patterns = await self.pattern_analyzer.analyze(
            conversation,
            entities,
            relationships
        )
        
        # Step 5: Update knowledge graph
        await self.update_knowledge_graph(
            entities,
            relationships,
            patterns
        )
        
        # Step 6: Mark processed
        await self.mark_processed(conversation_id)
        
        return {
            'conversation_id': conversation_id,
            'entities_extracted': len(entities),
            'relationships_found': len(relationships),
            'patterns_detected': len(patterns)
        }

# Start worker
worker = Worker(
    'jarvis-sleep-cycles',
    process_conversation,
    connection=redis_connection
)
```

### Entity Extraction

**Purpose:** Identify and categorize meaningful elements from conversations.

**Entity Types:**
1. **Projects** - SafeHaven, DivergentThrive, JARVIS, NeuroThrive
2. **Skills** - Salesforce, Apex, Python, Kotlin, Agentforce
3. **People** - Matt (beta tester), Spouse, Dad, Kids
4. **Organizations** - FINCA International, Macquarie Capital
5. **Goals** - Pass Salesforce Admin exam, Get job offer
6. **Deadlines** - Dec 30 exam, Job application deadlines
7. **Emotional States** - Tired, excited, struggling, gaining momentum
8. **Energy Levels** - Low (1-3), Medium (4-7), High (8-10)
9. **Activities** - Study, coding, garden time, family check-ins
10. **Achievements** - Completed video, earned badge, applied to job

**Implementation:**

```python
# jarvis/memory/entity_extractor.py

class EntityExtractor:
    async def extract(self, conversation) -> List[Entity]:
        """
        Extract entities from conversation using Claude API
        """
        prompt = f"""
        Analyze this conversation and extract all meaningful entities.
        
        Timestamp: {conversation.timestamp_local}
        User: {conversation.user_input}
        JARVIS: {conversation.jarvis_response}
        Context: {conversation.context_json}
        
        Extract and categorize:
        
        1. PROJECTS mentioned:
           - Name
           - Status update (if mentioned)
           - Action items
        
        2. SKILLS discussed:
           - Skill name
           - Proficiency level (if mentioned)
           - Usage context
        
        3. PEOPLE mentioned:
           - Name
           - Relationship
           - Context of mention
        
        4. GOALS/DEADLINES:
           - Goal description
           - Deadline date (if mentioned)
           - Progress indicators
        
        5. EMOTIONAL STATES:
           - State description
           - Intensity (1-10 if quantifiable)
           - Triggers/causes
        
        6. ENERGY LEVELS:
           - Level (1-10)
           - Time of day
           - Factors affecting
        
        7. ACTIVITIES:
           - Activity name
           - Duration (if mentioned)
           - Outcome
        
        8. ACHIEVEMENTS:
           - What was accomplished
           - Significance
           - Related to which goal/project
        
        Return as structured JSON with timestamps attached to each entity.
        """
        
        response = await self.claude_api.generate(
            prompt,
            system="You are an expert at extracting structured information from conversations. Be precise and comprehensive.",
            max_tokens=2000
        )
        
        # Parse JSON response
        extracted = json.loads(response)
        
        # Convert to Entity objects with timestamps
        entities = []
        for entity_type, entity_list in extracted.items():
            for entity_data in entity_list:
                entity = Entity(
                    type=entity_type,
                    data=entity_data,
                    conversation_id=conversation.conversation_id,
                    timestamp=conversation.timestamp_utc,
                    source_context=conversation.context_json
                )
                entities.append(entity)
        
        return entities
```

### Relationship Building

**Purpose:** Identify how entities connect to each other.

**Relationship Types:**
1. **REQUIRES** - Project requires skill
2. **BLOCKED_BY** - Project blocked by missing resource
3. **RELATED_TO** - Skill related to another skill
4. **IMPACTS** - Emotional state impacts energy level
5. **WORKS_ON** - Person works on project
6. **PART_OF** - Activity part of larger goal
7. **ENABLES** - Completing X enables Y
8. **PRECEDES** - Must happen before
9. **FOLLOWS** - Happens after
10. **CORRELATES_WITH** - Statistical correlation

**Implementation:**

```python
# jarvis/memory/relationship_builder.py

class RelationshipBuilder:
    async def build(
        self,
        entities: List[Entity],
        conversation
    ) -> List[Relationship]:
        """
        Identify relationships between extracted entities
        """
        prompt = f"""
        Given these entities extracted from a conversation, identify relationships between them.
        
        Entities:
        {json.dumps([e.to_dict() for e in entities], indent=2)}
        
        Conversation context:
        User: {conversation.user_input}
        JARVIS: {conversation.jarvis_response}
        
        Identify relationships such as:
        - Which projects require which skills?
        - How do emotional states impact energy levels?
        - What activities enable which goals?
        - Which achievements unlock new capabilities?
        - How do people relate to projects?
        - What blocks or enables progress?
        
        For each relationship, specify:
        - Source entity
        - Relationship type
        - Target entity
        - Strength/confidence (0-1)
        - Evidence/reasoning
        
        Return as structured JSON.
        """
        
        response = await self.claude_api.generate(prompt)
        relationships_data = json.loads(response)
        
        relationships = []
        for rel_data in relationships_data:
            relationship = Relationship(
                source=rel_data['source'],
                type=rel_data['type'],
                target=rel_data['target'],
                strength=rel_data['strength'],
                evidence=rel_data['evidence'],
                conversation_id=conversation.conversation_id,
                timestamp=conversation.timestamp_utc
            )
            relationships.append(relationship)
        
        return relationships
```

### Pattern Analysis

**Purpose:** Detect recurring patterns in behavior, emotions, energy, productivity.

**Pattern Types:**
1. **Temporal** - "Always struggles on Wednesday mornings"
2. **Causal** - "Garden time → improved mood"
3. **Sequential** - "Family check-ins → better work sessions"
4. **Cyclic** - "Depression cycles every 3-4 weeks"
5. **Threshold** - "Energy below 4 → reduced productivity"

**Implementation:**

```python
# jarvis/memory/pattern_analyzer.py

class PatternAnalyzer:
    async def analyze(
        self,
        conversation,
        entities: List[Entity],
        relationships: List[Relationship]
    ) -> List[Pattern]:
        """
        Detect patterns across conversations over time
        """
        # Get historical context (last 30 days)
        historical = await self.load_historical_data(
            days=30,
            entity_types=['emotional_state', 'energy_level', 'activity']
        )
        
        patterns = []
        
        # Analyze day-of-week patterns
        day_patterns = self.analyze_day_of_week_patterns(historical)
        patterns.extend(day_patterns)
        
        # Analyze time-of-day patterns
        time_patterns = self.analyze_time_of_day_patterns(historical)
        patterns.extend(time_patterns)
        
        # Analyze activity correlations
        activity_patterns = self.analyze_activity_correlations(historical)
        patterns.extend(activity_patterns)
        
        # Analyze emotional cycles
        emotional_patterns = self.analyze_emotional_cycles(historical)
        patterns.extend(emotional_patterns)
        
        return patterns
    
    def analyze_day_of_week_patterns(self, data) -> List[Pattern]:
        """
        Example: "User reports low energy on Mondays 80% of the time"
        """
        day_stats = defaultdict(lambda: {'low': 0, 'medium': 0, 'high': 0})
        
        for entry in data:
            if entry.type == 'energy_level':
                day = entry.day_of_week
                level_category = self.categorize_energy(entry.level)
                day_stats[day][level_category] += 1
        
        patterns = []
        for day, stats in day_stats.items():
            total = sum(stats.values())
            if total > 3:  # Need at least 3 data points
                percentages = {k: v/total for k, v in stats.items()}
                
                # Flag days with strong trends
                if percentages['low'] > 0.7:
                    patterns.append(Pattern(
                        type='temporal',
                        description=f"Low energy on {day}s ({percentages['low']:.0%} of time)",
                        confidence=percentages['low'],
                        evidence=stats
                    ))
        
        return patterns
```

---

## LAYER 3: KNOWLEDGE GRAPH CONSTRUCTION

### Purpose
Store entities and relationships in a queryable graph structure that preserves temporal context and enables relationship traversal.

### Technology Choice

**Option 1: Neo4j (Dedicated Graph Database)**
- **Pros:** Purpose-built for graphs, excellent traversal performance, rich query language (Cypher)
- **Cons:** Additional infrastructure, learning curve

**Option 2: PostgreSQL with Recursive CTEs**
- **Pros:** Already using Postgres, one database, familiar SQL
- **Cons:** Less performant for deep graph traversals

**Recommendation:** Start with PostgreSQL, migrate to Neo4j if performance becomes an issue.

### Graph Schema

**Node Types:**

```sql
-- Core entity table
CREATE TABLE entities (
    entity_id UUID PRIMARY KEY,
    entity_type VARCHAR(50) NOT NULL, -- project, skill, person, goal, etc.
    entity_name VARCHAR(255) NOT NULL,
    properties JSONB NOT NULL,
    first_seen TIMESTAMP NOT NULL,
    last_updated TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Temporal tracking: Entity states over time
CREATE TABLE entity_states (
    state_id UUID PRIMARY KEY,
    entity_id UUID REFERENCES entities(entity_id),
    timestamp_utc TIMESTAMP NOT NULL,
    state_type VARCHAR(50) NOT NULL, -- status, progress, completion, etc.
    state_value JSONB NOT NULL,
    conversation_id UUID REFERENCES conversations(conversation_id),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Relationships between entities
CREATE TABLE relationships (
    relationship_id UUID PRIMARY KEY,
    source_entity_id UUID REFERENCES entities(entity_id),
    target_entity_id UUID REFERENCES entities(entity_id),
    relationship_type VARCHAR(50) NOT NULL,
    strength FLOAT, -- 0-1 confidence
    properties JSONB,
    first_seen TIMESTAMP NOT NULL,
    last_confirmed TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Temporal tracking: Relationship states over time
CREATE TABLE relationship_states (
    state_id UUID PRIMARY KEY,
    relationship_id UUID REFERENCES relationships(relationship_id),
    timestamp_utc TIMESTAMP NOT NULL,
    state_type VARCHAR(50) NOT NULL,
    state_value JSONB NOT NULL,
    conversation_id UUID REFERENCES conversations(conversation_id),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Pattern detection results
CREATE TABLE patterns (
    pattern_id UUID PRIMARY KEY,
    pattern_type VARCHAR(50) NOT NULL, -- temporal, causal, sequential, etc.
    pattern_description TEXT NOT NULL,
    confidence FLOAT,
    evidence JSONB,
    detected_at TIMESTAMP NOT NULL,
    still_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_entities_type ON entities(entity_type);
CREATE INDEX idx_entities_name ON entities(entity_name);
CREATE INDEX idx_entity_states_timestamp ON entity_states(timestamp_utc);
CREATE INDEX idx_relationships_source ON relationships(source_entity_id);
CREATE INDEX idx_relationships_target ON relationships(target_entity_id);
CREATE INDEX idx_relationships_type ON relationships(relationship_type);
```

### Graph Population

```python
# jarvis/memory/knowledge_graph.py

class KnowledgeGraph:
    async def update_from_entities(
        self,
        entities: List[Entity],
        relationships: List[Relationship],
        conversation_id: str
    ):
        """
        Update knowledge graph with new entities and relationships
        """
        async with self.db.transaction():
            # Upsert entities
            for entity in entities:
                existing = await self.find_entity(
                    entity_type=entity.type,
                    entity_name=entity.name
                )
                
                if existing:
                    # Update existing entity
                    await self.update_entity(existing.entity_id, entity)
                    entity_id = existing.entity_id
                else:
                    # Create new entity
                    entity_id = await self.create_entity(entity)
                
                # Record state change
                await self.record_entity_state(
                    entity_id,
                    entity.state,
                    conversation_id
                )
            
            # Upsert relationships
            for relationship in relationships:
                existing = await self.find_relationship(
                    source=relationship.source,
                    type=relationship.type,
                    target=relationship.target
                )
                
                if existing:
                    # Update confirmation timestamp
                    await self.confirm_relationship(existing.relationship_id)
                else:
                    # Create new relationship
                    await self.create_relationship(relationship)
    
    async def create_entity(self, entity: Entity) -> str:
        """Create new entity node"""
        entity_id = str(uuid.uuid4())
        
        await self.db.execute("""
            INSERT INTO entities (
                entity_id, entity_type, entity_name,
                properties, first_seen, last_updated
            ) VALUES (%s, %s, %s, %s, %s, %s)
        """, (
            entity_id,
            entity.type,
            entity.name,
            json.dumps(entity.properties),
            entity.timestamp,
            entity.timestamp
        ))
        
        return entity_id
    
    async def record_entity_state(
        self,
        entity_id: str,
        state: dict,
        conversation_id: str
    ):
        """Record temporal state of entity"""
        await self.db.execute("""
            INSERT INTO entity_states (
                state_id, entity_id, timestamp_utc,
                state_type, state_value, conversation_id
            ) VALUES (%s, %s, %s, %s, %s, %s)
        """, (
            str(uuid.uuid4()),
            entity_id,
            datetime.utcnow(),
            state.get('type', 'update'),
            json.dumps(state),
            conversation_id
        ))
```

### Example Graph Queries

**Query 1: "What projects am I working on?"**

```sql
SELECT 
    e.entity_name AS project_name,
    e.properties->>'status' AS status,
    es.state_value->>'completion' AS completion_percentage,
    es.timestamp_utc AS last_updated
FROM entities e
LEFT JOIN LATERAL (
    SELECT state_value, timestamp_utc
    FROM entity_states
    WHERE entity_id = e.entity_id
    AND state_type = 'status_update'
    ORDER BY timestamp_utc DESC
    LIMIT 1
) es ON true
WHERE e.entity_type = 'project'
AND (e.properties->>'status' != 'complete' OR e.properties->>'status' IS NULL)
ORDER BY es.timestamp_utc DESC;
```

**Query 2: "What skills does SafeHaven require?"**

```sql
SELECT 
    target.entity_name AS required_skill,
    target.properties->>'proficiency' AS my_proficiency,
    r.strength AS importance
FROM entities source
JOIN relationships r ON r.source_entity_id = source.entity_id
JOIN entities target ON r.target_entity_id = target.entity_id
WHERE source.entity_name = 'SafeHaven'
AND source.entity_type = 'project'
AND r.relationship_type = 'REQUIRES'
AND target.entity_type = 'skill'
ORDER BY r.strength DESC;
```

**Query 3: "When do I have low energy?"**

```sql
SELECT 
    day_of_week,
    time_of_day,
    COUNT(*) AS occurrences,
    AVG((context_json->>'energy_level')::int) AS avg_energy
FROM conversations
WHERE context_json->>'energy_level' IS NOT NULL
AND timestamp_utc >= NOW() - INTERVAL '30 days'
GROUP BY day_of_week, time_of_day
HAVING AVG((context_json->>'energy_level')::int) < 4
ORDER BY avg_energy ASC;
```

**Query 4: "Cross-domain insights: How does garden time affect my productivity?"**

```sql
WITH garden_sessions AS (
    SELECT 
        DATE(timestamp_local) AS session_date,
        COUNT(*) AS garden_mentions
    FROM conversations
    WHERE user_input ILIKE '%garden%'
    OR context_json->>'current_activity' = 'garden'
    GROUP BY DATE(timestamp_local)
),
productivity_scores AS (
    SELECT 
        DATE(timestamp_local) AS session_date,
        COUNT(*) FILTER (WHERE context_json->>'achievement' IS NOT NULL) AS achievements,
        AVG((context_json->>'energy_level')::int) AS avg_energy
    FROM conversations
    WHERE timestamp_local >= NOW() - INTERVAL '30 days'
    GROUP BY DATE(timestamp_local)
)
SELECT 
    CASE WHEN g.garden_mentions > 0 THEN 'With Garden Time' ELSE 'No Garden Time' END AS condition,
    AVG(p.achievements) AS avg_achievements,
    AVG(p.avg_energy) AS avg_energy
FROM productivity_scores p
LEFT JOIN garden_sessions g ON p.session_date = g.session_date
GROUP BY CASE WHEN g.garden_mentions > 0 THEN 'With Garden Time' ELSE 'No Garden Time' END;
```

---

## LAYER 4: QUERY & RETRIEVAL

### Purpose
Enable fast, accurate retrieval of relevant context when user asks questions.

### Hybrid Query Approach

**Combine:**
1. **Vector Similarity Search** - Find semantically similar conversations
2. **Graph Traversal** - Find related entities and relationships
3. **Temporal Filtering** - Constrain by time windows

### Implementation

```python
# jarvis/memory/query.py

class MemoryQuery:
    async def answer_question(
        self,
        question: str,
        context: dict = None
    ) -> str:
        """
        Query memory system to answer user question
        """
        # Step 1: Vector similarity search
        similar_conversations = await self.vector_search(
            question,
            top_k=5
        )
        
        # Step 2: Extract keywords for graph query
        keywords = await self.extract_keywords(question)
        
        # Step 3: Graph traversal for related entities
        related_entities = await self.graph_search(keywords)
        
        # Step 4: Temporal filtering if time mentioned
        if self.has_temporal_reference(question):
            time_filter = self.parse_temporal_reference(question)
            similar_conversations = self.apply_temporal_filter(
                similar_conversations,
                time_filter
            )
            related_entities = self.apply_temporal_filter(
                related_entities,
                time_filter
            )
        
        # Step 5: Combine results into context
        memory_context = self.combine_results(
            similar_conversations,
            related_entities
        )
        
        # Step 6: Generate response with full context
        response = await self.generate_response(
            question=question,
            memory_context=memory_context,
            current_context=context
        )
        
        return response
    
    async def vector_search(
        self,
        query: str,
        top_k: int = 5
    ) -> List[Conversation]:
        """
        Find semantically similar conversations
        """
        # Generate query embedding
        query_embedding = self.embedding_model.encode(query)
        
        # Search using pgvector
        results = await self.db.fetch("""
            SELECT 
                conversation_id,
                timestamp_local,
                user_input,
                jarvis_response,
                context_json,
                1 - (embedding <=> %s) AS similarity
            FROM conversations
            WHERE 1 - (embedding <=> %s) > 0.7  -- Similarity threshold
            ORDER BY embedding <=> %s
            LIMIT %s
        """, query_embedding, query_embedding, query_embedding, top_k)
        
        return [Conversation.from_db(r) for r in results]
    
    async def graph_search(
        self,
        keywords: List[str]
    ) -> List[Entity]:
        """
        Find entities matching keywords and their relationships
        """
        results = []
        
        for keyword in keywords:
            # Find matching entities
            entities = await self.db.fetch("""
                SELECT 
                    e.*,
                    es.state_value AS current_state
                FROM entities e
                LEFT JOIN LATERAL (
                    SELECT state_value
                    FROM entity_states
                    WHERE entity_id = e.entity_id
                    ORDER BY timestamp_utc DESC
                    LIMIT 1
                ) es ON true
                WHERE 
                    e.entity_name ILIKE %s
                    OR e.properties::text ILIKE %s
            """, f'%{keyword}%', f'%{keyword}%')
            
            for entity_row in entities:
                entity = Entity.from_db(entity_row)
                
                # Get related entities (1 hop away)
                related = await self.get_related_entities(entity.entity_id)
                entity.related = related
                
                results.append(entity)
        
        return results
    
    def parse_temporal_reference(self, question: str) -> dict:
        """
        Extract time references like 'yesterday', 'last week', 'Dec 17'
        """
        # Use regex and NLP to extract temporal references
        # Examples:
        # "yesterday" -> {start: yesterday 00:00, end: yesterday 23:59}
        # "last week" -> {start: 7 days ago, end: yesterday}
        # "Dec 17" -> {start: 2025-12-17 00:00, end: 2025-12-17 23:59}
        # "this morning" -> {start: today 05:00, end: today 12:00}
        
        temporal_patterns = [
            (r'yesterday', lambda: self.get_yesterday_range()),
            (r'last week', lambda: self.get_last_week_range()),
            (r'this morning', lambda: self.get_this_morning_range()),
            (r'(\d{1,2})/(\d{1,2})', lambda m: self.get_specific_date(m)),
            # ... more patterns
        ]
        
        for pattern, handler in temporal_patterns:
            match = re.search(pattern, question, re.IGNORECASE)
            if match:
                return handler(match) if hasattr(handler, '__call__') else handler()
        
        return None
    
    def combine_results(
        self,
        conversations: List[Conversation],
        entities: List[Entity]
    ) -> str:
        """
        Combine search results into formatted context
        """
        context_parts = []
        
        # Add conversation history
        if conversations:
            context_parts.append("## Recent Relevant Conversations")
            for conv in conversations:
                context_parts.append(f"""
**{conv.timestamp_local} ({conv.day_of_week} {conv.time_of_day})**
You: {conv.user_input}
JARVIS: {conv.jarvis_response}
Energy: {conv.context.get('energy_level', 'unknown')}
                """.strip())
        
        # Add entity information
        if entities:
            context_parts.append("\n## Relevant Information from Knowledge Graph")
            for entity in entities:
                status = entity.properties.get('status', 'unknown')
                context_parts.append(f"""
**{entity.name}** ({entity.type})
Status: {status}
Current State: {entity.current_state}
Related: {', '.join([r.name for r in entity.related])}
                """.strip())
        
        return "\n\n".join(context_parts)
```

---

## INTEGRATION POINTS

### Git Commits Integration

**Purpose:** Ground JARVIS in objective project data

```python
# jarvis/integrations/git_tracker.py

class GitCommitTracker:
    async def sync_repositories(self):
        """
        Scan local git repositories and update knowledge graph
        """
        repos = self.discover_repositories()
        
        for repo_path in repos:
            repo = git.Repo(repo_path)
            project_name = self.infer_project_name(repo_path)
            
            # Get commits since last sync
            last_sync = await self.get_last_sync_time(project_name)
            commits = list(repo.iter_commits(since=last_sync))
            
            for commit in commits:
                # Create entity for commit
                await self.create_commit_entity(
                    project_name=project_name,
                    commit_hash=commit.hexsha,
                    timestamp=commit.committed_datetime,
                    message=commit.message,
                    files_changed=commit.stats.files
                )
            
            # Update project status
            await self.update_project_status(
                project_name,
                total_commits=len(list(repo.iter_commits())),
                last_commit=commits[0] if commits else None
            )
```

### Trailhead Progress Integration

**Purpose:** Track learning progress automatically

```python
# jarvis/integrations/trailhead_tracker.py

class TrailheadTracker:
    async def sync_badges(self):
        """
        Sync Trailhead badge progress
        (Requires Trailhead profile scraping or API if available)
        """
        # Fetch current badge count
        badge_data = await self.fetch_trailhead_profile()
        
        # Create/update skill entities for each badge
        for badge in badge_data['badges']:
            await self.update_skill_entity(
                skill_name=badge['name'],
                skill_type='salesforce',
                earned_date=badge['earned_date'],
                badge_level=badge['level']
            )
        
        # Update overall Trailhead rank entity
        await self.update_rank_entity(
            rank=badge_data['rank'],
            total_badges=badge_data['total_badges'],
            total_points=badge_data['total_points']
        )
```

### Job Application Tracking Integration

**Purpose:** Track job search progress automatically

```python
# jarvis/integrations/job_tracker.py

class JobApplicationTracker:
    async def sync_applications(self):
        """
        Sync job applications from Salesforce org
        """
        # Query Salesforce for Job_Posting__c records
        job_postings = await self.salesforce_api.query("""
            SELECT Id, Company__c, Position_Title__c, 
                   Application_Status__c, AI_Fit_Score__c,
                   Applied_Date__c, Interview_Date__c
            FROM Job_Posting__c
            WHERE Application_Status__c != 'Rejected'
            ORDER BY Applied_Date__c DESC
        """)
        
        for job in job_postings:
            # Create/update job application entity
            await self.update_job_entity(
                company=job['Company__c'],
                position=job['Position_Title__c'],
                status=job['Application_Status__c'],
                fit_score=job['AI_Fit_Score__c'],
                applied_date=job['Applied_Date__c'],
                interview_date=job['Interview_Date__c']
            )
            
            # Create relationships
            await self.create_relationship(
                source='Job Search Goal',
                type='HAS_APPLICATION',
                target=f"{job['Company__c']} - {job['Position_Title__c']}"
            )
```

---

## EXAMPLE USE CASES

### Use Case 1: "What did I accomplish yesterday?"

**Query Processing:**
```
1. Parse temporal reference: "yesterday" -> 2025-12-17
2. Vector search: conversations from Dec 17
3. Extract achievements from conversations
4. Query knowledge graph for status updates from Dec 17
5. Combine results
```

**Response:**
```
Yesterday (December 17, 2025) you accomplished:

✅ Watched "Test an AI Agent in Agentforce Testing Center" video (8 mins)
✅ Completed Agentblazer Innovator 2026 badge (111 total badges now)
✅ Applied to FINCA International (Salesforce Administrator role)
✅ Started Matt's Salesforce profile setup for beta testing

You started the day with low energy but gained momentum by afternoon.
Your energy improved from 3/10 to 7/10 after family check-ins.

Context: You're in Day 1 of your Agentforce exam prep (exam Dec 30).
```

### Use Case 2: "Should I prioritize JARVIS or DivergentThrive?"

**Query Processing:**
```
1. Identify entities: JARVIS (project), DivergentThrive (project)
2. Graph traversal: Get status, blockers, relationships for both
3. Consider current context: Depression phase, exam prep, energy levels
4. Analyze recent patterns
```

**Response:**
```
Prioritize DivergentThrive. Here's why:

DivergentThrive (85% complete):
- 3 beta testers ready (Matt, others)
- Code complete, needs deployment testing
- Demonstrates job-ready Salesforce skills
- Estimated: 3-4 hours to beta-ready

JARVIS (30% complete):
- Memory layer not implemented
- You said "too tired for JARVIS" on Dec 11
- Requires sustained focus (20-30 hours)
- Can wait until after Dec 30 exam

Current Context:
- You're in a depression phase (low energy mornings)
- Agentforce exam Dec 30 (12 days away)
- DivergentThrive success = portfolio evidence for interviews

Recommendation: Finish DivergentThrive beta testing this week, 
revisit JARVIS after passing your exam when energy is better.
```

### Use Case 3: "When do I have the most energy?"

**Query Processing:**
```
1. Query: energy_level patterns by time_of_day and day_of_week
2. Calculate averages over last 30 days
3. Identify peak times
4. Check for correlations with activities
```

**Response:**
```
Based on 30 days of data:

Your Peak Energy Times:
1. Tuesday afternoons (2-4 PM): Avg 8/10 energy
2. Thursday mornings (10 AM-12 PM): Avg 7.5/10 energy
3. Saturday afternoons (1-3 PM): Avg 7/10 energy

Your Low Energy Times:
1. Monday mornings (8-10 AM): Avg 3/10 energy
2. Wednesday all day: Avg 4/10 energy
3. Any morning before family check-ins: Avg 3.5/10 energy

Patterns Detected:
- Family check-ins (9:30-10 AM) boost energy +2 points
- Garden time correlates with +40% productivity
- Mornings below 4/10 energy → 60% less task completion
- After 5:15 PM: Energy drops to 2-3/10 (hard stop needed)

Recommendation: Schedule high-focus work (exam study, coding) 
for Tuesday/Thursday afternoons when energy is consistently high.
```

---

## SECURITY INTEGRATION

**Note:** Full security architecture detailed in `JARVIS_SECURITY_ARCHITECTURE_SPECIFICATION.md`

**Key Security Considerations for Memory:**

1. **Encrypted Storage**
   - All conversation data encrypted at rest
   - Encryption keys stored separately
   - Memory database protected by same encryption as SafeHaven

2. **Access Control**
   - Memory queries require authentication
   - Biometric auth before revealing sensitive memories
   - Duress PIN triggers fake memory responses

3. **Panic Delete Integration**
   - Memory database included in <2 second wipe
   - Irreversible deletion
   - Multiple trigger methods

4. **LLM Lockout During Emergency**
   - Memory queries disabled during emergency mode
   - Recording continues but JARVIS doesn't respond
   - Prevents coercion through JARVIS

---

## IMPLEMENTATION ROADMAP

### Phase 1: Foundation (Weeks 1-2)
- [ ] Set up PostgreSQL with pgvector
- [ ] Implement conversation ingestion with full timestamps
- [ ] Build embedding pipeline
- [ ] Create basic vector search

### Phase 2: Background Processing (Weeks 3-4)
- [ ] Set up Redis + BullMQ
- [ ] Implement entity extraction
- [ ] Build relationship builder
- [ ] Create sleep cycle worker

### Phase 3: Knowledge Graph (Weeks 5-6)
- [ ] Design and implement graph schema
- [ ] Build graph population logic
- [ ] Create graph query functions
- [ ] Implement temporal tracking

### Phase 4: Query System (Week 7)
- [ ] Build hybrid query engine
- [ ] Implement temporal filtering
- [ ] Create response generator
- [ ] Add pattern analysis

### Phase 5: Integrations (Week 8)
- [ ] Git commit tracker
- [ ] Trailhead sync
- [ ] Job application tracker
- [ ] Calendar integration

### Phase 6: Security (Week 9)
- [ ] Implement encryption
- [ ] Add access controls
- [ ] Integrate panic delete
- [ ] Test duress scenarios

### Phase 7: Testing & Refinement (Week 10)
- [ ] Load testing
- [ ] Accuracy evaluation
- [ ] Performance optimization
- [ ] User acceptance testing

---

## SUCCESS METRICS

**Memory Quality:**
- Conversation recall accuracy: >95%
- Entity extraction accuracy: >90%
- Relationship identification accuracy: >85%
- Pattern detection precision: >80%

**Performance:**
- Query response time: <500ms for simple queries
- Query response time: <2s for complex graph traversals
- Background processing: <30s per conversation
- Memory database size: <1GB per year

**User Experience:**
- "JARVIS remembers what I told it" satisfaction: >90%
- Time saved not repeating context: 5-10 min per session
- Useful insights provided: >3 per week
- Cross-session continuity: Seamless

---

## NEXT STEPS

1. **Review this specification** with user for feedback
2. **Create companion documents:**
   - Security architecture spec
   - Integration architecture spec
   - API documentation
3. **Set up development environment**
4. **Begin Phase 1 implementation** after Salesforce Admin exam (post-Dec 30)

---

**Document Status:** Draft - Awaiting User Review  
**Last Updated:** December 18, 2025  
**Next Review:** After user feedback on memory architecture approach