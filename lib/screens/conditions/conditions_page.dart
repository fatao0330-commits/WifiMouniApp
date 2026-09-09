import 'package:flutter/material.dart';

class ConditionsPage extends StatelessWidget {
  const ConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Conditions d'utilisation"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [

          Icon(
            Icons.description,
            size: 80,
            color: Colors.blue,
          ),

          SizedBox(height: 20),

          Center(
            child: Text(
              "Conditions d'utilisation",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          SizedBox(height: 20),

          Text(
            "Bienvenue sur WiFi Mouni. En utilisant cette application, vous acceptez les présentes conditions d'utilisation.",
            style: TextStyle(
              fontSize: 16,
            ),
            textAlign: TextAlign.justify,
          ),

          SizedBox(height: 20),
                      Text(
            "1. Création de compte",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 10),

          Text(
            "Chaque utilisateur est responsable des informations fournies lors de son inscription. "
            "Le compte est personnel et ne doit pas être partagé.",
            style: TextStyle(
              fontSize: 16,
            ),
            textAlign: TextAlign.justify,
          ),

          SizedBox(height: 20),

          Text(
            "2. Utilisation du service",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 10),

          Text(
            "Les abonnements achetés sont réservés à un usage conforme aux règles de WiFi Mouni. "
            "Toute utilisation frauduleuse peut entraîner la suspension ou la fermeture du compte.",
            style: TextStyle(
              fontSize: 16,
            ),
            textAlign: TextAlign.justify,
          ),

          SizedBox(height: 20),
                      Text(
            "3. Paiements",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 10),

          Text(
            "Les paiements effectués pour les abonnements sont enregistrés dans votre historique. "
            "Après validation du paiement, l'abonnement est activé selon sa durée de validité.",
            style: TextStyle(
              fontSize: 16,
            ),
            textAlign: TextAlign.justify,
          ),

          SizedBox(height: 20),

          Text(
            "4. Confidentialité",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 10),

          Text(
            "Vos informations personnelles sont protégées conformément à notre politique de confidentialité. "
            "WiFi Mouni ne vend pas vos données personnelles.",
            style: TextStyle(
              fontSize: 16,
            ),
            textAlign: TextAlign.justify,
          ),

          SizedBox(height: 20),
                      Text(
            "5. Modification des conditions",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 10),

          Text(
            "WiFi Mouni se réserve le droit de modifier les présentes conditions d'utilisation à tout moment. "
            "Les utilisateurs seront informés des changements importants via l'application.",
            style: TextStyle(
              fontSize: 16,
            ),
            textAlign: TextAlign.justify,
          ),

          SizedBox(height: 25),

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