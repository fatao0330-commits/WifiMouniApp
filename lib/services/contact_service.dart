import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/contact_model.dart';

class ContactService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  String? get _uid =>
      _auth.currentUser?.uid;

  // ==========================================================
  // RÉFÉRENCE DES CONTACTS
  // ==========================================================

  CollectionReference<
      Map<String, dynamic>> get _contactsRef {
    final uid = _uid;

    if (uid == null) {
      throw Exception(
        "Utilisateur non connecté.",
      );
    }

    return _firestore
        .collection("users")
        .doc(uid)
        .collection("contacts");
  }

  // ==========================================================
  // RÉCUPÉRER LES CONTACTS EN TEMPS RÉEL
  // ==========================================================

  Stream<List<ContactModel>>
      getContacts() {
    final uid = _uid;

    if (uid == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection("users")
        .doc(uid)
        .collection("contacts")
        .orderBy("nom")
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ContactModel.fromMap(
          doc.data(),
          doc.id,
        );
      }).toList();
    });
  }

  // ==========================================================
  // AJOUTER UN CONTACT
  // ==========================================================

  Future<void> addContact(
    ContactModel contact,
  ) async {
    if (contact.nom.trim().isEmpty) {
      throw Exception(
        "Le nom du contact est obligatoire.",
      );
    }

    if (contact.userId.trim().isEmpty) {
      throw Exception(
        "L'ID WiFi Mouni est obligatoire.",
      );
    }

    await _contactsRef.add(
      contact.toMap(),
    );
  }

  // ==========================================================
  // MODIFIER UN CONTACT
  // ==========================================================

  Future<void> updateContact(
    ContactModel contact,
  ) async {
    await _contactsRef
        .doc(contact.id)
        .update(
          contact.toMap(),
        );
  }

  // ==========================================================
  // SUPPRIMER UN CONTACT
  // ==========================================================

  Future<void> deleteContact(
    String contactId,
  ) async {
    await _contactsRef
        .doc(contactId)
        .delete();
  }

  // ==========================================================
  // SUPPRIMER TOUS LES CONTACTS
  // ==========================================================

  Future<void> deleteAllContacts()
      async {
    final snapshot =
        await _contactsRef.get();

    if (snapshot.docs.isEmpty) {
      return;
    }

    // Firestore limite un batch à 500 opérations.
    for (
      int i = 0;
      i < snapshot.docs.length;
      i += 500
    ) {
      final batch =
          _firestore.batch();

      final end =
          (i + 500 >
                  snapshot.docs.length)
              ? snapshot.docs.length
              : i + 500;

      final documents =
          snapshot.docs.sublist(
        i,
        end,
      );

      for (final doc in documents) {
        batch.delete(
          doc.reference,
        );
      }

      await batch.commit();
    }
  }

  // ==========================================================
  // VÉRIFIER SI LE CONTACT EXISTE DÉJÀ
  // ==========================================================

  Future<bool> contactExists(
    String userId,
  ) async {
    final result =
        await _contactsRef
            .where(
              "userId",
              isEqualTo:
                  userId.trim().toUpperCase(),
            )
            .limit(1)
            .get();

    return result.docs.isNotEmpty;
  }

  // ==========================================================
  // RÉCUPÉRER UN CONTACT
  // ==========================================================

  Future<ContactModel?> getContact(
    String contactId,
  ) async {
    final doc =
        await _contactsRef
            .doc(contactId)
            .get();

    if (!doc.exists) {
      return null;
    }

    final data = doc.data();

    if (data == null) {
      return null;
    }

    return ContactModel.fromMap(
      data,
      doc.id,
    );
  }

  // ==========================================================
  // RECHERCHER UN CONTACT PAR ID
  // ==========================================================

  Future<ContactModel?>
      getContactByUserId(
    String userId,
  ) async {
    final result =
        await _contactsRef
            .where(
              "userId",
              isEqualTo:
                  userId.trim().toUpperCase(),
            )
            .limit(1)
            .get();

    if (result.docs.isEmpty) {
      return null;
    }

    final doc =
        result.docs.first;

    return ContactModel.fromMap(
      doc.data(),
      doc.id,
    );
  }
}