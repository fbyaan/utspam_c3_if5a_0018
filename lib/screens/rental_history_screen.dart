import 'package:flutter/material.dart';
import 'package:utspam_c3_if5a_0018/models/rental_model.dart';
import 'package:utspam_c3_if5a_0018/services/local_storage.dart';
import 'package:utspam_c3_if5a_0018/theme/app_theme.dart';

class RentalHistoryScreen extends StatefulWidget {
  const RentalHistoryScreen({Key? key}) : super(key: key);

  @override
  _RentalHistoryScreenState createState() => _RentalHistoryScreenState();
}

class _RentalHistoryScreenState extends State<RentalHistoryScreen> {
  List<Rental> _rentals = [];

  @override
  void initState() {
    super.initState();
    _loadRentals();
  }

  void _loadRentals() async {
    final rentals = await LocalStorageService.getRentals();
    setState(() {
      _rentals = rentals;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        title: Text('Riwayat Sewa'),
      ),
      body: _rentals.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 80,
                    color: AppTheme.textSecondary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada riwayat sewa',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Sewa mobil pertama Anda sekarang!',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/car-list');
                    },
                    child: Text('Sewa Mobil'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _rentals.length,
              itemBuilder: (context, index) {
                final rental = _rentals[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/rental-detail',
                        arguments: rental,
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                rental.carName,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(rental.status)
                                      .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _getStatusColor(rental.status),
                                  ),
                                ),
                                child: Text(
                                  rental.statusText,
                                  style: TextStyle(
                                    color: _getStatusColor(rental.status),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            rental.carType,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.person, size: 16, 
                                  color: AppTheme.textSecondary),
                              SizedBox(width: 4),
                              Text(
                                rental.customerName,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 16, 
                                  color: AppTheme.textSecondary),
                              SizedBox(width: 4),
                              Text(
                                '${rental.duration} hari - ${rental.formattedStartDate}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Biaya:',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                'Rp ${rental.totalCost}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: AppTheme.accentColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}