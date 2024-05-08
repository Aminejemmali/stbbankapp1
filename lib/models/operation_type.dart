import 'package:cloud_firestore/cloud_firestore.dart';

class OperationType {
  final String id;
  final String name;

  OperationType({
    required this.id,
    required this.name,
  });

}
  final List<OperationType> operationTypes = [
    OperationType(id: "1", name: "Dépôt"),
    OperationType(id: "2", name: "Retrait"),
    OperationType(id: "3", name: "Demande de Prêt"),
    OperationType(id: "4", name: "Virement"),
    OperationType(id: "5", name: "Paiement de Facture"),
    OperationType(id: "6", name: "Consultation de Solde"),
    OperationType(id: "7", name: "Ouverture de Compte"),
  ];