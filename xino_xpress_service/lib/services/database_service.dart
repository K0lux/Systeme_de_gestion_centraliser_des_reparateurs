import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/client.dart';
import '../models/repair.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Ajouter un nouveau client
  Future<void> addClient(Client client) async {
    try {
      await _db.collection('clients').add(client.toMap());
    } catch (e) {
      print('Erreur lors de l\'ajout du client: $e');
      rethrow;
    }
  }

  // Obtenir un client par son ID
  Future<Client> getClientById(String id) async {
    try {
      DocumentSnapshot doc = await _db.collection('clients').doc(id).get();
      return Client.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      print('Erreur lors de la récupération du client: $e');
      rethrow;
    }
  }

  // Rechercher des clients par nom
  Stream<List<Client>> searchClientsByName(String name) {
    return _db
        .collection('clients')
        .where('name', isGreaterThanOrEqualTo: name)
        .where('name', isLessThan: name + 'z')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                Client.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // Ajouter une nouvelle réparation
  Future<void> addRepair(Repair repair) async {
    try {
      await _db.collection('repairs').add(repair.toMap());
    } catch (e) {
      print('Erreur lors de l\'ajout de la réparation: $e');
      rethrow;
    }
  }

  // Obtenir les réparations d'un client
  Stream<List<Repair>> getClientRepairs(String clientId) {
    return _db
        .collection('repairs')
        .where('clientId', isEqualTo: clientId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                Repair.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // Obtenir les réparations d'un repair
  Stream<List<Repair>> getRepairs(String clientId) {
    return _db
        .collection('repairs')
        .where('clientId', isEqualTo: clientId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                Repair.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // Mettre à jour l'état d'une réparation
  Future<void> updateRepairStatus(String repairId, String newStatus) async {
    try {
      await _db
          .collection('repairs')
          .doc(repairId)
          .update({'status': newStatus});
    } catch (e) {
      print('Erreur lors de la mise à jour de l\'état de la réparation: $e');
      rethrow;
    }
  }
}
