enum ReservationStatus {
  pending,
  accepted,
  declined,
  rescheduled,
}

class Reservation {
  final String id;
  final String name;
  final String email;
  final String phone;
  final DateTime visitingTime;
  final ReservationStatus status;

  const Reservation({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.visitingTime,
    this.status = ReservationStatus.pending,
  });

  Reservation copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    DateTime? visitingTime,
    ReservationStatus? status,
  }) {
    return Reservation(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      visitingTime: visitingTime ?? this.visitingTime,
      status: status ?? this.status,
    );
  }
}
