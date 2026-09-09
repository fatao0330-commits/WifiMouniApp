class ContactModel {
  final String id;
  final String nom;
  final String telephone;
  final String userId;
  final String? photoUrl;

  ContactModel({
    required this.id,
    required this.nom,
    this.telephone = "",
    required this.userId,
    this.photoUrl,
  });

  factory ContactModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return ContactModel(
      id: documentId,
      nom: (map["nom"] ?? "").toString(),
      telephone: (map["telephone"] ?? "").toString(),
      userId: (map["userId"] ?? "").toString(),
      photoUrl: map["photoUrl"]?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "nom": nom,
      "telephone": telephone,
      "userId": userId,
      "photoUrl": photoUrl,
    };
  }
}