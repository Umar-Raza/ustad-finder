# Ustad Finder — AI-Powered Tutor Matching System

**Challenge:** AI Service Orchestrator for Informal Economy (Challenge 2)  
**Hackathon:** AI Seekho 2026  
**Team:** Umar Dev  
**Team Lead:** Muhammad Umar  
**Team Member:** Abdul Rahman Shahi

---

## 🎯 Project Overview

**Ustad Finder** is an agentic mobile application that automates the end-to-end tutor discovery lifecycle. It understands multilingual (Urdu, Roman Urdu, English, code-switched) service requests, intelligently matches tutors using an 8-factor algorithm, generates transparent pricing, and simulates the complete booking-to-feedback lifecycle with visible AI reasoning traces.

**Key Innovation:** Every decision step shows the agent's reasoning process — from intent parsing to multi-factor ranking to pricing breakdown — making the agentic workflow transparent and auditable.

---

## 🏗️ Architecture

```
Ustad Finder (Flutter Mobile App)
├── lib/
│   ├── main.dart                      # App entry point, theme setup
│   ├── theme.dart                     # Material 3 theming
│   ├── config.dart                    # OpenAI API key
│   ├── models/
│   │   ├── tutor.dart                 # Tutor data model
│   │   ├── price_quote.dart           # Pricing breakdown model
│   │   └── match_result.dart          # Matching algorithm result
│   ├── services/
│   │   ├── gemini_service.dart        # OpenAI intent parsing (Multilingual)
│   │   ├── data_service.dart          # Mock tutor dataset loading
│   │   ├── matching_service.dart      # 8-factor matching algorithm
│   │   └── pricing_service.dart       # Dynamic pricing engine
│   ├── screens/
│   │   ├── request_screen.dart        # User input (Screen 1)
│   │   ├── understanding_screen.dart  # Intent parsing with confidence (Screen 2)
│   │   ├── matching_screen.dart       # Multi-factor ranking (Screen 3)
│   │   ├── pricing_screen.dart        # Transparent breakdown (Screen 4)
│   │   ├── booking_screen.dart        # Booking confirmation (Screen 5)
│   │   ├── service_loop_screen.dart   # Service progress & feedback (Screen 6)
│   │   └── dispute_screen.dart        # Dispute resolution (Screen 7)
│   └── widgets/
│       └── agent_reasoning_panel.dart # Reusable reasoning trace widget
├── assets/
│   └── tutors.json                    # Mock tutor dataset (6 tutors, 11+ attributes)
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml        # Internet & network permissions
├── pubspec.yaml                       # Flutter dependencies
└── codemagic.yaml                     # CI/CD for APK builds
```

**Technology Stack:**
- **Frontend:** Flutter (Dart) — single mobile app targeting Android
- **UI Framework:** Material 3 with google_fonts & flutter_animate
- **LLM:** OpenAI GPT-4o Mini (intent parsing via HTTP API)
- **Data Storage:** Mock JSON (assets) + optional Firebase Firestore
- **Build & Deployment:** Codemagic (cloud APK builds)
- **Orchestration:** Google Antigravity (vibe-coding & planning)

---

## 🧠 Agentic Workflow (Core Feature)

Every user interaction triggers an **Agent Reasoning** flow visible on-screen:

### **Flow 1: Multilingual Intent Parsing**
```
User Input: "G-13 mein bachay ke liye math tutor chahiye kal shaam, mehnga na ho"
  ↓
[Agent Reasoning Panel]
1. Input language detected: mixed Urdu/English/Roman Urdu
2. Extracted subject: Math
3. Identified location: G-13
4. Assessed urgency: high
5. Budget preference: low
6. Confidence Score: 0.90
  ↓
[Low confidence? → Show confirmation question]
  ↓
Extracted Requirements: Subject | Location | Urgency | Time | Budget
```

**Implementation:**
- OpenAI API (gpt-4o-mini) parses raw input with a strict JSON prompt
- Returns: `{ subject, location, urgency, preferredTime, budgetLevel, constraints, confidenceScore, needsConfirmation, confirmationQuestion }`
- If `confidenceScore < 0.6`, user refines via confirmation dialog before proceeding

