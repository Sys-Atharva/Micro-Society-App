# Product Requirement Document (PRD) - Micro-Society App

## 1. Executive Summary
The Micro-Society App is a lightweight community management platform featuring a secure, dual-role architecture (Owner and Tenant). The app facilitates flat management, automated building code generation, payment history tracking, real-time tenant approval handshakes, issue logging, and event broadcasting. It is optimized to perform efficiently on a wide variety of mobile hardware.

## 2. User Roles & Core Value Proposition
*   **Owner:** Registers a property, automatically generates a unique building code, configures bank layout parameters, maps physical flat structures, reviews pending tenant requests via real-time approvals, manages maintenance issues, and schedules community events.
*   **Tenant:** Registers an account, gets locked out of core features until providing a valid building code and selecting an unassigned flat, sits in a real-time reactive waiting room, and gains full access to dashboard analytics, payment selection logs, and issue submission forms once approved by the owner.

## 3. Functional Requirements

### 3.1 Authentication & Gated Access
*   Dual registration paths using a consistent `Name, Email, Password, Confirm Password` form factor.
*   The system creates an unapproved Firestore account metadata placeholder (`approved: false`).
*   **Tenant Onboarding Restriction:** Tenants must input an active building code and select a vacant flat structure. They are strictly restricted to a **Waiting Room Screen** powered by an active stream listener until the owner authorizes access.

### 3.2 Property & Flat Management
*   Owners can dynamically append structural unit configurations into a designated property array.
*   Flats must toggle state seamlessly across four logical classifications: `All`, `Occupied`, `Vacant`, and `Pending`.

### 3.3 Financial & Ticket Operations
*   Owners set up routing details (`Bank Name, Account Number, IFSC`) before core dashboard interactions.
*   Tenants can check current payment parameters and inspect historical transaction logs.
*   Tenants can submit maintenance issues directly to the owner's dashboard view with dynamic operational toggles (`Open`, `In Progress`, `Resolved`).

## 4. Non-Functional Requirements
*   **Performance:** State variations must resolve with low latency. Real-time operations utilize background data listeners to eliminate structural lagging on the client device.
*   **Security:** State transitions modifying sensitive roles require strict database isolation criteria matching deployed Firestore security protocols.