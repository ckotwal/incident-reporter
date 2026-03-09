# Project Blueprint

## Overview

This application allows users to capture and report incidents of electric wire damage. It enables users to take photos of the damage, automatically captures the geolocation and time of the incident, and stores this information in a structured database. The app provides a simple and efficient way for field agents or the general public to document infrastructure issues, facilitating quicker response and repair.

## Implemented Style, Design, and Features

### Version 1.0 (Initial Build)

*   **Core Functionality:**
    *   Image capture using the device camera.
    *   Image preview and the option to retake.
    *   Upload of the captured image to Firebase Storage.
    *   Storage of incident metadata (geolocation, address, timestamp, image URL) in Cloud Firestore.
    *   Automatic capture of geolocation (latitude and longitude).
    *   Reverse geocoding to get a human-readable address.
    *   Display of captured incidents in a list.
    *   A detail view for each incident.

*   **User Interface and Design:**
    *   A simple, intuitive interface.
    *   A bottom navigation bar to switch between the capture screen and the incident list.
    *   A consistent and clean theme.

*   **Architecture:**
    *   **State Management:** `provider` for managing application state.
    *   **Data Model:** A clear and structured `Incident` model.
    *   **Services:** Separate services for interacting with Firebase Storage and Cloud Firestore.

## Current Plan

### Request: Build the initial version of the electric wire damage incident reporting app.

1.  **Project Setup and Dependencies:**
    *   Add the following dependencies to `pubspec.yaml`:
        *   `firebase_core`: For Firebase initialization.
        *   `cloud_firestore`: For Firestore database interaction.
        *   `firebase_storage`: For image storage.
        *   `image_picker`: For using the device camera.
        *   `geolocator`: For geolocation capture.
        *   `geocoding`: For reverse geocoding.
        *   `provider`: For state management.

2.  **Firebase Configuration:**
    *   Configure the project for Firebase by adding server configurations to `.idx/mcp.json`.
    *   Initialize Firebase in `lib/main.dart`.

3.  **Application Structure:**
    *   Create a `theme.dart` file for theme definitions.
    *   Modify `main.dart` to set up the main app structure and routing.
    *   Create `models/incident.dart` to define the `Incident` data model.
    *   Create `providers/incidents_provider.dart` to manage incident data.
    *   Create `screens/capture_screen.dart` for capturing and uploading new incidents.
    *   Create `screens/incident_list_screen.dart` to display a list of all incidents.
    *   Create `screens/incident_detail_screen.dart` to show detailed information for a selected incident.

4.  **Data Model (Firestore):**
    *   **Collection:** `incidents`
    *   **Document Fields:**
        *   `imageUrl`: `String` (URL of the image in Firebase Storage)
        *   `latitude`: `double`
        *   `longitude`: `double`
        *   `address`: `String`
        *   `timestamp`: `Timestamp`

5.  **Implementation Steps:**
    *   Add all dependencies to `pubspec.yaml`.
    *   Configure and initialize Firebase.
    *   Create the file structure and placeholder files.
    *   Implement the `CaptureScreen`, including camera access, image preview, and data upload.
    *   Implement the `IncidentListScreen` to fetch and display incidents from Firestore.
    *   Implement the `IncidentDetailScreen` to display the complete details of an incident.
    *   Implement the main app structure and navigation in `main.dart`.
