import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/contact_model.dart';
import '../../services/contact_service.dart';

class AddContactPage extends StatefulWidget {
  const AddContactPage({super.key});

  @override
  State<AddContactPage> createState() =>
      _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  final ContactService _contactService =
      ContactService();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _phoneController =
      TextEditingController();

  final TextEditingController _idController =
      TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _idController.dispose();

    super.dispose();
  }

  // ----------------------------------------------------------
  // ENREGISTRER LE CONTACT
  // ----------------------------------------------------------

  Future<void> _save() async {
    if (_loading) return;

    final nom =
        _nameController.text.trim();

    final telephone =
        _phoneController.text.trim();

    final userId =
        _idController.text
            .trim()
            .toUpperCase();

    // Le nom et l'ID sont obligatoires.
    // Le téléphone est facultatif.
    if (nom.isEmpty || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Veuillez saisir le nom et l'ID WiFi Mouni.",
          ),
        ),
      );

      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      // ------------------------------------------------------
      // VÉRIFIER QUE L'ID EXISTE DANS FIRESTORE
      // ------------------------------------------------------

      final userQuery = await _firestore
          .collection("users")
          .where(
            "userId",
            isEqualTo: userId,
          )
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        throw Exception(
          "Cet ID WiFi Mouni n'existe pas.",
        );
      }

      final userData =
          userQuery.docs.first.data();

      // ------------------------------------------------------
      // RÉCUPÉRER LES INFORMATIONS DU COMPTE
      // ------------------------------------------------------

      final firebaseName =
          (userData["nom"] ?? "")
              .toString()
              .trim();

      final firebasePhone =
          (userData["telephone"] ?? "")
              .toString()
              .trim();

      final firebasePhoto =
          (userData["photoUrl"] ?? "")
              .toString()
              .trim();

      // Si le nom du compte existe,
      // on utilise celui enregistré dans Firebase.
      final finalName =
          firebaseName.isNotEmpty
              ? firebaseName
              : nom;

      // Le téléphone saisi est prioritaire.
      // Sinon, on récupère celui du compte
      // s'il existe.
      final finalPhone =
          telephone.isNotEmpty
              ? telephone
              : firebasePhone;

      // ------------------------------------------------------
      // VÉRIFIER SI LE CONTACT EXISTE DÉJÀ
      // ------------------------------------------------------

      final exists =
          await _contactService.contactExists(
        userId,
      );

      if (exists) {
        throw Exception(
          "Ce contact est déjà enregistré.",
        );
      }

      // ------------------------------------------------------
      // CRÉER LE CONTACT
      // ------------------------------------------------------

      final contact = ContactModel(
        id: "",
        nom: finalName,
        telephone: finalPhone,
        userId: userId,
        photoUrl: firebasePhoto.isEmpty
            ? null
            : firebasePhoto,
      );

      // ------------------------------------------------------
      // ENREGISTRER DANS FIRESTORE
      // ------------------------------------------------------

      await _contactService.addContact(
        contact,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Contact ajouté avec succès.",
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              "Exception: ",
              "",
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // ----------------------------------------------------------
  // INTERFACE
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: _loading
              ? null
              : () {
                  Navigator.pop(context);
                },
        ),
        title: const Text(
          "Ajouter un contact",
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ------------------------------------------------
            // NOM
            // ------------------------------------------------

            TextField(
              controller: _nameController,
              textCapitalization:
                  TextCapitalization.words,
              enabled: !_loading,
              decoration:
                  const InputDecoration(
                labelText: "Nom",
                hintText:
                    "Nom du contact",
                prefixIcon:
                    Icon(Icons.person),
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // ------------------------------------------------
            // TÉLÉPHONE
            // ------------------------------------------------

            TextField(
              controller: _phoneController,
              keyboardType:
                  TextInputType.phone,
              enabled: !_loading,
              decoration:
                  const InputDecoration(
                labelText:
                    "Téléphone (facultatif)",
                hintText:
                    "Vous pouvez laisser vide",
                prefixIcon:
                    Icon(Icons.phone),
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // ------------------------------------------------
            // ID WIFI MOUNI
            // ------------------------------------------------

            TextField(
              controller: _idController,
              textCapitalization:
                  TextCapitalization.characters,
              enabled: !_loading,
              decoration:
                  const InputDecoration(
                labelText:
                    "ID WiFi Mouni",
                hintText:
                    "Exemple : 53456473M",
                prefixIcon:
                    Icon(Icons.badge),
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            const Align(
              alignment:
                  Alignment.centerLeft,
              child: Text(
                "L'ID WiFi Mouni est obligatoire. "
                "Le numéro de téléphone est facultatif.",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ------------------------------------------------
            // BOUTON ENREGISTRER
            // ------------------------------------------------

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed:
                    _loading ? null : _save,
                icon: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.save,
                      ),
                label: Text(
                  _loading
                      ? "Enregistrement..."
                      : "Enregistrer",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}