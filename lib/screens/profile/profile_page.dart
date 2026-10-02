import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../settings/settings_page.dart';

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

  Stream<DocumentSnapshot<Map<String, dynamic>>>
      _userStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.error(StateError('User session unavailable'));
    }
    return _firestore
        .collection("users")
        .doc(user.uid)
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

            if (snapshot.hasError ||
              !snapshot.hasData ||
              !snapshot.data!.exists ||
              snapshot.data!.data() == null) {
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
                  user["nom"]?.toString() ?? "",
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
                      Text(user["userId"]?.toString() ?? ""),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () => _copyId(
                      user["userId"]?.toString() ?? "",
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
                    user["telephone"]?.toString() ?? "",
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
                      Text(user["email"]?.toString() ?? ""),
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

              const SizedBox(height: 20),
                            ],
          );
        },
      ),
    );
  }
}