import 'package:bioskop/models/reservations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addReservation(Reservation reservation) async {
    try {
      await _firestore.collection('reservations').add(reservation.toMap());
    } catch (e) {
      throw "Gagal Melakukan Reservasi !";
    }
  }
}
