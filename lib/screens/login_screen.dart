import 'package:flutter/material.dart';
import 'package:utspam_c3_if5a_0018/services/local_storage.dart';
import 'package:utspam_c3_if5a_0018/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';
  bool _showPassword = false;
  bool _isPasswordValid = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordLength);
  }

  void _checkPasswordLength() {
    setState(() {
      _isPasswordValid = _passwordController.text.length >= 8;
    });
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Simulasi proses login
      await Future.delayed(Duration(seconds: 2));

      final user = await LocalStorageService.getUser();
      
      if (user != null && 
          (user.username == _usernameController.text || user.nik == _usernameController.text) &&
          user.password == _passwordController.text) {
        // Login berhasil
        await LocalStorageService.setLoggedInUser(user);
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() {
          _errorMessage = 'Username/NIK atau password salah';
        });
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _passwordController.removeListener(_checkPasswordLength);
    _passwordController.dispose();
    _usernameController.dispose();
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
                // Header dengan ilustrasi
                _buildHeader(),
                SizedBox(height: 48),
                
                // Form Container dengan background card
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Title Section
                      _buildTitleSection(),
                      SizedBox(height: 32),
                      
                      // Error Message
                      if (_errorMessage.isNotEmpty) _buildErrorMessage(),
                      if (_errorMessage.isNotEmpty) SizedBox(height: 16),
                      
                      // Form Fields
                      _buildFormFields(),
                      SizedBox(height: 24),
                      
                      // Login Button
                      _buildLoginButton(),
                      SizedBox(height: 24),
                      
                      // Register Link
                      _buildRegisterLink(),
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

  Widget _buildHeader() {
    return Column(
      children: [
        SizedBox(height: 20),
        // Logo custom
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppTheme.accentColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/logo.jpeg',
              width: 700,
              height: 700,
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selamat Datang',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Masuk ke akun Anda untuk melanjutkan',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.errorColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppTheme.errorColor,
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage,
              style: TextStyle(
                color: AppTheme.errorColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        // Username Field
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white.withOpacity(0.05),
          ),
          child: TextFormField(
            controller: _usernameController,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              labelText: 'Username atau NIK',
              labelStyle: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
              prefixIcon: Icon(
                Icons.person_outline,
                color: AppTheme.textSecondary,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Username/NIK harus diisi';
              }
              return null;
            },
          ),
        ),
        SizedBox(height: 20),
        
        // Password Field
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white.withOpacity(0.05),
          ),
          child: TextFormField(
            controller: _passwordController,
            obscureText: !_showPassword,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
              prefixIcon: Icon(
                Icons.lock_outline,
                color: AppTheme.textSecondary,
              ),
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
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password harus diisi';
              }
              if (value.length < 8) {
                return 'Password minimal 8 karakter';
              }
              return null;
            },
          ),
        ),
        
        // Password Strength Indicator
        SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 14,
              color: _isPasswordValid ? Colors.green : AppTheme.textSecondary,
            ),
            SizedBox(width: 6),
            Text(
              'Minimal 8 karakter',
              style: TextStyle(
                fontSize: 12,
                color: _isPasswordValid ? Colors.green : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: _isLoading
          ? Center(
              child: Container(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.primaryDark,
                ),
              ),
            )
          : ElevatedButton(
              onPressed: _isPasswordValid ? _login : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isPasswordValid
                    ? AppTheme.accentColor
                    : AppTheme.accentColor.withOpacity(0.5),
                foregroundColor: AppTheme.primaryDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                shadowColor: _isPasswordValid
                    ? AppTheme.accentColor.withOpacity(0.3)
                    : Colors.transparent,
              ),
              child: Text(
                'Masuk',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Belum punya akun? ',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacementNamed(context, '/register');
          },
          child: Text(
            'Daftar di sini',
            style: TextStyle(
              color: AppTheme.accentColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}