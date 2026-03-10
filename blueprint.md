# Project Blueprint

## Overview

This is an incident reporter application that allows users to capture images of incidents, which are then stored and displayed. The application uses Firebase for backend services, including Cloud Storage for images and Cloud Firestore for incident data.

## Features Implemented

*   **Incident Capture:** Users can capture an image of an incident using the device camera.
*   **Location Tracking:** The user's current location (latitude and longitude) is captured with the incident.
*   **Firebase Integration:**
    *   Images are uploaded to Firebase Storage.
    *   Incident data (image URL, location, timestamp) is saved to Cloud Firestore.
*   **Incident Feed:** The home screen displays a real-time list of all reported incidents, sorted by timestamp.
*   **Incident Details:** Users can tap on an incident to view its details, including the captured image and location data.
*   **Navigation:** The application uses `go_router` for navigating between the home, capture, and incident details screens.
*   **Styling:** The application uses a custom theme with `google_fonts` for a consistent and modern look and feel.

## Future Features

*   User Authentication (Login/Registration)
*   User profiles
*   Ability to add comments or notes to incidents
*   Offline data storage and synchronization

## Current Plan

All tasks for the initial version are complete. The application now has the core functionality for reporting and viewing incidents.
