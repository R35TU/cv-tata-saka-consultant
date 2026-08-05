// =============================================================
// FILE   : lib/backend/config/app_config.dart
// TEKNIK : Runtime Configuration
// -------------------------------------------------------------
// FUNGSI :
//   Membaca variabel environment dari file .env.
// =============================================================

import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      // Fallback if .env is missing, prevents crash on first run
      print("Warning: .env file not found, using default configurations.");
      dotenv.env.addAll({
        'DB_NAME': 'konsultan.db',
        'DEBUG': 'true',
      });
    }
  }

  static String get dbName {
    final name = dotenv.env['DB_NAME'];
    return name ?? 'konsultan_default.db';
  }

  static bool get isDebug {
    return dotenv.env['DEBUG']?.toLowerCase() == 'true';
  }
}
