import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:utspam_c3_if5a_0018/theme/app_theme.dart';

class CarListScreen extends StatefulWidget {
  const CarListScreen({Key? key}) : super(key: key);

  @override
  _CarListScreenState createState() => _CarListScreenState();
}

class _CarListScreenState extends State<CarListScreen> {
  final List<Map<String, dynamic>> _cars = [
    {
      "id": "1",
      "name": "Land Rover Defender",
      "type": "Luxury Off-Road",
      "image": "assets/land_rover_defender.jpg",
      "price": 2200000,
      "rating": 4.8,
      "transmission": "Automatic",
      "seats": 6
    },
    {
      "id": "2",
      "name": "Mercedes-Benz G-Class",
      "type": "Luxury SUV Off-Road",
      "image": "assets/mercedes_benz_gclass.jpg",
      "price": 3200000,
      "rating": 4.9,
      "transmission": "Automatic",
      "seats": 5
    },
    {
      "id": "3",
      "name": "Toyota Land Cruiser 70 Series",
      "type": "Legendary Off-Road",
      "image": "assets/lc70.jpg",
      "price": 1500000,
      "rating": 4.7,
      "transmission": "Manual",
      "seats": 5
    },
    {
      "id": "4",
      "name": "Jeep Wrangler Rubicon",
      "type": "Hardcore Off-Road",
      "image": "assets/wrangler.jpg",
      "price": 1200000,
      "rating": 4.6,
      "transmission": "Manual",
      "seats": 4
    },
    {
      "id": "5",
      "name": "Ford Bronco Raptor",
      "type": "Performance Off-Road",
      "image": "assets/ford_bronco_raptor.jpg",
      "price": 1900000,
      "rating": 4.7,
      "transmission": "Automatic",
      "seats": 5
    },
    {
      "id": "6",
      "name": "Toyota 4Runner TRD Pro",
      "type": "Adventure SUV",
      "image": "assets/4runner.jpg",
      "price": 1300000,
      "rating": 4.5,
      "transmission": "Automatic",
      "seats": 5
    },
    {
      "id": "7",
      "name": "Land Rover Discovery",
      "type": "Luxury Off-Road",
      "image": "assets/discovery.jpg",
      "price": 1800000,
      "rating": 4.6,
      "transmission": "Automatic",
      "seats": 7
    },
    {
      "id": "8",
      "name": "Lexus GX 460",
      "type": "Luxury Off-Road",
      "image": "assets/lexus_gx_460.jpg",
      "price": 1700000,
      "rating": 4.4,
      "transmission": "Automatic",
      "seats": 7
    }
  ];

  // Filter states
  String _selectedType = 'All';
  String _selectedTransmission = 'All';
  String _selectedSeats = 'All';
  double _minPrice = 0;
  double _maxPrice = 5000000;
  bool _showFilters = false;

  // Available filter options
  final List<String> _carTypes = ['All', 'Luxury Off-Road', 'Luxury SUV Off-Road', 'Legendary Off-Road', 'Hardcore Off-Road', 'Performance Off-Road', 'Adventure SUV'];
  final List<String> _transmissions = ['All', 'Manual', 'Automatic'];
  final List<String> _seatsOptions = ['All', '4', '5', '6', '7'];

  List<Map<String, dynamic>> get _filteredCars {
    return _cars.where((car) {
      // Filter by type
      if (_selectedType != 'All' && car['type'] != _selectedType) {
        return false;
      }
      
      // Filter by transmission
      if (_selectedTransmission != 'All' && car['transmission'] != _selectedTransmission) {
        return false;
      }
      
      // Filter by seats
      if (_selectedSeats != 'All' && car['seats'].toString() != _selectedSeats) {
        return false;
      }
      
      // Filter by price range
      if (car['price'] < _minPrice || car['price'] > _maxPrice) {
        return false;
      }
      
      return true;
    }).toList();
  }

  void _resetFilters() {
    setState(() {
      _selectedType = 'All';
      _selectedTransmission = 'All';
      _selectedSeats = 'All';
      _minPrice = 0;
      _maxPrice = 5000000;
    });
  }

