import 'package:flutter/material.dart';
import 'package:utspam_c3_if5a_0018/models/user_model.dart';
import 'package:utspam_c3_if5a_0018/services/local_storage.dart';
import 'package:utspam_c3_if5a_0018/theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _showPassword = false;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _fullNameController.addListener(_checkFormValid);
    _nikController.addListener(_checkFormValid);
    _emailController.addListener(_checkFormValid);
    _phoneController.addListener(_checkFormValid);
    _addressController.addListener(_checkFormValid);
    _usernameController.addListener(_checkFormValid);
    _passwordController.addListener(_checkFormValid);
  }

  void _checkFormValid() {
    setState(() {
      _isFormValid =
          _fullNameController.text.isNotEmpty &&
          _nikController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _phoneController.text.isNotEmpty &&
          _addressController.text.isNotEmpty &&
          _usernameController.text.isNotEmpty &&
          _passwordController.text.length >= 8;
    });
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulasi proses registrasi
      await Future.delayed(Duration(seconds: 2));

      final newUser = User(
        fullName: _fullNameController.text,
        nik: _nikController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        username: _usernameController.text,
        password: _passwordController.text,
      );

      // Simpan user ke local storage
      await LocalStorageService.saveUser(newUser);

      // Tampilkan pesan sukses
      _showSuccessMessage();

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessMessage() {
    // Option 1: Menggunakan SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Akun berhasil dibuat!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Redirect ke login setelah delay
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/login');
    });

    // // Option 2: Menggunakan Dialog (uncomment jika prefer dialog)
    // showDialog(
    //   context: context,
    //   barrierDismissible: false,
    //   builder: (BuildContext context) {
    //     return AlertDialog(
    //       title: Text('Sukses'),
    //       content: Text('Akun berhasil dibuat!'),
    //       actions: [
    //         TextButton(
    //           onPressed: () {
    //             Navigator.of(context).pop();
    //             Navigator.pushReplacementNamed(context, '/login');
    //           },
    //           child: Text('OK'),
    //         ),
    //       ],
    //     );
    //   },
    // );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email harus diisi';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor telepon harus diisi';
    }
    final phoneRegex = RegExp(r'^[0-9]+$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Nomor telepon hanya boleh berisi angka';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password harus diisi';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  @override
  void dispose() {
    _fullNameController.removeListener(_checkFormValid);
    _nikController.removeListener(_checkFormValid);
    _emailController.removeListener(_checkFormValid);
    _phoneController.removeListener(_checkFormValid);
    _addressController.removeListener(_checkFormValid);
    _usernameController.removeListener(_checkFormValid);
    _passwordController.removeListener(_checkFormValid);

    _fullNameController.dispose();
    _nikController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Text(
                  'Daftar Akun Baru',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                SizedBox(height: 8),
                Text(
                  'Buat akun untuk mulai menyewa mobil',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: 32),
                _buildTextField(
                  controller: _fullNameController,
                  label: 'Nama Lengkap',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama lengkap harus diisi';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                _buildTextField(
                  controller: _nikController,
                  label: 'NIK',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'NIK harus diisi';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                SizedBox(height: 16),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Nomor Telepon',
                  keyboardType: TextInputType.phone,
                  validator: _validatePhone,
                ),
                SizedBox(height: 16),
                _buildTextField(
                  controller: _addressController,
                  label: 'Alamat',
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Alamat harus diisi';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                _buildTextField(
                  controller: _usernameController,
                  label: 'Username',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username harus diisi';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  obscureText: !_showPassword,
                  validator: _validatePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off,
                      color: AppTheme.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                  ),
                ),
                SizedBox(height: 32),
                _isLoading
                    ? Center(child: CircularProgressIndicator(color: AppTheme.accentColor))
                    : ElevatedButton(
                        onPressed: _isFormValid ? _register : null,
                        child: Text('Daftar'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          backgroundColor: _isFormValid
                              ? AppTheme.accentColor
                              : AppTheme.accentColor.withOpacity(0.5),
                          foregroundColor: AppTheme.primaryDark,
                        ),
                      ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Text('Sudah punya akun? Masuk'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    bool obscureText = false,
    int maxLines = 1,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppTheme.textSecondary),
        suffixIcon: suffixIcon,
      ),
    );
  }
}