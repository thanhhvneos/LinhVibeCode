# Resource Allocation System (Hackathon MVP)

## 🎯 Goal
Build an offline iOS app (SwiftUI) that helps managers allocate resources (members) to projects optimally.

---

## 📥 Input

### Member
- id
- name
- skills: [Skill]
- level: Junior / Senior
- cost (rate)
- availability (% free)
- preference (preferred skill/project)
- currentAllocation (% used across projects)

### Project
- id
- name
- timeline
- estimate effort
- requiredRoles:
  - skill
  - quantity

---

## 🧠 Core Logic

### 1. Matching
Calculate score for each member:
- Skill match
- Availability
- Cost (lower is better)
- Preference

### 2. Allocation
- Assign members to project roles
- Multi-project support (allocation %)
- Avoid overload (>100%)

### 3. Risk Analysis
Detect:
- Missing resource
- Overload member
- Skill gap
- Key member dependency

### 4. Simulation
Allow:
- Remove member
- Change requirement
- Recalculate allocation

---

## 📤 Output
- Suggested team per project
- Matching score + explanation
- Risk warnings
- Resource utilization

---

## 🧩 App Structure

### Screen 1: Dashboard
- Total members
- Total projects
- Resource utilization
- Project list + status

---

### Screen 2: Project Detail
- Project info
- Required roles
- Suggested team
- Matching score
- Explain why selected
- Risk analysis
- Button: Run Simulation

---

### Screen 3: Simulation
- Modify input:
  - Remove member
  - Adjust requirement
- Recalculate
- Show diff before/after

---

### Screen 4: Member List (optional)
- Member info
- Allocation
- Skills

---

## ⚙️ Technical Decisions

- Platform: iOS (SwiftUI)
- Offline only (no API)
- Data: Hardcoded JSON / in-memory
- Algorithm: Greedy + scoring
- AI: Rule-based + explainable

---

## 🎯 Scoring Strategy (Hackathon)

- Focus on working demo (end-to-end)
- Explainable AI (score + reason)
- Simulation (what-if analysis)
- Clean UI (SwiftUI native)
- Clear documentation (this file + playbook)

---

## 🚀 Demo Flow

Dashboard → Project → Suggested Team → Risk → Simulation → Impact