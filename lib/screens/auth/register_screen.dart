import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _name = '';
  String _email = '';
  String _password = '';
  String? _errorMessage;
  bool _isLoading = false;
  String _selectedAvatar = 'https://placehold.co/100x100/png?text=User1'; // Default avatar
  final List<String> _avatarOptions = [
    'https://placehold.co/100x100/png?text=User1',
    'https://placehold.co/100x100/png?text=User2',
    'https://placehold.co/100x100/png?text=User3',
  ];

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        // Update display name in Firebase Auth profile
        await userCredential.user?.updateDisplayName(_name);

        // Create user document in Firestore with selected avatar
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': _name,
          'email': _email,
          'avatarUrl': _selectedAvatar,
          'points': 0,
          'badges': [],
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'Email sudah terdaftar';
            break;
          case 'invalid-email':
            errorMessage = 'Format email tidak valid';
            break;
          case 'operation-not-allowed':
            errorMessage = 'Operasi tidak diizinkan';
            break;
          case 'weak-password':
            errorMessage = 'Password terlalu lemah';
            break;
          default:
            errorMessage = 'Gagal mendaftar. Silakan coba lagi';
        }
        if (mounted) {
          setState(() {
            _errorMessage = errorMessage;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Terjadi kesalahan. Silakan coba lagi';
          });
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Widget _buildAvatarOption(String avatarUrl) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAvatar = avatarUrl;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(
            color: _selectedAvatar == avatarUrl ? Colors.blue : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(50),
        ),
        child: CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(avatarUrl),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrasi')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    color: Colors.red.shade100,
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

                // Avatar Selection
                const Text('Pilih Avatar', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _avatarOptions.map((avatar) => _buildAvatarOption(avatar)).toList(),
                ),
                const SizedBox(height: 20),

                // Name Field
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Nama'),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Nama tidak boleh kosong';
                    if (value.length < 3) return 'Nama terlalu pendek';
                    return null;
                  },
                  onSaved: (value) => _name = value!.trim(),
                ),
                const SizedBox(height: 16),

                // Email Field
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Email tidak boleh kosong';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(value)) return 'Email tidak valid';
                    return null;
                  },
                  onSaved: (value) => _email = value!.trim(),
                ),
                const SizedBox(height: 16),

                // Password Field
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Password tidak boleh kosong';
                    if (value.length < 6) return 'Password minimal 6 karakter';
                    return null;
                  },
                  onSaved: (value) => _password = value!,
                ),
                const SizedBox(height: 32),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Daftar'),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Login Link
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pushReplacementNamed(context, '/login'),
                  child: const Text('Sudah punya akun? Masuk'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}