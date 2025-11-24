import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:utspam_c3_if5a_0018/models/rental_model.dart';
import 'package:utspam_c3_if5a_0018/services/local_storage.dart';
import 'package:utspam_c3_if5a_0018/theme/app_theme.dart';

class EditRentalScreen extends StatefulWidget {
  const EditRentalScreen({Key? key}) : super(key: key);

  @override
  _EditRentalScreenState createState() => _EditRentalScreenState();
}

class _EditRentalScreenState extends State<EditRentalScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();

  Rental? _rental;
  double _totalCost = 0;
  double _originalPricePerDay = 0;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _durationController.addListener(_calculateTotalCost);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null) {
      setState(() {
        _rental = args as Rental;
        _customerNameController.text = _rental!.customerName;
        _durationController.text = _rental!.duration.toString();
        _startDateController.text = _rental!.formattedStartDate;
        _originalPricePerDay = _rental!.totalCost / _rental!.duration;
        _totalCost = _rental!.totalCost;
      });
    }
  }

  void _calculateTotalCost() {
    if (_durationController.text.isNotEmpty) {
      final duration = int.tryParse(_durationController.text) ?? 0;
      setState(() {
        _totalCost = duration * _originalPricePerDay;
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _rental?.startDate ?? DateTime.now(),
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

  void _updateRental() async {
    if (_formKey.currentState!.validate() && _rental != null) {
      setState(() {
        _isUpdating = true;
      });

      final updatedRental = Rental(
        id: _rental!.id,
        carId: _rental!.carId,
        carName: _rental!.carName,
        carType: _rental!.carType,
        carImage: _rental!.carImage,
        customerName: _customerNameController.text,
        duration: int.parse(_durationController.text),
        startDate: DateFormat('dd/MM/yyyy').parse(_startDateController.text),
        totalCost: _totalCost,
        status: _rental!.status,
      );

      await LocalStorageService.updateRental(updatedRental);

      // Kembali ke halaman sebelumnya (RentalHistoryScreen) dengan result true
      Navigator.pop(context, true);
    }
  }

  void _cancelEdit() {
    // Jika ada perubahan, konfirmasi sebelum keluar
    final hasChanges = _customerNameController.text != _rental!.customerName ||
        _durationController.text != _rental!.duration.toString() ||
        _startDateController.text != _rental!.formattedStartDate;

    if (hasChanges) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.secondaryDark,
          title: Text(
            'Batalkan Edit',
            style: TextStyle(color: AppTheme.textPrimary),
          ),
          content: Text(
            'Perubahan yang belum disimpan akan hilang. Yakin ingin keluar?',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Lanjutkan Edit', style: TextStyle(color: AppTheme.accentColor)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
                Navigator.pop(context, false); // Kembali tanpa refresh
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
              ),
              child: Text('Ya, Keluar'),
            ),
          ],
        ),
      );
    } else {
      Navigator.pop(context, false);
    }
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
    if (_rental == null) {
      return Scaffold(
        backgroundColor: AppTheme.primaryDark,
        appBar: AppBar(
          backgroundColor: AppTheme.primaryDark,
          elevation: 0,
          title: Text(
            'Edit Sewa',
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
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.accentColor),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryDark,
        elevation: 0,
        title: Text(
          'Edit Penyewaan',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: _cancelEdit,
        ),
      ),
      body: _isUpdating
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppTheme.accentColor),
                  SizedBox(height: 16),
                  Text(
                    'Menyimpan perubahan...',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Car Info Card
                    _buildCarInfoCard(),
                    SizedBox(height: 24),

                    // Edit Form Section
                    _buildEditFormSection(),
                    SizedBox(height: 24),

                    // Total Cost Card
                    _buildTotalCostCard(),
                    SizedBox(height: 32),

                    // Action Buttons
                    _buildActionButtons(),
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryDark,
              borderRadius: BorderRadius.circular(12),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _rental!.carName,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _rental!.carType,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Rp ${_originalPricePerDay.toInt()} / hari',
                  style: TextStyle(
                    color: AppTheme.accentColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditFormSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Edit Data Penyewaan',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 20),

          _buildTextField(
            controller: _customerNameController,
            label: 'Nama Penyewa',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nama penyewa harus diisi';
              }
              return null;
            },
          ),
          SizedBox(height: 16),

          _buildTextField(
            controller: _durationController,
            label: 'Lama Sewa (hari)',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Lama sewa harus diisi';
              }
              final duration = int.tryParse(value);
              if (duration == null || duration <= 0) {
                return 'Lama sewa harus angka positif';
              }
              return null;
            },
          ),
          SizedBox(height: 16),

          TextFormField(
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
              suffixIcon: Icon(
                Icons.calendar_today,
                color: AppTheme.accentColor,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.textSecondary.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.textSecondary.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.accentColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppTheme.textSecondary.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppTheme.textSecondary.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppTheme.accentColor),
        ),
      ),
    );
  }

  Widget _buildTotalCostCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Biaya Lama:',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              Text(
                'Rp ${_rental!.totalCost.toInt()}',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Biaya Baru:',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Rp ${_totalCost.toInt()}',
                style: TextStyle(
                  color: AppTheme.accentColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _cancelEdit,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.textPrimary,
              side: BorderSide(color: AppTheme.textSecondary),
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Batal'),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _isUpdating ? null : _updateRental,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              foregroundColor: AppTheme.primaryDark,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isUpdating
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.primaryDark,
                    ),
                  )
                : Text(
                    'Simpan Perubahan',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}