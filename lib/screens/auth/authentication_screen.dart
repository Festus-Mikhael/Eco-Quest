import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Widget stateless untuk halaman autentikasi awal
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengambil tema dari context agar konsisten dengan tema aplikasi
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // Body dengan padding di semua sisi
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // rata kiri semua anak widget
          children: [
            const Spacer(flex: 2), // Spacer besar di atas untuk memberi jarak

            // Gambar maskot yang ditampilkan di tengah
            Center(
              child: Image.asset(
                'assets/images/maskot_1.png',
                height: 200,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 40), // Jarak vertikal

            // Judul utama dengan gaya teks besar dan warna utama tema
            Text(
              "Siap Jadi \nEco Hero?",
              style: textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
                height: 1.2, // tinggi baris lebih rapat
              ),
            ),

            const SizedBox(height: 20), // Jarak vertikal

            // Baris yang berisi info "Belum punya akun?" dan tombol mulai
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // posisi kiri-kanan
              children: [
                // Text dengan tautan "Yuk daftar!" menggunakan RichText dan GestureRecognizer
                RichText(
                  text: TextSpan(
                    style: textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: "Belum punya akun?\n",
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                      TextSpan(
                        text: "Yuk daftar!",
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.blue,
                        ),
                        // Gesture untuk menangani tap pada teks "Yuk daftar!"
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushNamed(context, '/register'); // Navigasi ke halaman register
                          },
                      ),
                    ],
                  ),
                ),

                // Tombol "Ayo Mulai" yang mengarahkan ke halaman login
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary, // Warna tombol sesuai tema utama
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32), // Sudut membulat
                    ),
                  ),
                  child: Text(
                    "Ayo Mulai",
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Warna teks tombol putih
                    ),
                  ),
                ),
              ],
            ),

            const Spacer(flex: 1), // Spacer di bawah untuk mengisi ruang kosong
          ],
        ),
      ),
    );
  }
}
