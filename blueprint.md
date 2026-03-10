# Project Blueprint: Incident Reporter
 
## Overview
 
This document outlines the architecture, features, and development plan for the **Incident Reporter**, a Flutter application. The app allows users to capture and report incidents, including an image and the user's current location, and view a list of all reported incidents.
 
## Core Features
 
*   **Incident Capture**: Users can take a picture using the device camera.
*   **Location Tagging**: The app automatically captures the user's current GPS coordinates and fetches the corresponding address.
*   **Incident Reporting**: The captured image, location data, and a timestamp are uploaded and saved as a new incident in a Firestore database.
*   **Incident List**: The home screen displays a list of all previously reported incidents, sorted by time.
*   **Incident Details**: Users can tap on an incident in the list to view its full details, including the image and a map view of the location.
 
## Style and Design
 
*   **Theme**: Material 3 Design
*   **Color Scheme**: A `ColorScheme` generated from a seed color (`Colors.deepPurple`).
*   **Typography**: Custom fonts from `google_fonts` (`Oswald` for display/headlines, `Roboto` for titles, and `Open Sans` for body text).
*   **Component Styling**: Centralized theme for `AppBar` and `ElevatedButton` for a consistent look and feel.
 
## Future Features
 
*   User Authentication (Login/Registration)
*   User profiles
*   Ability to add comments or notes to incidents
*   Offline data storage and synchronization
 
## Current Plan: Rename Package

The goal is to change the internal Dart package name from `myapp` to `incident_reporter` for better project identification and consistency. This will not affect the native Android or iOS application IDs.

**Steps:**

1.  **Update `pubspec.yaml`**: Change the `name` property to `incident_reporter`.
2.  **Update Dart Imports**: Find and replace all import statements from `package:myapp/...` to `package:incident_reporter/...` in all `.dart` files within the `lib/` and `test/` directories.
3.  **Sync Dependencies**: Run `flutter pub get` to apply the changes.
4.  **Update `blueprint.md`**: Update the blueprint to reflect the change of the project's name.
