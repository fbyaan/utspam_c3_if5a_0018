import 'package:intl/intl.dart';

class Rental {
  final String id;
  final String carId;
  final String carName;
  final String carType;
  final String carImage;
  final String customerName;
  final int duration;
  final DateTime startDate;
  final double totalCost;
  final RentalStatus status;

  Rental({
    required this.id,
    required this.carId,
    required this.carName,
    required this.carType,
    required this.carImage,
    required this.customerName,
    required this.duration,
    required this.startDate,
    required this.totalCost,
    required this.status,
  });

  String get formattedStartDate {
    return DateFormat('dd/MM/yyyy').format(startDate);
  }

  String get statusText {
    switch (status) {
      case RentalStatus.active:
        return 'Aktif';
      case RentalStatus.completed:
        return 'Selesai';
      case RentalStatus.cancelled:
        return 'Dibatalkan';
    }
  }
}

enum RentalStatus {
  active,
  completed,
  cancelled,
}