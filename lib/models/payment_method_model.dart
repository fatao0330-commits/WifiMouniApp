class PaymentMethodModel {
  final String id;
  final String nom;
  final String logo;
  final bool actif;
  final int ordre;
  final String type;
  final String pays;
  final String codeUssd;

  PaymentMethodModel({
    required this.id,
    required this.nom,
    required this.logo,
    required this.actif,
    required this.ordre,
    required this.type,
    required this.pays,
    required this.codeUssd,
  });

  factory PaymentMethodModel.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return PaymentMethodModel(
      id: id,
      nom: data["nom"] ?? "",
      logo: data["logo"] ?? "",
      actif: data["actif"] ?? true,
      ordre: data["ordre"] ?? 0,
      type: data["type"] ?? "",
      pays: data["pays"] ?? "",
      codeUssd: data["codeUssd"] ?? "",
    );
  }
}