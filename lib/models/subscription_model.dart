import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionModel {
  final String id;
  final String nom;
  final String description;
  final int prix;
  final int duree;
  final bool actif;
  final int ordre;

  const SubscriptionModel({
    required this.id,
    required this.nom,
    required this.description,
    required this.prix,
    required this.duree,
    required this.actif,
    required this.ordre,
  });

  factory SubscriptionModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return SubscriptionModel(
      id: doc.id,
      nom: data["nom"] ?? "",
      description: data["description"] ?? "",
      prix: (data["prix"] ?? 0) as int,
      duree: (data["duree"] ?? 0) as int,
      actif: data["actif"] ?? false,
      ordre: (data["ordre"] ?? 0) as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "nom": nom,
      "description": description,
      "prix": prix,
      "duree": duree,
      "actif": actif,
      "ordre": ordre,
    };
  }

  SubscriptionModel copyWith({
    String? id,
    String? nom,
    String? description,
    int? prix,
    int? duree,
    bool? actif,
    int? ordre,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      prix: prix ?? this.prix,
      duree: duree ?? this.duree,
      actif: actif ?? this.actif,
      ordre: ordre ?? this.ordre,
    );
  }
}