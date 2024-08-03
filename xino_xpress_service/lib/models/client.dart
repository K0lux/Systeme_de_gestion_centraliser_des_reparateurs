import 'package:cloud_firestore/cloud_firestore.dart';

class Client {
  final String id;
  final String name;
  final String issueDescription;
  final double repairCost;
  final DateTime submissionDate;
  final DateTime? pickupDate;
  final String phone;
  final String? photoUrl;
  final useFingerprint;

  Client({
    required this.id,
    required this.name,
    required this.issueDescription,
    required this.repairCost,
    required this.submissionDate,
    required this.pickupDate,
    required this.phone,
    this.photoUrl,
    required this.useFingerprint,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'issueDescription': issueDescription,
      'repairCost': repairCost,
      'submissionDate': submissionDate,
      'pickupDate': pickupDate,
      'phone': phone,
      'photoUrl': photoUrl,
      'useFingerprint': useFingerprint,
    };
  }

  factory Client.fromMap(Map<String, dynamic> map, String id) {
    return Client(
      id: id,
      name: map['name'],
      issueDescription: map['issueDescription'],
      repairCost: map['repairCost'],
      submissionDate: (map['submissionDate'] as Timestamp).toDate(),
      //pickupDate: (map['pickupDate'] as Timestamp).toDate(),
      pickupDate: map['pickupDate'] != null
          ? (map['pickupDate'] as Timestamp).toDate()
          : null,
      phone: map['phone'],
      photoUrl: map['photoUrl'],
      useFingerprint: map['useFingerprint'] ?? false,
    );
  }
}
