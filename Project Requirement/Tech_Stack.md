# Technical Stack Specifications

## 1. Language & Framework Runtime
*   **Framework Baseline:** Flutter Architecture Framework
*   **Language Ecosystem:** Dart SDK (Target Dependency: `^3.12.1`)
*   **Design Paradigm:** Material 3 Styling Framework (Vercel-Inspired minimal color palettes, tight tracking, crisp boundaries, high contrast layout styling).

## 2. Infrastructure & Backend Core
*   **Identity Provisioning:** Firebase Auth Engine supporting explicit Email and Password identity registers.
*   **Persistence Repository:** Cloud Firestore JSON NoSQL Document Model Store.
*   **Binary Content Management:** Firebase Storage Engine for image records, maintenance documentation, and ticket uploads.

## 3. Local State Management Dependencies
*   **Architectural Provider Model:** `provider: ^6.1.1` (Manages global authentication states, core operational networking loops, data repository access).
*   **Local State Mutators:** Standard Flutter Material Framework `setState` structural markers for local UI views, field parsing updates, and minor view toggles.
*   **Reactive Core Listeners:** Dart Asynchronous Streams API (`StreamSubscription` lifecycle hooks for low-overhead client tracking).