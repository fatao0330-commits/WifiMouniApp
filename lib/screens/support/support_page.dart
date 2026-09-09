import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  static const String supportEmail =
      "supportwifimouni@gmail.com";

  void _copyEmail(BuildContext context) {
    Clipboard.setData(
      const ClipboardData(text: supportEmail),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Adresse e-mail copiée.",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Support"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Icon(
            Icons.support_agent,
            size: 80,
            color: Colors.blue,
          ),

          const SizedBox(height: 20),

          const Center(
            child: Text(
              "Centre d'assistance",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 20),
                      const Text(
            "Si vous rencontrez un problème avec votre compte, "
            "un abonnement ou un paiement, vous pouvez contacter notre équipe.",
            style: TextStyle(
              fontSize: 16,
            ),
            textAlign: TextAlign.justify,
          ),

          const SizedBox(height: 25),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.email,
                color: Colors.blue,
              ),
              title: const Text(
                "Adresse e-mail",
              ),
              subtitle: const Text(
                supportEmail,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () => _copyEmail(context),
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Nous répondons généralement dans un délai de 24 à 48 heures.",
            style: TextStyle(
              fontSize: 16,
            ),
            textAlign: TextAlign.justify,
          ),

          const SizedBox(height: 25),
                      const Text(
            "Avant de contacter le support, vérifiez :",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            "• Que votre connexion Internet fonctionne.\n"
            "• Que votre paiement a été effectué.\n"
            "• Que votre abonnement est toujours actif.\n"
            "• Que votre application est à jour.",
            style: TextStyle(
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 25),

          const Text(
            "Merci d'indiquer votre ID WiFi Mouni dans votre message afin que nous puissions traiter votre demande plus rapidement.",
            style: TextStyle(
              fontSize: 16,
            ),
            textAlign: TextAlign.justify,
          ),

          const SizedBox(height: 30),
                      Center(
            child: ElevatedButton.icon(
              onPressed: () => _copyEmail(context),
              icon: const Icon(Icons.copy),
              label: const Text(
                "Copier l'adresse e-mail",
              ),
            ),
          ),

          const SizedBox(height: 30),

          const Center(
            child: Text(
              "© 2026 WiFi Mouni\nSupport officiel",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}