import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_quest/config/app_theme.dart';
import '../../config/app_constants.dart';
import '../../widgets/custom_white_appbar.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Key untuk form validasi
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // Instance FirebaseAuth untuk registrasi
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Instance Firestore untuk simpan data user
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Variabel untuk menyimpan input user
  String _name = '';
  String _email = '';
  String _password = '';
  // Pesan error jika ada kesalahan saat registrasi
  String? _errorMessage;
  // Indikator loading saat proses registrasi berlangsung
  bool _isLoading = false;
  // Untuk toggle visibility password
  bool _obscurePassword = true;

  Future<void> _register() async {
    // Validasi form terlebih dahulu
    if (_formKey.currentState!.validate()) {
      // Simpan nilai input ke variabel
      _formKey.currentState!.save();

      setState(() => _isLoading = true);

      try {
        // Membuat user baru dengan email dan password di Firebase Auth
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        // Setelah berhasil, simpan data tambahan user ke Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': _name,
          'email': _email,
          'points': 0,       // Default poin user baru
          'rank': 'n/a',     // Default rank user baru
          'createdAt': FieldValue.serverTimestamp(), // Timestamp otomatis server
        });

        // Jika widget masih mounted, navigasi ke halaman login
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppConstants.loginRoute);
        }
      } finally {
        // Setelah proses selesai, matikan loading indicator
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // Fungsi untuk membuat label teks di atas input
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

  // Widget input dengan styling bulat dan opsi obscure text (password)
  Widget _buildRoundedInput({
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    final color = AppTheme.lightTheme.colorScheme.primary.withAlpha(40);
    final borderRadius = BorderRadius.circular(32);

    return TextFormField(
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,    // Validator form
      onSaved: onSaved,        // Simpan value saat form disubmit
      style: TextStyle(color: AppTheme.lightTheme.colorScheme.onSurface),
      decoration: InputDecoration(
        filled: true,
        fillColor: color,
        suffixIcon: suffixIcon,  // Icon di akhir input (misal tombol show password)
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: borderRadius, borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: borderRadius, borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: borderRadius, borderSide: BorderSide.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    return Theme(
      data: theme,
      child: Scaffold(
        // Custom AppBar putih tanpa teks
        appBar: const WhiteAppBar(title: '', actions: []),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              children: [
                // Gambar maskot di atas form
                Image.asset('assets/images/maskot_2.png', height: 120, width: 120),

                // Tampilkan pesan error jika ada
                if (_errorMessage != null)
                  Container(
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
                  ),

                // Form input nama, email, password
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Nama'),
                      _buildRoundedInput(
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Nama tidak boleh kosong';
                          if (value.length < 3) return 'Nama terlalu pendek';
                          return null;
                        },
                        onSaved: (value) => _name = value!.trim(),
                      ),

                      const SizedBox(height: 8),

                      _buildLabel('Email'),
                      _buildRoundedInput(
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Email tidak boleh kosong';
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(value)) return 'Email tidak valid';
                          return null;
                        },
                        onSaved: (value) => _email = value!.trim(),
                      ),

                      const SizedBox(height: 8),

                      _buildLabel('Password'),
                      _buildRoundedInput(
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: theme.colorScheme.primary,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Password tidak boleh kosong';
                          if (value.length < 6) return 'Password minimal 6 karakter';
                          return null;
                        },
                        onSaved: (value) => _password = value!,
                      ),

                      const SizedBox(height: 16),

                      // Tombol daftar, disable saat loading
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          // Tampilkan progress indicator saat loading
                          child: _isLoading
                              ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : const Text('Daftar'),
                        ),
                      ),

                      // Tambahan teks "Sudah punya akun? Masuk" dengan gesture untuk navigasi ke login screen
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Sudah punya akun? '),
                          GestureDetector(
                            onTap: () {
                              // Navigasi ke halaman login jika "Masuk" ditekan
                              Navigator.pushReplacementNamed(context, AppConstants.loginRoute);
                            },
                            child: Text(
                              'Masuk',
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
}
