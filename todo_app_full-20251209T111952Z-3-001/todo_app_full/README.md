# To-Do MVC Complete (Flutter)

Features included:
- MVC pattern: models, controllers, views separated.
- SQLite persistence using sqflite (lib/data/task_database.dart).
- Add / Edit / Delete tasks.
- Mark tasks as complete.
- Categories, Priority, Status fields.
- Calendar view (table_calendar) and List view toggle.
- Settings page: dark mode, font size, accent color (persisted via SharedPreferences).
- All files are commented to help graders find MODEL / VIEW / CONTROLLER.

How to run:
1. Ensure Flutter SDK is installed and Android Studio has an emulator.
2. Open this folder in Android Studio or VS Code.
3. Run `flutter pub get`.
4. Run the app on an emulator or device.

Notes:
- The database file is created in the app documents directory on the device/emulator.
- If your Android toolchain requires a specific JDK (e.g., Java 17), adjust Android Studio settings accordingly.
