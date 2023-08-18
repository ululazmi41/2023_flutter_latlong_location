# Find My Location

A Flutter project made to use Location and Mapbox to locate the user's location.

## Pre-Installation

Add these 2 permissions on `AndroidManifest`:

- `<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />`
- `<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />`

For [Mapbox](https://www.mapbox.com/), make sure you have:

- registered at [Mapbox](https://www.mapbox.com/)
- Created a token with secret `Downloads:Read` enabled
- Store your private and public key

## Installation

- Clone this repository
- Rebuild the Flutter App by running `flutter create .` inside the repository
- Open `gradle.properties` and change `<YOUR SECRET API KEY>` with your Mapbox's private key
- Open `main.dart` and change the `<YOUR PUBLIC API KEY>` with your Mapbox's public key
- Run the app

# Running the App
- When starting, the app will ask for permission
- After granted, the app will show "Waiting..." until the latitude and longitude of the user is collected
- Then, the "Locate Me" button will be enabled
- It will show your current location, but it might be inaccurate
