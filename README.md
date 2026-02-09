# FitSync – Personal Health & Fitness Tracker

**Project Codename:** FitSync  
**Current Stage:** Early MVP / Prototype (Health Dashboard + Planned ML Posture Module)  
**Platform:** Flutter (Android)  
**Last Updated:** February 2026  
**Primary Data Source:** Sahha Flutter SDK (Passive Health Sensing)  
**Planned ML Extension:** On-device Pose Estimation & Posture Feedback  
**Backend:** Firebase Authentication + Firestore  
**UI Style:** Dark-themed, modern, green accent (`#7CBA3B`)

---

## 1. Project Goal
Build a modern, privacy-first daily health companion that:
* **Passive Tracking:** Collects steps, heart metrics, sleep, energy, and exercise via **Sahha**.
* **Visual Insights:** Provides clean daily summaries, progress visuals, and persistent goals.
* **Gamification:** Rewards consistency with XP, levels, and streak celebrations.
* **Active Coaching (Future):** Uses **on-device machine learning** to detect posture in real-time during sitting, yoga, or exercise, evolving the app from a tracker to a form coach.

---

## 2. Current Core Features (Implemented)

| Feature Area | Status | Implementation Notes |
| :--- | :--- | :--- |
| **Sahha SDK Integration** | ✅ | Sandbox env; 20+ sensors (Steps, HR, HRV, Sleep, Energy). |
| **Daily Health Dashboard** | ✅ | Activity rings, goal progress bars, sleep & exercise lists. |
| **Persistent Daily Goals** | ✅ | Automatically carries over goals from the most recent entry. |
| **Step-Goal Reward** | ✅ | +100 XP & full-screen `StreakAnimation` on goal completion. |
| **Date Browsing** | ✅ | `table_calendar` integration for historical data viewing. |
| **Heart Rate Detail** | ✅ | Dedicated `HeartRateGraph` route. |
| **Firebase Sync** | ✅ | Auth and per-user Firestore collections for goals/gamification. |
| **Metric Estimation** | ✅ | Cal ≈ steps × 0.03; Distance ≈ steps × 0.0008 km. |

---

## 3. Planned ML / Posture Detection Module
**Objective:** Real-time form correction for strength training, yoga, and desk-work posture.

### Technology Strategy
We will utilize **`google_mlkit_pose_detection`** for the 2026 MVP due to its stability and lightweight performance on mobile.

* **Landmarks:** Detect 33 body points (shoulders, hips, knees, etc.).
* **Logic:** Calculate joint angles (e.g., knee-hip-shoulder) to classify form quality.
* **Feedback:** Real-time visual overlays + haptic/voice cues.

> **Logic Example:**
> If $KneeAngle < 80^\circ$ or $BackAngle > 160^\circ$ during a squat, trigger a "Straighten Back" alert.

---

## 4. Firestore Data Layout

```text
users/{userId}/
  ├─ healthGoals/{yyyy-MM-dd}
  │    ├─ stepGoal, activeMinutesGoal, activeCaloriesGoal
  │    └─ steps, activeCalories (daily snapshot)
  ├─ gamification/data
  │    └─ experience, level, totalPoints, streak, achievements
  └─ postureSessions/{sessionId} (PLANNED)
       ├─ date, exerciseType, durationSeconds
       ├─ avgPostureScore: 0–100
       └─ alerts: [{timestamp, message, severity}]
