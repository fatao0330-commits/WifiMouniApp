import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Confidentialité"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [

          Icon(
            Icons.privacy_tip,
            size: 80,
            color: Colors.blue,
          ),

          SizedBox(height: 20),

          Text(
            "Politique de confidentialité",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 20),

          Text(
            "WiFi Mouni protège les informations personnelles de ses utilisateurs. "
            "Toutes les données sont utilisées uniquement pour fournir les services de l'application.",
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.justify,
          ),

          SizedBox(height: 15),
                      Text(
            "Les informations enregistrées peuvent inclure :",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 10),

          Text(
            "• Nom\n"
            "• Adresse e-mail\n"
            "• Numéro de téléphone\n"
            "• Identifiant WiFi Mouni\n"
            "• Historique des achats\n"
            "• Solde du compte",
            style: TextStyle(fontSize: 16),
          ),

          SizedBox(height: 20),

          Text(
            "Ces informations ne sont jamais vendues à des tiers. Elles servent uniquement à assurer le bon fonctionnement de l'application et à sécuriser votre compte.",
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.justify,
          ),

          SizedBox(height: 20),
                      Text(
            "Sécurité",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 10),

          Text(
            "WiFi Mouni utilise Firebase Authentication et "
            "Cloud Firestore pour protéger les comptes et les données des utilisateurs.",
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.justify,
          ),

          SizedBox(height: 20),

          Text(
            "Si vous avez une question concernant la confidentialité "
            "ou vos données personnelles, contactez notre support :",
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.justify,
          ),

          SizedBox(height: 10),

          SelectableText(
            "supportwifimouni@gmail.com",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),

          SizedBox(height: 30),
                      Text(
            "En utilisant WiFi Mouni, vous acceptez cette politique de confidentialité. "
            "Cette politique peut être mise à jour afin d'améliorer la sécurité et les services proposés.",
            style: TextStyle(
              fontSize: 16,
            ),
            textAlign: TextAlign.justify,
          ),

          SizedBox(height: 20),

          Center(
            child: Text(
              "© 2026 WiFi Mouni\nTous droits réservés.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),

          SizedBox(height: 30),
        ],
      ),
    );
  }
}