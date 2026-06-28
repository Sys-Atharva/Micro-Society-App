# Database Schema Design - Firestore Collections

## 1. `users` Collection
Each document utilizes the validated Firebase Auth `UserCredential.uid` as its distinct Document identifier string.

```json
{
  "uid": "STRING (Document ID)",
  "name": "STRING",
  "email": "STRING",
  "role": "STRING ('owner' | 'tenant')",
  "approved": "BOOLEAN",
  "buildingCode": "STRING (Nullable for Tenants until onboarding)",
  "flatId": "STRING (Nullable for Tenants until onboarding)",
  "bankDetails": {
    "bankName": "STRING",
    "accountNumber": "STRING",
    "ifscCode": "STRING"
  },
  "createdAt": "TIMESTAMP"
}

## 2. flats Collection
Defines physical living structures managed by owners and leased by approved tenants.

{
  "flatId": "STRING (Document ID)",
  "flatNumber": "STRING",
  "buildingCode": "STRING",
  "status": "STRING ('vacant' | 'occupied' | 'pending')",
  "tenantId": "STRING (Nullable)",
  "ownerId": "STRING"
}

## 3. issues Collection
Holds active and resolved maintenance complaints.

{
  "issueId": "STRING (Document ID)",
  "buildingCode": "STRING",
  "flatNumber": "STRING",
  "tenantId": "STRING",
  "title": "STRING",
  "description": "STRING",
  "status": "STRING ('open' | 'in_progress' | 'resolved')",
  "createdAt": "TIMESTAMP"
}

## 4. events Collection
Stores building notices and scheduled activities.

{
  "eventId": "STRING (Document ID)",
  "buildingCode": "STRING",
  "title": "STRING",
  "description": "STRING",
  "eventDate": "TIMESTAMP",
  "createdAt": "TIMESTAMP"
}

## 5. Security Validation Rule Constraints

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.auth.uid == userId;
      // Restrict owner approval updates strictly to the 'approved' field matching security scopes
      allow update: if request.auth != null && 
        (request.auth.uid == userId || 
         request.resource.data.diff(resource.data).hasOnly(['approved']));
    }
    match /flats/{flatId} {
      allow read, write: if request.auth != null;
    }
  }
}