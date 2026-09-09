import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String userId;
  final String nom;
  final String email;
  final String telephone;

  final int solde;

  final String nomAbonnement;
  final int joursRestants;
  final String statut;

  final DateTime? dateDebutAbonnement;
  final DateTime? dateFinAbonnement;

  const UserModel({
    required this.uid,
    required this.userId,
    required this.nom,
    required this.email,
    required this.telephone,
    required this.solde,
    required this.nomAbonnement,
    required this.joursRestants,
    required this.statut,
    this.dateDebutAbonnement,
    this.dateFinAbonnement,
  });

  factory UserModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return UserModel(
      uid: map["uid"] ?? "",
      userId: map["userId"] ?? "",
      nom: map["nom"] ?? "",
      email: map["email"] ?? "",
      telephone: map["telephone"] ?? "",
      solde: (map["solde"] ?? 0) as int,
      nomAbonnement:
          map["nomAbonnement"] ?? "",
      joursRestants:
          (map["joursRestants"] ?? 0)
              as int,
      statut: map["statut"] ?? "",

      dateDebutAbonnement:
          map["dateDebutAbonnement"] !=
                  null
              ? (map[
                          "dateDebutAbonnement"]
                      as Timestamp)
                  .toDate()
              : null,

      dateFinAbonnement:
          map["dateFinAbonnement"] !=
                  null
              ? (map[
                          "dateFinAbonnement"] 
                      as Timestamp)
                  .toDate()
              : null,
    );
  }
      Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "userId": userId,
      "nom": nom,
      "email": email,
      "telephone": telephone,
      "solde": solde,
      "nomAbonnement": nomAbonnement,
      "joursRestants": joursRestants,
      "statut": statut,
      "dateDebutAbonnement":
          dateDebutAbonnement == null
              ? null
              : Timestamp.fromDate(
                  dateDebutAbonnement!,
                ),
      "dateFinAbonnement":
          dateFinAbonnement == null
              ? null
              : Timestamp.fromDate(
                  dateFinAbonnement!,
                ),
    };
  }

  UserModel copyWith({
    String? uid,
    String? userId,
    String? nom,
    String? email,
    String? telephone,
    int? solde,
    String? nomAbonnement,
    int? joursRestants,
    String? statut,
    DateTime? dateDebutAbonnement,
    DateTime? dateFinAbonnement,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      userId: userId ?? this.userId,
      nom: nom ?? this.nom,
      email: email ?? this.email,
      telephone:
          telephone ?? this.telephone,
      solde: solde ?? this.solde,
      nomAbonnement:
          nomAbonnement ??
              this.nomAbonnement,
      joursRestants:
          joursRestants ??
              this.joursRestants,
      statut: statut ?? this.statut,
      dateDebutAbonnement:
          dateDebutAbonnement ??
              this.dateDebutAbonnement,
      dateFinAbonnement:
          dateFinAbonnement ??
              this.dateFinAbonnement,
    );
  }
}