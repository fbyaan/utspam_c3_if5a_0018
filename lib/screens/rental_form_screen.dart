import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:utspam_c3_if5a_0018/models/rental_model.dart';
import 'package:utspam_c3_if5a_0018/models/user_model.dart';
import 'package:utspam_c3_if5a_0018/services/local_storage.dart';
import 'package:utspam_c3_if5a_0018/theme/app_theme.dart';

class RentalFormScreen extends StatefulWidget {
  const RentalFormScreen({Key? key}) : super(key: key);

  @override
  _RentalFormScreenState createState() => _RentalFormScreenState();
}

class _RentalFormScreenState extends State<RentalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();

  Map<String, dynamic>? _selectedCar;
  User? _currentUser;
  double _totalCost = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _durationController.addListener(_calculateTotalCost);
  }

  void _loadUserData() async {
    final user = await LocalStorageService.getLoggedInUser();
    setState(() {
      _currentUser = user;
      _customerNameController.text = user?.fullName ?? '';
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null) {
      setState(() {
        _selectedCar = args as Map<String, dynamic>;
      });
    }
  }

  void _calculateTotalCost() {
    if (_durationController.text.isNotEmpty && _selectedCar != null) {
      final duration = int.tryParse(_durationController.text) ?? 0;
      final pricePerDay = _selectedCar!['price'] as int;
      setState(() {
        _totalCost = (duration * pricePerDay).toDouble();
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.accentColor,
              onPrimary: AppTheme.primaryDark,
              surface: AppTheme.secondaryDark,
              onSurface: AppTheme.textPrimary,
            ),
            dialogBackgroundColor: AppTheme.secondaryDark,
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _startDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _submitRental() async {
    if (_formKey.currentState!.validate()) {
      final rental = Rental(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        carId: _selectedCar!['id'],
        carName: _selectedCar!['name'],
        carType: _selectedCar!['type'],
        carImage: _selectedCar!['image'],
        customerName: _customerNameController.text,
        duration: int.parse(_durationController.text),
        startDate: DateFormat('dd/MM/yyyy').parse(_startDateController.text),
        totalCost: _totalCost,
        status: RentalStatus.active,
      );

      await LocalStorageService.saveRental(rental);

      // Show success dialog
      await _showSuccessDialog();
      
      // Navigate to rental history
      Navigator.pushReplacementNamed(context, '/rental-history');
    }
  }

  Future<void> _showSuccessDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.secondaryDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: AppTheme.successColor,
                  size: 30,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Berhasil!',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Penyewaan mobil berhasil dibuat',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                    foregroundColor: AppTheme.primaryDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text('OK'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _durationController.removeListener(_calculateTotalCost);
    _customerNameController.dispose();
    _durationController.dispose();
    _startDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryDark,
        elevation: 0,
        title: Text(
          'Formulir Penyewaan',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _selectedCar == null
          ? Center(
              child: CircularProgressIndicator(color: AppTheme.accentColor),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Selected Car Card
                    _buildCarInfoCard(),
                    SizedBox(height: 24),

                    // Form Section
                    _buildFormSection(),
                    SizedBox(height: 24),

                    // Total Cost Card
                    _buildTotalCostCard(),
                    SizedBox(height: 32),

                    // Submit Button
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCarInfoCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Car Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryDark,
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.accentColor.withOpacity(0.1),
                  AppTheme.accentColor.withOpacity(0.05),
                ],
              ),
            ),
            child: Center(
              child: Icon(
                Icons.directions_car,
                size: 40,
                color: AppTheme.accentColor,
              ),
            ),
          ),
          SizedBox(width: 16),
          
          // Car Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedCar!['name'],
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _selectedCar!['type'],
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Rp ${_selectedCar!['price']} / hari',
                  style: TextStyle(
                    color: AppTheme.accentColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppTheme.accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Data Penyewaan',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Form Fields
          _buildModernTextField(
            controller: _customerNameController,
            label: 'Nama Penyewa',
            icon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nama penyewa harus diisi';
              }
              return null;
            },
          ),
          SizedBox(height: 16),

          _buildModernTextField(
            controller: _durationController,
            label: 'Lama Sewa (hari)',
            icon: Icons.calendar_today_outlined,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Lama sewa harus diisi';
              }
              final duration = int.tryParse(value);
              if (duration == null || duration <= 0) {
                return 'Lama sewa harus angka positif';
              }
              if (duration > 30) {
                return 'Maksimal sewa 30 hari';
              }
              return null;
            },
          ),
          SizedBox(height: 16),

          // Date Picker Field
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withOpacity(0.05),
            ),
            child: TextFormField(
              controller: _startDateController,
              readOnly: true,
              onTap: _selectDate,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Tanggal mulai harus diisi';
                }
                return null;
              },
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                labelText: 'Tanggal Mulai Sewa',
                labelStyle: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.date_range_outlined,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                suffixIcon: Icon(
                  Icons.arrow_drop_down,
                  color: AppTheme.textSecondary,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.05),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: AppTheme.textSecondary,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildTotalCostCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.accentColor.withOpacity(0.15),
            AppTheme.accentColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accentColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Biaya',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Rp $_totalCost',
                style: TextStyle(
                  color: AppTheme.accentColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.attach_money_rounded,
              color: AppTheme.accentColor,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _submitRental,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentColor,
          foregroundColor: AppTheme.primaryDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          shadowColor: AppTheme.accentColor.withOpacity(0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_car_filled, size: 20),
            SizedBox(width: 8),
            Text(
              'Konfirmasi Penyewaan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}