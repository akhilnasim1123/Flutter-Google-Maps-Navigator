# Flutter Google Maps App 🚗🗺️

A Flutter application integrating **Google Maps**, **Places API**, and **Directions API** to provide real-time location tracking, place search, and route drawing between two points.

---

## 🚀 Features

- 🌍 **Live User Location** — Fetches and displays the user’s current position using **Geolocator**
- 🔎 **Search Places** — Uses **Google Places Autocomplete** for searching destinations
- 🗺️ **Interactive Map** — Powered by **Google Maps Flutter**
- 🧭 **Route Directions** — Fetches route path using **Google Directions API** and displays it with polylines
- 🧩 **Dynamic Camera Control** — Moves and zooms to user-selected or current locations
- ⚙️ **Hybrid Map Mode** — Combines satellite and street map layers
- 💬 **Error Handling** — Graceful alerts for denied location permissions or disabled GPS

---

## 🛠️ Built With

- **Flutter**
- **google_maps_flutter**
- **flutter_google_places**
- **google_maps_webservice**
- **geolocator**

---

## 📱 App Preview

> *(Add screenshots or GIFs here if you have them)*  
> Example: `assets/screenshot1.png`, `assets/screenshot2.gif`

---

## ⚙️ Setup Instructions

### 1️⃣ Clone the Repository
```bash
git clone https://github.com/akhilnasim1123/Flutter-Google-Maps-Navigator.git
```
### 2️⃣ Install Dependencies
```bash
flutter pub get
```
### 3️⃣ Configure Google API Key
In your Flutter code (main.dart), replace the placeholder key:
```bash
const String googleApiKey = 'YOUR_API_KEY';
```
## ⚠️ Important:
Do not commit your real Google API key to GitHub.
You can store it safely in a .env file or local build config.

### 4️⃣ Enable Google APIs

Enable the following APIs in your Google Cloud Console:

- **Maps SDK for Android**
- **Maps SDK for iOS**
- **Places API**
- **Directions API**
Then, restrict your key to your app’s package name and SHA-1 fingerprint for security.

### ▶️ Run the App
```bash
flutter run
```
### 🧭 How It Works

1. **On startup, the app requests location permission and fetches your current GPS location.**

2. **You can search for a place using the floating search button.**

3. **Once selected, the app fetches route directions between your current location and destination.**

4. **The map displays a blue polyline for the route path.**
