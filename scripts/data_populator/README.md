# Test Data Management Scripts

This directory contains scripts for managing test data in your Firebase backend.

---

### ?? `populate_data.dart`

This script generates and uploads 10 random, realistic incident reports to your Firebase project. Each incident includes:

*   Random coordinates within Pune, India.
*   A real-world address reverse-geocoded from the coordinates.
*   A random date within the last 10 days.
*   A random placeholder image uploaded to Firebase Storage.

**To run this script:**

```bash
dart run scripts/populate_data.dart
```

### ?? `clear_data.dart`

This script provides a clean slate by deleting all test data. It includes a safety guardrail to prevent accidental deletion.

*   It deletes all documents from the `incidents` collection in Firestore.
*   It deletes all images from the `incident_images/` folder in Firebase Storage.

**To run this script:**

```bash
dart run scripts/clear_data.dart
```

You will be prompted to type `DELETE` to confirm the action.
