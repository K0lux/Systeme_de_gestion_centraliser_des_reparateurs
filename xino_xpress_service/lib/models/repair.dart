//import 'dart:html';

class Repair {
  String? id;
  String clientId;
  String problem;
  double repairCost;
  DateTime submissionDate;
  DateTime? retrievalDate;
  String? audioUrl;
  String status;

  Repair({
    this.id,
    required this.clientId,
    required this.problem,
    required this.repairCost,
    required this.submissionDate,
    this.retrievalDate,
    this.audioUrl,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'problem': problem,
      'repairCost': repairCost,
      'submissionDate': submissionDate.toIso8601String(),
      'retrievalDate': retrievalDate?.toIso8601String(),
      'audioUrl': audioUrl,
      'status': status,
    };
  }

  factory Repair.fromMap(Map<String, dynamic> map, String id) {
    return Repair(
      id: id,
      clientId: map['clientId'],
      problem: map['problem'],
      repairCost: map['repairCost'],
      submissionDate: DateTime.parse(map['submissionDate']),
      retrievalDate: map['retrievalDate'] != null
          ? DateTime.parse(map['retrievalDate'])
          : null,
      audioUrl: map['audioUrl'],
      status: map['status'],
    );
  }
  //factory Repair.fromMap(Map<String, dynamic> data, String id) {
  //return Repair(
  //id: id,
  //clientId: data['clientId'],
  //problem: data['problem'],
  //repairCost: data['repairCost'].toDouble(),
  //submissionDate: (data['submissionDate'] as DateTime).toDate(),
  //retrievalDate: data['retrievalDate'] != null
  //? (data['retrievalDate'] as Timestamp).toDate()
  //: null,
  //audioUrl: data['audioUrl'],
  //status: data['status'],
  //);
  //}

  // Define getters for description and cost
  String get description => problem;
  double get cost => repairCost;
}
