import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("À propos"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [

          Icon(
            Icons.wifi,
            size: 80,
            color: Colors.blue,
          ),

          SizedBox(height: 20),

          Center(
            child: Text(
              "WiFi Mouni",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          SizedBox(height: 10),

          Center(
            child: Text(
              "Version 1.0.0",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ),

          SizedBox(height: 25),
                      Text(
            "WiFi Mouni est une application développée pour permettre "
            "aux utilisateurs d'acheter facilement des abonnements Internet, "
            "de gérer leur compte et d'effectuer des paiements en toute sécurité.",
            style: TextStyle(
              fontSize: 16,
            ),
            textAlign: TextAlign.justify,
          ),

          SizedBox(height: 25),

          Text(
            "Fonctionnalités principales",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 10),

          Text(
            "• Gestion du compte\n"
            "• Achat d'abonnements\n"
            "• Paiement pour soi ou un autre utilisateur\n"
            "• Gestion des contacts\n"
            "• Historique des opérations\n"
            "• QR Code et Scan QR\n"
            "• Support intégré",
            style: TextStyle(
              fontSize: 16,
            ),
          ),

          SizedBox(height: 25),
                      Text(
            "Développé avec",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 10),

          Text(
            "• Flutter\n"
            "• Firebase Authentication\n"
            "• Cloud Firestore\n"
            "• Firebase Storage",
            style: TextStyle(
              fontSize: 16,
            ),
          ),

          SizedBox(height: 25),

          Text(
            "Support officiel",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 10),

          SelectableText(
            "supportwifimouni@gmail.com",
            style: TextStyle(
              fontSize: 16,
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 30),
                      Center(
            child: Text(
              "Merci d'utiliser WiFi Mouni.",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          SizedBox(height: 20),

          Center(
            child: Text(
              "© 2026 WiFi Mouni\nTous droits réservés.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),

          SizedBox(height: 30),
        ],
      ),
    );
  }
}