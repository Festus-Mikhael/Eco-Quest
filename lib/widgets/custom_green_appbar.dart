import 'package:flutter/material.dart';

class GreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title; // Judul yang akan ditampilkan di AppBar
  final List<Widget>? actions; // Daftar widget action di sisi kanan AppBar (opsional)

  const GreenAppBar({
    super.key,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: Text(
        title,
        style: theme.textTheme.displayLarge?.copyWith(
          color: Colors.white, // Warna teks judul putih
        ),
      ),
      centerTitle: true, // Judul diposisikan di tengah
      backgroundColor: theme.colorScheme.primary, // Warna background AppBar sesuai primary color theme
      elevation: 0, // Hilangkan bayangan di bawah AppBar
      automaticallyImplyLeading: false, // Supaya tidak muncul tombol back default otomatis
      actions: actions, // Widget action opsional di sisi kanan
      iconTheme: const IconThemeData(color: Colors.white), // Warna ikon AppBar putih
    );
  }

  // Mengatur tinggi AppBar sesuai standar kToolbarHeight
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
