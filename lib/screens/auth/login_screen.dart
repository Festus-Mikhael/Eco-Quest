import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eco_quest/config/app_theme.dart';
import '../../config/app_constants.dart';
import '../../widgets/custom_white_appbar.dart';

// StatefulWidget untuk layar login pengguna
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Key untuk form validasi
  final _formKey = GlobalKey<FormState>();

  // Instance FirebaseAuth untuk autentikasi
  final _auth = FirebaseAuth.instance;

  // Controller untuk mengontrol input email dan password
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // State untuk menampilkan loading, sembunyikan password, dan pesan error
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    // Dispose controller saat widget dibuang untuk mencegah memory leak
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Fungsi utama untuk login menggunakan email dan password
  Future<void> _login() async {
    // Validasi form terlebih dahulu
    if (!_formKey.currentState!.validate()) return;

    // Set state loading dan reset pesan error
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Melakukan login ke Firebase Authentication
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Jika widget sudah tidak ada di tree, hentikan proses
      if (!mounted) return;

      // Navigasi ke halaman home menggantikan halaman login
      Navigator.pushReplacementNamed(context, AppConstants.homeRoute);
    } on FirebaseAuthException catch (e) {
      // Tangani error spesifik dari Firebase Auth
      _handleAuthError(e);
    } catch (e) {
      // Tangani error tak terduga lainnya
      _handleGenericError();
    } finally {
      // Matikan loading saat proses selesai (jika widget masih ada)
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Mengatur pesan error khusus untuk error Firebase Auth
  void _handleAuthError(FirebaseAuthException e) {
    debugPrint('Error Code: ${e.code}');
    final message = _getFriendlyErrorMessage(e.code);
    if (mounted) setState(() => _errorMessage = message);
  }

  // Pesan error default untuk error tak terduga
  void _handleGenericError() {
    debugPrint('Unexpected Error');
    if (mounted) {
      setState(() => _errorMessage = 'Terjadi kesalahan tak terduga. Coba lagi');
    }
  }

  // Mapping kode error Firebase ke pesan yang ramah pengguna
  String _getFriendlyErrorMessage(String errorCode) {
    return switch (errorCode) {
      'invalid-email' => 'Format email tidak valid. Contoh: nama@email.com',
      'user-not-found' => 'Email belum terdaftar. Silakan daftar terlebih dahulu',
      'wrong-password' => 'Password salah. Silakan coba lagi',
      _ => 'Terjadi kesalahan saat login',
    };
  }

  // Widget pembantu untuk menampilkan label input dengan styling khusus
  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppTheme.lightTheme.colorScheme.primary,
        ),
      ),
    );
  }

  // Widget pembantu untuk input teks dengan border membulat dan opsi password
  Widget _buildRoundedInput({
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    TextEditingController? controller,
  }) {
    final color = AppTheme.lightTheme.colorScheme.primary.withAlpha(40);
    final borderRadius = BorderRadius.circular(32);

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: AppTheme.lightTheme.colorScheme.onSurface),
      decoration: InputDecoration(
        filled: true,
        fillColor: color, // Warna latar belakang input
        suffixIcon: suffixIcon, // Icon di ujung kanan input
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: borderRadius, borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: borderRadius, borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: borderRadius, borderSide: BorderSide.none),
      ),
      // Validator: field wajib diisi
      validator: (value) => value?.isEmpty ?? true ? 'Field ini wajib diisi' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: const WhiteAppBar(title: '', actions: []), // AppBar putih custom tanpa judul
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              children: [
                // Gambar maskot di atas form
                Image.asset('assets/images/maskot_2.png', height: 120, width: 120),

                // Jika ada pesan error, tampilkan widget error
                if (_errorMessage != null)
                  _buildErrorWidget(),

                // Form untuk input email dan password
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Email'),
                      _buildRoundedInput(
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                      ),

                      const SizedBox(height: 8),

                      _buildLabel('Password'),
                      _buildRoundedInput(
                        obscureText: _obscurePassword,
                        controller: _passwordController,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: theme.colorScheme.primary,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword), // Toggle tampil/simpan password
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Tombol login
                      _buildLoginButton(),

                      // Tambahan teks "Belum punya akun? Daftar" dengan gesture untuk navigasi ke register screen
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Belum punya akun? '),
                          GestureDetector(
                            onTap: () {
                              // Navigasi ke halaman register jika "Daftar" ditekan
                              Navigator.pushReplacementNamed(context, AppConstants.registerRoute);
                            },
                            child: Text(
                              'Daftar',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget untuk menampilkan pesan error dengan background merah dan icon error
  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Tombol login dengan animasi loading saat proses login berlangsung
  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login, // Disable tombol saat loading
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        // Tampilkan indikator loading jika sedang login, atau teks "Masuk" jika tidak
        child: _isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : const Text('Masuk'),
      ),
    );
  }
}
