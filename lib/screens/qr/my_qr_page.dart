import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../services/qr_service.dart';

class MyQrPage extends StatefulWidget {
  const MyQrPage({super.key});

  @override
  State<MyQrPage> createState() => _MyQrPageState();
}

class _MyQrPageState extends State<MyQrPage> {
  final QrService _qrService = QrService();

  Future<Map<String, dynamic>> _loadUser() async {
    final userId = await _qrService.getMyUserId();

    if (userId == null) {
      throw Exception(
        "Utilisateur non connecté ou introuvable.",
      );
    }

    final user = await _qrService.findUserById(userId);

    if (user == null) {
      throw Exception(
        "Informations utilisateur introuvables.",
      );
    }

    return user;
  }

  void _copyUserId(String userId) {
    Clipboard.setData(
      ClipboardData(text: userId),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("ID copié."),
      ),
    );
  }

  void _shareUserId({
    required String nom,
    required String userId,
  }) {
    Share.share(
      "Mon ID WiFi Mouni\n\n"
      "Nom : $nom\n"
      "ID : $userId\n\n"
      "Scannez mon QR Code ou utilisez cet ID "
      "pour m'acheter un abonnement.",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mon QR Code",
        ),
        centerTitle: true,
      ),

      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Impossible de charger les informations.\n\n"
                  "${snapshot.error}",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                "Utilisateur introuvable.",
              ),
            );
          }

          final data = snapshot.data!;

          final String nom =
              data["nom"]?.toString() ?? "";

          final String userId =
              data["userId"]?.toString() ?? "";

          if (userId.isEmpty) {
            return const Center(
              child: Text(
                "ID WiFi Mouni introuvable.",
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),

                CircleAvatar(
                  radius: 40,
                  child: Text(
                    nom.isEmpty
                        ? "?"
                        : nom[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                Text(
                  nom.isEmpty
                      ? "Utilisateur"
                      : nom,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "ID : $userId",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 30),

                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.all(20),
                    child: QrImageView(
                      data: userId,
                      version:
                          QrVersions.auto,
                      size: 250,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _copyUserId(userId),
                    icon: const Icon(
                      Icons.copy,
                    ),
                    label: const Text(
                      "Copier mon ID",
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _shareUserId(
                      nom: nom,
                      userId: userId,
                    ),
                    icon: const Icon(
                      Icons.share,
                    ),
                    label: const Text(
                      "Partager",
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}