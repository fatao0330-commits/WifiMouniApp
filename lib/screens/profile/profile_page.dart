import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../settings/settings_page.dart';
import '../auth/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<void> _copyId(String id) async {
    await Clipboard.setData(
      ClipboardData(text: id),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "ID copié avec succès.",
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await _auth.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>>
      _userStream() {
    return _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .snapshots();
  }
      @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil"),
        centerTitle: true,
      ),
      body: StreamBuilder<
          DocumentSnapshot<Map<String, dynamic>>>(
        stream: _userStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData ||
              !snapshot.data!.exists) {
            return const Center(
              child: Text(
                "Utilisateur introuvable.",
              ),
            );
          }

          final user = snapshot.data!.data()!;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 10),

              const CircleAvatar(
                radius: 55,
                child: Icon(
                  Icons.person,
                  size: 60,
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: Text(
                  user["nom"] ?? "",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 30),
                              Card(
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.badge),
                  title: const Text("ID WiFi Mouni"),
                  subtitle:
                      Text(user["userId"] ?? ""),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () => _copyId(
                      user["userId"] ?? "",
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Card(
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.phone),
                  title:
                      const Text("Téléphone"),
                  subtitle: Text(
                    user["telephone"] ?? "",
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Card(
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text("E-mail"),
                  subtitle:
                      Text(user["email"] ?? ""),
                ),
              ),

              const SizedBox(height: 30),
                              ElevatedButton.icon(
                icon: const Icon(Icons.settings),
                label: const Text("Paramètres"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(
                    double.infinity,
                    50,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const SettingsPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 15),

              OutlinedButton.icon(
                icon: const Icon(
                  Icons.logout,
                  color: Colors.red,
                ),
                label: const Text(
                  "Déconnexion",
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(
                    double.infinity,
                    50,
                  ),
                ),
                onPressed: _logout,
              ),

              const SizedBox(height: 20),
                            ],
          );
        },
      ),
    );
  }
}