  void _applyFilters() {
    setState(() {
      _showFilters = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryDark,
        elevation: 0,
        title: Text(
          'Daftar Mobil ',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        
      ),
      body: Column(
        children: [
          // Filter Section
          _buildFilterSection(),
          SizedBox(height: 16),
          
          // Active Filters
          _buildActiveFilters(),
          
          // Car Count
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  '${_filteredCars.length} mobil tersedia',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                Spacer(),
                if (_hasActiveFilters)
                  GestureDetector(
                    onTap: _resetFilters,
                    child: Text(
                      'Reset Filter',
                      style: TextStyle(
                        color: AppTheme.accentColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 16),
          
          // Car List
          Expanded(
            child: _filteredCars.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _filteredCars.length,
                    itemBuilder: (context, index) {
                      final car = _filteredCars[index];
                      return _buildCarCard(car, context);
                    },
                  ),
          ),
        ],
      ),

      // Filter Bottom Sheet
      bottomSheet: _showFilters ? _buildFilterBottomSheet() : null,
    );
  }

  bool get _hasActiveFilters {
    return _selectedType != 'All' ||
        _selectedTransmission != 'All' ||
        _selectedSeats != 'All' ||
        _minPrice > 0 ||
        _maxPrice < 5000000;
  }

  Widget _buildFilterSection() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showFilters = true;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.secondaryDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.accentColor.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter Mobil',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _hasActiveFilters ? 'Filter aktif' : 'Temukan mobil yang di inginkan',
                    style: TextStyle(
                      color: _hasActiveFilters ? AppTheme.accentColor : AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.filter_list,
                color: _hasActiveFilters ? AppTheme.accentColor : AppTheme.textSecondary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveFilters() {
    if (!_hasActiveFilters) return SizedBox.shrink();

    return Container(
      height: 40,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (_selectedType != 'All')
            _buildFilterChip('Type: $_selectedType', () {
              setState(() {
                _selectedType = 'All';
              });
            }),
          if (_selectedTransmission != 'All')
            _buildFilterChip('Transmisi: $_selectedTransmission', () {
              setState(() {
                _selectedTransmission = 'All';
              });
            }),
          if (_selectedSeats != 'All')
            _buildFilterChip('Seats: $_selectedSeats', () {
              setState(() {
                _selectedSeats = 'All';
              });
            }),
          if (_minPrice > 0 || _maxPrice < 5000000)
            _buildFilterChip(
              'Harga: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(_minPrice)} - ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(_maxPrice)}',
              () {
                setState(() {
                  _minPrice = 0;
                  _maxPrice = 5000000;
              });
            }
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onDelete) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accentColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.accentColor,
              fontSize: 12,
            ),
          ),
          SizedBox(width: 4),
          GestureDetector(
            onTap: onDelete,
            child: Icon(
              Icons.close,
              size: 14,
              color: AppTheme.accentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBottomSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Mobil Off-Road',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: AppTheme.textPrimary),
                onPressed: () {
                  setState(() {
                    _showFilters = false;
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 20),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [  
                  // Transmission Filter
                  _buildFilterSectionTitle('Transmisi'),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _transmissions.map((transmission) {
                      return FilterChip(
                        label: Text(transmission),
                        selected: _selectedTransmission == transmission,
                        onSelected: (selected) {
                          setState(() {
                            _selectedTransmission = selected ? transmission : 'All';
                          });
                        },
                        backgroundColor: AppTheme.primaryDark,
                        selectedColor: AppTheme.accentColor.withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: _selectedTransmission == transmission ? AppTheme.accentColor : AppTheme.textPrimary,
                        ),
                        checkmarkColor: AppTheme.accentColor,
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 24),

                  // Seats Filter
                        _buildFilterSectionTitle('Jumlah Kursi'),
                        SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _seatsOptions.map((seats) {
                            return FilterChip(
                              label: Text(seats == 'All' ? 'Semua' : '$seats Kursi'),
                              selected: _selectedSeats == seats,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedSeats = selected ? seats : 'All';
                                });
                              },
                              backgroundColor: AppTheme.primaryDark,
                              selectedColor: AppTheme.accentColor.withOpacity(0.2),
                              labelStyle: TextStyle(
                                color: _selectedSeats == seats ? AppTheme.accentColor : AppTheme.textPrimary,
                              ),
                              checkmarkColor: AppTheme.accentColor,
                            );
                          }).toList(),
                        ),

                        SizedBox(height: 24),

                        // Price Range Filter
                      _buildFilterSectionTitle('Rentang Harga'),
                  SizedBox(height: 12),
                  Column(
                    children: [
                      RangeSlider(
                        values: RangeValues(_minPrice, _maxPrice),
                        min: 0,
                        max: 5000000,
                        divisions: 10,
                        labels: RangeLabels(
                          NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(_minPrice),
                          NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(_maxPrice),
                        ),
                        onChanged: (values) {
                          setState(() {
                            _minPrice = values.start;
                            _maxPrice = values.end;
                          });
                        },
                        activeColor: AppTheme.accentColor,
                  inactiveColor: AppTheme.textSecondary.withOpacity(0.3),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(_minPrice),
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(_maxPrice),
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetFilters,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textPrimary,
                    side: BorderSide(color: AppTheme.textSecondary),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Reset'),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                    foregroundColor: AppTheme.primaryDark,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Terapkan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            'Tidak ada mobil yang sesuai',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Coba ubah filter pencarian Anda',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _resetFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              foregroundColor: AppTheme.primaryDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Reset Filter'),
          ),
        ],
      ),
    );
  }

  Widget _buildCarCard(Map<String, dynamic> car, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/rental-form',
              arguments: car,
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Name and Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        car['name'],
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                // Car Image and Details
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Car Image
                    // Car Image
                    Container(
                      width: 120,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryDark,
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.accentColor.withOpacity(0.15),
                            AppTheme.accentColor.withOpacity(0.05),
                          ],
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          car['image'],
                          fit: BoxFit.cover,  // Agar gambar menutupi container tanpa distorsi
                          errorBuilder: (context, error, stackTrace) {
                            // Placeholder jika gambar gagal dimuat
                            return Center(
                              child: Icon(
                                Icons.directions_car,
                                size: 50,
                                color: AppTheme.accentColor,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    
                    // Car Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Type
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 1, vertical: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              car['type'],
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),

                          // Specifications
                          Row(
                            children: [
                              _buildSpecItem(Icons.settings, car['transmission']),
                              SizedBox(width: 15),
                              _buildSpecItem(Icons.people, '${car['seats']}'),
                            ],
                          ),
                          SizedBox(height: 12),

                          // Price
                          Text(
                            NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(car['price']) + ' / hari',
                            style: TextStyle(
                              color: AppTheme.accentColor,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 16),
                
                // Rent Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/rental-form',
                        arguments: car,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor,
                      foregroundColor: AppTheme.primaryDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions_car, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Sewa Sekarang',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppTheme.textSecondary,
          size: 16,
        ),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}