# Project Blueprint

## Overview

This document outlines the project structure, features, and design of the Flutter application.

## Style, Design, and Features

### Initial Version

*   Basic Flutter application structure.
*   Placeholder home screen.

### Version 2: Side Navigation Drawer

*   **Feature:** Added a side navigation drawer to the `HomeScreen`.
*   **Navigation:** The drawer contains links to two new screens:
    *   "Search Incidents" (`/search_incidents`)
    *   "Nearby Incidents" (`/nearby_incidents`)
*   **Icons:**
    *   "Search Incidents" uses the `Icons.search` icon.
    *   "Nearby Incidents" uses the `Icons.near_me` icon.
*   **Routing:** `go_router` is used for navigation.

### Version 3: Icon-Only Global Navigation Drawer

*   **Feature:** The side navigation drawer is now accessible from all main screens and uses only icons for navigation.
*   **UI:** The text labels in the drawer have been removed, leaving only the `Icon` widgets.
*   **Architecture:** Implemented a `ShellRoute` in `go_router` to provide a consistent `Scaffold` and `AppDrawer` for the home, search, and nearby incidents screens.

### Version 4: Bug Fixes and UX Improvements

*   **Bug Fix (Capture Screen):** Fixed an issue where the checkmark button on the "Report Incident" screen did not trigger the incident upload process. The `onPressed` handler now correctly calls the `_submitIncident` function.
*   **Bug Fix (Permissions):** Resolved an issue where the application was requesting microphone permissions in addition to camera permissions. The `CameraController` is now initialized with `enableAudio: false` to prevent this.
*   **UX Improvement (Capture Screen):** Added `SnackBar` notifications to provide users with immediate feedback after an incident is reported, indicating whether the submission was successful or failed.

## Current Plan

*   Implement the bug fixes and UX improvements as described in Version 4.
