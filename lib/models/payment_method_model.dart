class PaymentMethodModel {
  final String id;
  final String nom;
  final String logo;
  final bool actif;
  final int ordre;
  final String type;
  final String pays;
  final String codeUssd;
  final String description;
  final String instructions;
  final String accountName;
  final String accountNumber;
  final String phoneNumber;

  PaymentMethodModel({
    required this.id,
    required this.nom,
    required this.logo,
    required this.actif,
    required this.ordre,
    required this.type,
    required this.pays,
    required this.codeUssd,
    required this.description,
    required this.instructions,
    required this.accountName,
    required this.accountNumber,
    required this.phoneNumber,
  });

  factory PaymentMethodModel.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return PaymentMethodModel(
      id: id,
      nom: _stringValue(data, const ["nom", "name", "title"]),
      logo: _stringValue(data, const ["logoUrl", "logo", "imageUrl", "image", "iconUrl", "icon"]),
      actif: _boolValue(data["actif"] ?? data["enabled"]),
      ordre: _intValue(data["ordre"] ?? data["sortOrder"]),
      type: _stringValue(data, const ["type", "category"]),
      pays: _stringValue(data, const ["pays", "country", "countryCode"]),
      codeUssd: _stringValue(data, const ["codeUssd", "ussdCode", "code"]),
      description: _stringValue(data, const ["description", "details"]),
      instructions: _stringValue(data, const ["instructions", "paymentInstructions"]),
      accountName: _stringValue(data, const ["accountName", "nomCompte"]),
      accountNumber: _stringValue(data, const ["accountNumber", "numeroCompte"]),
      phoneNumber: _stringValue(data, const ["phoneNumber", "telephone", "numero"]),
    );
  }
}

String _stringValue(Map<String, dynamic> data, List<String> keys) {
  for (final key in keys) {
    final value = data[key];
    if (value is String && value.trim().isNotEmpty) return value.trim();
    if (value is num || value is bool) return value.toString();
    if (value is Map) {
      final nested = value['url'] ?? value['value'] ?? value['text'];
      if (nested is String && nested.trim().isNotEmpty) return nested.trim();
      final entries = value.entries
          .where((entry) => entry.value != null && entry.value.toString().trim().isNotEmpty)
          .map((entry) => '${entry.key}: ${entry.value}')
          .toList();
      if (entries.isNotEmpty) return entries.join('\n');
    }
  }
  return '';
}

bool _boolValue(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) return value.toLowerCase() == 'true' || value == '1';
  return true;
}

int _intValue(Object? value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}