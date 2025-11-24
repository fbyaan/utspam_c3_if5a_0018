import 'package:flutter/material.dart';
import 'package:utspam_c3_if5a_0018/models/rental_model.dart';
import 'package:utspam_c3_if5a_0018/services/local_storage.dart';
import 'package:utspam_c3_if5a_0018/theme/app_theme.dart';

class RentalDetailScreen extends StatefulWidget {
  const RentalDetailScreen({Key? key}) : super(key: key);

  @override
  _RentalDetailScreenState createState() => _RentalDetailScreenState();
}

class _RentalDetailScreenState extends State<RentalDetailScreen> {
  Rental? _rental;
  bool _isUpdating = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null) {
      setState(() {
        _rental = args as Rental;
      });
    }
  }

  void _cancelRental() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.secondaryDark,
        title: Text(
          'Batalkan Sewa',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          'Apakah Anda yakin ingin membatalkan penyewaan ini?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Tidak', style: TextStyle(color: AppTheme.accentColor)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirmed == true && _rental != null) {
      setState(() {
        _isUpdating = true;
      });

      final updatedRental = Rental(
        id: _rental!.id,
        carId: _rental!.carId,
        carName: _rental!.carName,
        carType: _rental!.carType,
        carImage: _rental!.carImage,
        customerName: _rental!.customerName,
        duration: _rental!.duration,
        startDate: _rental!.startDate,
        totalCost: _rental!.totalCost,
        status: RentalStatus.cancelled,
      );

      await LocalStorageService.updateRental(updatedRental);
      
      setState(() {
        _rental = updatedRental;
        _isUpdating = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Penyewaan berhasil dibatalkan'),
            ],
          ),
          backgroundColor: AppTheme.successColor,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Return to history with updated data
      _returnToHistory();
    }
  }

    void _editRental() {
    if (_rental != null && _rental!.status == RentalStatus.active) {
      Navigator.pushNamed(
        context,
        '/edit-rental',
        arguments: _rental,
      ).then((shouldRefresh) {
        // Refresh data jika kembali dari edit dengan perubahan
        if (shouldRefresh != null && shouldRefresh is bool && shouldRefresh == true) {
          _returnToHistory(); // Kembali ke riwayat dengan data terupdate
        }
      });
    }
  }

  void _returnToHistory() {
    // Pop dengan result true untuk trigger refresh di RentalHistoryScreen
    Navigator.pop(context, true);
  }

  void _showUpdateInProgress() {
    if (_isUpdating) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.secondaryDark,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppTheme.accentColor),
              SizedBox(height: 16),
              Text(
                'Memperbarui data...',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_rental == null) {
      return Scaffold(
        backgroundColor: AppTheme.primaryDark,
        appBar: AppBar(title: Text('Detail Penyewaan')),
        body: Center(child: CircularProgressIndicator(color: AppTheme.accentColor)),
      );
    }

    // Show loading dialog when updating
    if (_isUpdating) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showUpdateInProgress();
      });
    }

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        title: Text('Detail Penyewaan'),
        actions: [
          // Refresh button
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              // Force reload current rental data
              _reloadRentalData();
            },
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _isUpdating
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppTheme.accentColor),
                  SizedBox(height: 16),
                  Text(
                    'Memperbarui data...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Mobil
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 80,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryDark,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                _rental!.carImage,
                                fit: BoxFit.cover,
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
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                Text(
                                  _rental!.carType,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Status
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Status:',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getStatusColor(_rental!.status).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _getStatusColor(_rental!.status),
                              ),
                            ),
                            child: Text(
                              _rental!.statusText,
                              style: TextStyle(
                                color: _getStatusColor(_rental!.status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Detail Penyewaan
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Detail Penyewaan',
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                          SizedBox(height: 16),
                          _buildDetailRow('Nama Penyewa', _rental!.customerName),
                          _buildDetailRow('Lama Sewa', '${_rental!.duration} hari'),
                          _buildDetailRow('Tanggal Mulai', _rental!.formattedStartDate),
                          _buildDetailRow('Total Biaya', 'Rp ${_rental!.totalCost}'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Tombol Aksi
                  if (_rental!.status == RentalStatus.active) ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isUpdating ? null : _cancelRental,
                            child: _isUpdating
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppTheme.errorColor,
                                    ),
                                  )
                                : Text('Batalkan Sewa'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.errorColor,
                              side: BorderSide(color: AppTheme.errorColor),
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isUpdating ? null : _editRental,
                            child: Text('Edit Sewa'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                  ],
                  
                  // Tombol Kembali
                  ElevatedButton(
                    onPressed: _isUpdating ? null : () => _returnToHistory(),
                    child: _isUpdating
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('Memperbarui...'),
                            ],
                          )
                        : Text('Kembali ke Riwayat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: AppTheme.accentColor,
                      side: BorderSide(color: AppTheme.accentColor),
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(RentalStatus status) {
    switch (status) {
      case RentalStatus.active:
        return AppTheme.successColor;
      case RentalStatus.completed:
        return Colors.blue;
      case RentalStatus.cancelled:
        return AppTheme.errorColor;
    }
  }

  void _reloadRentalData() async {
    try {
      final rentals = await LocalStorageService.getRentals();
      final updatedRental = rentals.firstWhere(
        (rental) => rental.id == _rental!.id,
        orElse: () => _rental!,
      );
      
      setState(() {
        _rental = updatedRental;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data diperbarui'),
          backgroundColor: AppTheme.successColor,
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      print('Error reloading rental data: $e');
    }
  }
}