import 'package:flutter/material.dart';
import 'package:utspam_c3_if5a_0018/models/rental_model.dart';
import 'package:utspam_c3_if5a_0018/services/local_storage.dart';
import 'package:utspam_c3_if5a_0018/theme/app_theme.dart';
import 'package:utspam_c3_if5a_0018/utils/route_observer.dart';

class RentalHistoryScreen extends StatefulWidget {
  const RentalHistoryScreen({Key? key}) : super(key: key);

  @override
  _RentalHistoryScreenState createState() => _RentalHistoryScreenState();
}

class _RentalHistoryScreenState extends State<RentalHistoryScreen> with RouteAware {
  List<Rental> _rentals = [];
  bool _isLoading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadRentals();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    RouteObserverUtil.routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    RouteObserverUtil.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _loadRentals();
  }

  void _loadRentals() async {
    try {
      final rentals = await LocalStorageService.getRentals();
      if (mounted) {
        setState(() {
          _rentals = rentals;
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
      }
      print('Error loading rentals: $e');
    }
  }

  void _refreshData() async {
    if (_isRefreshing) return;
    
    setState(() {
      _isRefreshing = true;
    });

    _loadRentals();
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

  // Di RentalHistoryScreen, modifikasi method _navigateToRentalDetail:
  void _navigateToRentalDetail(Rental rental) {
    try {
      Navigator.pushNamed(
        context,
        '/rental-detail',
        arguments: rental,
      ).then((shouldRefresh) {
        // Refresh data jika kembali dari detail dengan perubahan
        if (shouldRefresh != null && shouldRefresh is bool && shouldRefresh == true) {
          _refreshData();
        }
      });
    } catch (e) {
      print('Error navigating to rental detail: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tidak dapat membuka detail pemesanan'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        title: Text('Riwayat Sewa'),
        actions: [
          // Refresh Button
          
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AppTheme.accentColor,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Memuat riwayat sewa...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          : _rentals.isEmpty
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
              : RefreshIndicator(
                  color: AppTheme.accentColor,
                  onRefresh: () async {
                    _refreshData();
                  },
                  child: Column(
                    children: [
                      // Refresh Status Indicator
                      if (_isRefreshing)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 8),
                          color: AppTheme.accentColor.withOpacity(0.1),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.accentColor,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Memperbarui data...',
                                style: TextStyle(
                                  color: AppTheme.accentColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      // Last Updated Info
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        color: AppTheme.primaryDark.withOpacity(0.5),
                        
                      ),
                      
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: _rentals.length,
                          itemBuilder: (context, index) {
                            final rental = _rentals[index];
                            return Card(
                              margin: EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                onTap: () => _navigateToRentalDetail(rental),
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              rental.carName,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(width: 8),
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
                                          Icon(Icons.person, 
                                              size: 16, 
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
                                          Icon(Icons.calendar_today, 
                                              size: 16, 
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
                      ),
                    ],
                  ),
                ),
      // Floating Action Button untuk refresh (opsional)
     
    );
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }
}