---

### **Flow 2: Multi-Factor Intelligent Matching**
```
[Agent Reasoning Panel]
1. Evaluating 6 tutors across 8 factors
2. Filtering by subject: Math
3. 5 tutors qualify
4. Ranking by weighted score (not distance alone)
5. Top match: Sir Ahmed Raza with score 93.1
  ↓
[Ranked Tutor List with Score Breakdown]
```

**8 Ranking Factors (Weighted):**
1. **Subject Match** (20%) — exact specialization match
2. **Proximity** (15%) — same sector = 1.0, adjacent = 0.5, far = 0.2
3. **Rating** (15%) — normalized 0-5 → 0-1
4. **Review Recency** (8%) — recent reviews weighted higher
5. **On-Time Score** (12%) — reliability metric
6. **Price Fit** (13%) — budget-aware pricing preference
7. **Reliability** (10%) — 1 − cancellation_rate
8. **Risk Score** (7%) — fraud/complaint history

**Each tutor card shows:**
- Rank badge (#1, #2, etc.)
- Name, subjects, sector, rating, hourly rate
- **Weighted total score (0-100)**
- Expandable "Why this ranking?" — visual bar chart of all 8 factors

---

### **Flow 3: Transparent Dynamic Pricing**
```
[Agent Reasoning Panel]
1. Calculating fair price for Sir Ahmed Raza (O/A Levels, on-time: 0.95)
2. Base rate: Rs 1200/hr
3. Complexity adjustment: +30% (A-Levels = 1.3x)
4. Urgency surcharge: +25% (high demand = 1.25x)
5. Distance: +0 (same sector)
6. Loyalty discount: −100 (assumed returning)
7. Surge: +10% (peak time)
  ↓
[Price Breakdown Card]
Base Rate           : Rs 1200
Complexity (A-Lvl)  : Rs 360 (+30%)
Urgency Surcharge   : Rs 300 (+25%)
Surge Charge        : Rs 156 (+10%)
Distance            : Rs 0
Loyalty Discount    : −Rs 100
───────────────────────
Final Price         : Rs 1916
  ↓
[Fairness View]
You Pay             : Rs 1916
Platform Fee (12%)  : Rs 230
Tutor Earns         : Rs 1686
```

**Pricing Logic:**
- Base = tutor's hourly rate
- Complexity multiplier: O/A Levels/University = 1.3x, Matric/FSc = 1.15x, Primary = 1.0x
- Urgency: high = 1.25x, medium = 1.1x, low = 1.0x
- Distance: +150 if different sector, 0 if same
- Loyalty: −100 (flat)
- Surge: +10% if high urgency
- Every line item visible to both student and tutor (transparency)

---

### **Flow 4-7: Booking → Service → Feedback → Dispute**

#### **Screen 5: Booking Confirmation**
- Agent reasoning: availability check, travel buffer, slot reservation
- Simulated booking ID generation
- Mock SMS/WhatsApp notification card
- Receipt with full details

#### **Screen 6: Service Progress & Feedback**
- Stepper: Tutor en-route → Session started → Completed
- Completion checklist simulation
- 5-star rating + comment feedback
- Reputation update reasoning: "Rating adjusted, future match score affected"
- "Report Issue" button → Dispute screen

#### **Screen 7: Dispute Resolution**
- Dropdown: No-show / Quality complaint / Price disagreement / Late arrival
- Agent reasoning for each type:
  - **No-show:** Verify booking → Provider failed → Full refund → Reliability score −X% → Auto-rematching
  - **Quality complaint:** Review feedback → Escalate to human / Partial refund
  - **Price disagreement:** Compare quote vs final → Adjust / refund difference
  - **Late arrival:** Track delay → Compensation / rescheduling
- Final outcome card with resolution type & amount

---

## 📊 Mock Data (Challenge Compliant)

**File:** `assets/tutors.json` (6 tutors, realistic Islamabad sectors)

Each tutor record includes:
```json
{
  "id": "T01",
  "name": "Sir Ahmed Raza",
  "subjects": ["Math", "Physics"],
  "sector": "G-13",
  "lat": 33.642, "lng": 72.985,
  "rating": 4.8,
  "reviews": 124,
  "reviewRecencyDays": 4,
  "onTimeScore": 0.95,
  "hourlyRate": 1200,
  "experienceYears": 8,
  "specialization": "O/A Levels",
  "cancellationRate": 0.03,
  "availableSlots": ["Tomorrow 4PM", "Tomorrow 6PM"],
  "riskScore": 0.05,
  "completedJobs": 210
}
```

**Why mock data?**
- Challenge brief explicitly permits mock data ("may use... mock datasets")
- Simulation demonstrates end-to-end agentic flow without external dependencies
- Focus remains on agent reasoning & workflow orchestration (the core requirement)
- Faster demo, zero API latency, guaranteed reproducibility

---

## 🚀 Antigravity Integration (MANDATORY Requirement)

**Google Antigravity** is used as the **main orchestrator** for the entire development:

### **Plan Mode Usage:**
Every major feature developed using Antigravity's **Plan mode**, which generates visible Plan Artifacts:

1. **Gemini Service Plan** — Intent parsing logic & API integration
2. **Matching Service Plan** — 8-factor algorithm design & weighting
3. **Pricing Service Plan** — Dynamic pricing engine & fairness calc
4. **Screen Implementations** — Each of 7 screens planned → code generated
5. **Widget Reusability** — Agent reasoning panel design & rollout

### **Reasoning Traces Visible In-App:**
Every screen displays an **Agent Reasoning Panel** (top of screen) showing the step-by-step decision process:
- Intent parsing → extracted fields + confidence
- Matching → filtering + ranking logic
- Pricing → breakdown calculation steps
- Booking → availability check + reservation
- Service → progress stage + feedback impact
- Dispute → resolution reasoning

### **Antigravity Artifacts for Submission:**
Compressed ZIP file containing:
- All Plan Artifact screenshots (prove Antigravity orchestrated development)
- Task lists generated per feature
- Walkthroughs & implementation verification steps
- Code generation prompts used

---

## 🎮 How to Run

### **Prerequisites:**
- Flutter 3.41.9+ (stable channel)
- Android SDK + command-line tools
- OpenAI API key (free trial or paid account with credit)

### **Local Setup (Chrome Web - For Testing):**
```bash
# Clone repo
git clone https://github.com/[github-username]/ustad-finder.git
cd ustad-finder

# Install dependencies
flutter pub get

# Run on Chrome (for quick testing)
flutter run -d chrome
```

### **Mobile APK Build:**
```bash
# Via Codemagic CI/CD (preferred - no local Android toolchain needed)
# Push code to GitHub → Codemagic auto-builds release APK
# Download from Codemagic artifacts

# Or local build (requires Android SDK):
flutter build apk --release
# APK at: build/app/outputs/flutter-apk/app-release.apk
```

### **First Test:**
1. Open app → Request screen
2. Tap example chip: *"G-13 mein bachay ke liye math tutor chahiye kal shaam, mehnga na ho"*
3. See parsing with confidence → Matching with 8-factor breakdown → Pricing transparent view
4. End-to-end flow works

---

## 📋 Challenge Requirements Fulfillment

| Requirement | Implementation | Status |
|---|---|---|
| **Multilingual Input** | OpenAI parses Urdu/Roman Urdu/English/code-switched with confidence scoring | ✅ |
| **Intent Extraction** | Service type, location, urgency, time, budget, constraints all extracted | ✅ |
| **Provider Discovery** | Mock tutor dataset (6 tutors) with realistic attributes | ✅ |
| **Multi-Factor Ranking** | 8 weighted factors (subject, proximity, rating, recency, on-time, price fit, reliability, risk) | ✅ |
| **Skill Classification** | Job complexity inferred (Basic/Intermediate/Complex) → affects pricing multiplier | ✅ |
| **Scheduling** | Slot management, travel-time buffers, conflict prevention simulated | ✅ |
| **Dynamic Pricing** | Base + complexity + urgency + distance − loyalty + surge = transparent breakdown | ✅ |
| **Booking Simulation** | Confirmation, SMS notification, receipt, calendar slot block — all simulated | ✅ |
| **Service Quality Loop** | En-route → completion → feedback → rating → reputation update → future match impact | ✅ |
| **Dispute Workflow** | No-show, quality, price, late arrival — all with reasoning & resolution | ✅ |
| **Reasoning Traces** | Agent Reasoning panel on every screen + Antigravity Plan Artifacts for submission | ✅ |
| **Antigravity Orchestration** | Plan mode for every feature, visible in-app, artifacts archived | ✅ |
| **Robustness** | Error handling, fallbacks, retry logic, graceful degradation | ✅ |

---

## 📱 Screenshots & Demo Flow

**Screen 1:** Request input with example chips  
**Screen 2:** Parsed intent + confidence + extracted requirements  
**Screen 3:** Ranked tutors with 8-factor breakdown (why ranking)  
**Screen 4:** Transparent pricing (student + tutor fairness view)  
**Screen 5:** Booking confirmation + simulated notification  
**Screen 6:** Service progress stepper + feedback form  
**Screen 7:** Dispute type selection + resolution reasoning  

All screens feature **Agent Reasoning Panel** at the top with visible step-by-step logic.

---

## 🛠️ Key Libraries & Dependencies

```yaml
dependencies:
  flutter: sdk: flutter
  http: ^1.1.0                    # OpenAI API calls
  google_fonts: ^6.0.0            # Poppins typeface
  flutter_animate: ^4.3.0         # Micro-animations
  intl: ^0.19.0                   # Localization (optional)

dev_dependencies:
  flutter_test:
    sdk: flutter
```

---

## 🎯 Competitive Advantages

1. **Agentic-First Design** — Not just an app with AI, but an AI agent orchestrating the workflow. Reasoning visible at every step.
2. **Multi-Factor Matching** — Goes beyond distance; 8 weighted factors ensure fairness and accuracy.
3. **Transparent Pricing** — Both student and tutor see the breakdown; trust-building in informal economy.
4. **End-to-End Lifecycle** — Request → parsing → matching → pricing → booking → service → feedback → dispute. Complete flow.
5. **Antigravity Integration** — Orchestration layer explicit; planning artifacts prove methodology.
6. **Robustness** — Fallbacks, error handling, retry logic for real-world use.
7. **Multilingual** — Urdu/Roman Urdu/English/code-switched support with confidence scoring.

---

## 🚧 Future Enhancements (Out of Scope for Hackathon)

- Real Google Maps/Places API integration (currently simulated)
- Firebase Firestore for persistent bookings (currently in-app state)
- SMS/WhatsApp Twilio integration (currently UI simulation)
- Provider-side app & demand forecasting
- Payment gateway (Stripe/JazzCash)
- User reviews & image uploads
- Video consultation feature
- Multi-language full localization (ar, ur, etc.)

---

## 📞 Contact & Support

**Team:** Umar Dev  
**Lead:** Muhammad Umar  (https://github.com/Umar-Raza)
**Member:** Abdul Rahman Shahi  (https://github.com/abdulrahman022)

For demo, questions, or clarifications, refer to the accompanying demo video and Antigravity usage video.

---

## 📄 Submission Artifacts

1. **Mobile APK** — Google Drive link (tested on Android 10+)
2. **GitHub Repository** — Full source code
3. **Demo Video (3-5 min)** — End-to-end workflow showcasing agentic reasoning
4. **Antigravity Usage Video (2-3 min)** — Screen recording of Antigravity prompts & Plan mode
5. **README** — This document
6. **Antigravity Traces ZIP** — All Plan Artifacts, task lists, walkthroughs

---

**Built with ❤️ using Google Antigravity | AI Seekho 2026**
