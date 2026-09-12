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
      nom: (data["nom"] ?? data["name"] ?? "") as String,
      logo: (data["logo"] ?? data["logoUrl"] ?? "") as String,
      actif: (data["actif"] ?? data["enabled"] ?? true) as bool,
      ordre: ((data["ordre"] ?? data["sortOrder"] ?? 0) as num).toInt(),
      type: (data["type"] ?? "") as String,
      pays: (data["pays"] ?? data["country"] ?? "") as String,
      codeUssd: (data["codeUssd"] ?? data["code"] ?? "") as String,
    );
  }
}