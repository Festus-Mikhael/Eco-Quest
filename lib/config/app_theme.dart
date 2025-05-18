import 'package:flutter/material.dart';

// Kelas AppTheme mendefinisikan tema aplikasi
class AppTheme {
  // Getter untuk mendapatkan tema terang (light theme)
  static ThemeData get lightTheme {
    // Membuat skema warna berdasarkan seedColor dan warna utama lainnya
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2E8B57),     // Warna dasar untuk menghasilkan skema warna
      primary: const Color(0xFF2E8B57),       // Warna utama aplikasi
      secondary: const Color(0xFF4CAF50),     // Warna sekunder
      surface: const Color(0xFFF5F5F5),       // Warna latar untuk elemen permukaan seperti Card atau Sheet
    );

    // Mengembalikan objek ThemeData yang dikonfigurasi
    return ThemeData(
      colorScheme: colorScheme,               // Menerapkan skema warna yang telah dibuat
      useMaterial3: true,                     // Menggunakan desain Material 3
      fontFamily: 'Quicksand',                // Font default untuk semua teks di aplikasi

      // Tema untuk teks-teks tertentu
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Fredoka',              // Font khusus untuk judul besar
          fontSize: 32,                       // Ukuran font judul
          fontWeight: FontWeight.bold,        // Ketebalan font
          color: colorScheme.primary,         // Warna teks judul menggunakan warna utama
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Quicksand',            // Font untuk isi teks (konten)
          fontSize: 14,                       // Ukuran font isi teks
          height: 1.5,                        // Spasi antarbaris
          color: colorScheme.onSurface,       // Warna teks pada permukaan (biasanya hitam atau putih tergantung latar)
        ),
      ),
    );
  }
}
