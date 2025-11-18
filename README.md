# 📦 Flutter Real-Time Object Detection  

A fully functional **real-time object detection app** built using **Flutter**, **Camera plugin**, and **TensorFlow Lite (TFLite)**.  
The app captures live camera frames, preprocesses them (BGRA → RGB), and performs inference using a lightweight TFLite model.

---

## 🚀 Features

- 📸 Real-time camera streaming  
- ⚡ Fast TensorFlow Lite inference  
- 🧠 Accurate object recognition  
- 🎯 Bounding box overlays  
- 🔧 Custom pixel preprocessing (BGRA → RGB)  
- 📱 Works smoothly on Android devices  
- 🗜 Optimized image conversion for low-latency detection  

---

## 📁 Project Structure

lib/
├── main.dart
├── home_page.dart
├── detector_service.dart
├── preprocess.dart
├── recognition.dart
├── box_painter.dart
assets/
└── models/
├── model.tflite
└── labels.txt

yaml
Copy code

---

## 🛠 Installation

### 1️⃣ Clone the Repo
```bash
git clone https://github.com/<your-username>/<your-repo>.git
cd <your-repo>
2️⃣ Install Flutter Packages
bash
Copy code
flutter pub get
3️⃣ Add Your Model Files
Place them in:

bash
Copy code
assets/models/model.tflite  
assets/models/labels.txt
Ensure the pubspec.yaml includes:

yaml
Copy code
assets:
  - assets/models/model.tflite
  - assets/models/labels.txt
4️⃣ Run the App
bash
Copy code
flutter run
📷 Screenshots
(Add your own screenshots here)

scss
Copy code
![App Screenshot 1](screenshots/shot1.jpg)
![App Screenshot 2](screenshots/shot2.jpg)
![Detection Preview](screenshots/shot3.jpg)
🧠 Model Info
Framework: TensorFlow Lite

Input Format: RGB, Uint8

Recommended input size: 300×300 / 320×320

Output:

Bounding boxes

Class labels

Confidence scores

⚙ Permissions
Add this to AndroidManifest.xml:

xml
Copy code
<uses-permission android:name="android.permission.CAMERA" />
🔧 Troubleshooting
🔴 App not detecting objects
✔ Ensure your model input size & preprocess code match.

🔴 Camera preview is black
✔ Restart the app
✔ Ensure camera permissions are granted

🔴 Gradle/TFLite errors
Use:

Flutter 3.x or above

Android SDK 33+

Java 11 or 17

🔴 Colors incorrect
Check preprocessing bitmasks:

dart
Copy code
final r = (pixel >> 16) & 0xFF;
final g = (pixel >> 8) & 0xFF;
final b = pixel & 0xFF;
📜 License
This project is licensed under the MIT License — free for use and modification.

🧑‍💻 Author
Priyesh Yadav
Flutter • Android Developer
GitHub: https://github.com/<your-username>
Email: your-email@example.com

⭐ Support the Project
If this project helped you, please give it a star ⭐ on GitHub — it motivates further development!

yaml
Copy code

---

# 👍 If you want:
✅ A **GitHub banner/logo**  
✅ A **preview GIF of detection**  
✅ A **better professional README**  
Just tell me!
