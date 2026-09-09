import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../security/pin_verification_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final TextEditingController _searchController =
      TextEditingController();

  String _searchText = "";

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _searchText =
            _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _historyStream() {
    final user = _auth.currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection("users")
        .doc(user.uid)
        .collection("history")
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  bool _matchesSearch(
    Map<String, dynamic> data,
  ) {
    if (_searchText.isEmpty) {
      return true;
    }

    final titre =
        (data["titre"] ?? "").toString().toLowerCase();

    final description =
        (data["description"] ?? "")
            .toString()
            .toLowerCase();

    final type =
        (data["type"] ?? "").toString().toLowerCase();

    final statut =
        (data["statut"] ?? "").toString().toLowerCase();

    final montant =
        (data["montant"] ?? "").toString().toLowerCase();

    return titre.contains(_searchText) ||
        description.contains(_searchText) ||
        type.contains(_searchText) ||
        statut.contains(_searchText) ||
        montant.contains(_searchText);
  }

  String _formatDate(dynamic value) {
    if (value == null) {
      return "Date inconnue";
    }

    DateTime? date;

    if (value is Timestamp) {
      date = value.toDate();
    } else if (value is DateTime) {
      date = value;
    }

    if (date == null) {
      return "Date inconnue";
    }

    final day =
        date.day.toString().padLeft(2, "0");

    final month =
        date.month.toString().padLeft(2, "0");

    final year =
        date.year.toString();

    final hour =
        date.hour.toString().padLeft(2, "0");

    final minute =
        date.minute.toString().padLeft(2, "0");

    return "$day/$month/$year à $hour:$minute";
  }

  IconData _getHistoryIcon(
    Map<String, dynamic> data,
  ) {
    final type =
        (data["type"] ?? "")
            .toString()
            .toLowerCase();

    if (type == "subscription") {
      return Icons.wifi;
    }

    if (type == "recharge") {
      return Icons.account_balance_wallet;
    }

    if (type == "payment") {
      return Icons.payments;
    }

    return Icons.receipt_long;
  }

  Color _getHistoryColor(
    Map<String, dynamic> data,
  ) {
    final type =
        (data["type"] ?? "")
            .toString()
            .toLowerCase();

    final statut =
        (data["statut"] ?? "")
            .toString()
            .toLowerCase();

    if (statut == "success" ||
        statut == "successful") {
      if (type == "recharge") {
        return Colors.green;
      }

      if (type == "subscription") {
        return Colors.blue;
      }

      return Colors.green;
    }

    if (statut == "failed" ||
        statut == "error") {
      return Colors.red;
    }

    if (statut == "pending") {
      return Colors.orange;
    }

    return Colors.grey;
  }

  String _getStatusText(
    Map<String, dynamic> data,
  ) {
    final statut =
        (data["statut"] ?? "")
            .toString()
            .toLowerCase();

    switch (statut) {
      case "success":
      case "successful":
        return "Réussi";

      case "failed":
      case "error":
        return "Échec";

      case "pending":
        return "En attente";

      default:
        return statut.isEmpty
            ? "Inconnu"
            : statut;
    }
  }

  // ============================================================
  // MASQUER UNE TRANSACTION
  // ============================================================

  Future<void> _requestHideHistory(
    String documentId,
  ) async {
    final user = _auth.currentUser;

    if (user == null) {
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PinVerificationPage(
          onSuccess: () async {
            try {
              await _firestore
                  .collection("users")
                  .doc(user.uid)
                  .collection("history")
                  .doc(documentId)
                  .update({
                "hidden": true,
                "hiddenAt":
                    FieldValue.serverTimestamp(),
              });

              if (!mounted) return;

              ScaffoldMessenger.of(context)
                  .showSnackBar(
                const SnackBar(
                  content: Text(
                    "Transaction masquée.",
                  ),
                  backgroundColor:
                      Colors.green,
                ),
              );
            } catch (e) {
              if (!mounted) return;

              ScaffoldMessenger.of(context)
                  .showSnackBar(
                const SnackBar(
                  content: Text(
                    "Impossible de masquer cette transaction.",
                  ),
                  backgroundColor:
                      Colors.red,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  // ============================================================
  // DÉTAILS
  // ============================================================

  void _showHistoryDetails(
    String documentId,
    Map<String, dynamic> data,
  ) {
    final titre =
        (data["titre"] ?? "Transaction")
            .toString();

    final description =
        (data["description"] ?? "")
            .toString();

    final montant =
        data["montant"] ?? 0;

    final statut =
        _getStatusText(data);

    final date =
        _formatDate(data["createdAt"]);

    final beneficiaryUid =
        data["beneficiaryUid"];

    final buyerUid =
        data["buyerUid"];

    final subscriptionName =
        data["subscriptionName"];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              5,
              20,
              30,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Détails de la transaction",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  ListTile(
                    leading: const Icon(
                      Icons.receipt_long,
                    ),
                    title: const Text(
                      "Transaction",
                    ),
                    subtitle: Text(titre),
                  ),

                  if (subscriptionName != null)
                    ListTile(
                      leading: const Icon(
                        Icons.wifi,
                      ),
                      title: const Text(
                        "Abonnement",
                      ),
                      subtitle: Text(
                        subscriptionName
                            .toString(),
                      ),
                    ),

                  ListTile(
                    leading: const Icon(
                      Icons.payments,
                    ),
                    title: const Text(
                      "Montant",
                    ),
                    subtitle: Text(
                      "$montant FCFA",
                    ),
                  ),

                  ListTile(
                    leading: Icon(
                      statut == "Réussi"
                          ? Icons.check_circle
                          : Icons.info,
                      color:
                          statut == "Réussi"
                              ? Colors.green
                              : Colors.orange,
                    ),
                    title: const Text(
                      "Statut",
                    ),
                    subtitle: Text(statut),
                  ),

                  ListTile(
                    leading: const Icon(
                      Icons.calendar_today,
                    ),
                    title: const Text(
                      "Date",
                    ),
                    subtitle: Text(date),
                  ),

                  if (beneficiaryUid != null)
                    ListTile(
                      leading: const Icon(
                        Icons.person,
                      ),
                      title: const Text(
                        "Bénéficiaire",
                      ),
                      subtitle: Text(
                        beneficiaryUid
                            .toString(),
                      ),
                    ),

                  if (buyerUid != null)
                    ListTile(
                      leading: const Icon(
                        Icons.account_circle,
                      ),
                      title: const Text(
                        "Acheteur",
                      ),
                      subtitle: Text(
                        buyerUid.toString(),
                      ),
                    ),

                  if (description.isNotEmpty)
                    Card(
                      child: Padding(
                        padding:
                            const EdgeInsets.all(
                          15,
                        ),
                        child: Text(
                          description,
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      icon: const Icon(
                        Icons.visibility_off,
                      ),
                      label: const Text(
                        "Masquer de l'affichage",
                      ),
                      onPressed: () {
                        Navigator.pop(
                          sheetContext,
                        );

                        _requestHideHistory(
                          documentId,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // ÉLÉMENT HISTORIQUE
  // ============================================================

  Widget _buildHistoryItem(
    String documentId,
    Map<String, dynamic> data,
  ) {
    final color =
        _getHistoryColor(data);

    final icon =
        _getHistoryIcon(data);

    final titre =
        (data["titre"] ?? "Transaction")
            .toString();

    final description =
        (data["description"] ?? "")
            .toString();

    final montant =
        data["montant"] ?? 0;

    final date =
        _formatDate(data["createdAt"]);

    final status =
        _getStatusText(data);

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      elevation: 1,
      child: InkWell(
        borderRadius:
            BorderRadius.circular(12),
        onTap: () {
          _showHistoryDetails(
            documentId,
            data,
          );
        },
        child: Padding(
          padding:
              const EdgeInsets.all(15),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor:
                    color.withOpacity(0.12),
                child: Icon(
                  icon,
                  color: color,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      titre,
                      style:
                          const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    if (description.isNotEmpty)
                      Padding(
                        padding:
                            const EdgeInsets.only(
                          top: 5,
                        ),
                        child: Text(
                          description,
                          maxLines: 2,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              TextStyle(
                            color:
                                Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ),

                    const SizedBox(height: 7),

                    Text(
                      date,
                      style:
                          TextStyle(
                        color:
                            Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Row(
                      children: [
                        Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration:
                              BoxDecoration(
                            color: color
                                .withOpacity(
                              0.12,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              8,
                            ),
                          ),
                          child: Text(
                            status,
                            style:
                                TextStyle(
                              color: color,
                              fontSize: 12,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),

                        const Spacer(),

                        Text(
                          "$montant FCFA",
                          style:
                              TextStyle(
                            color: color,
                            fontSize: 15,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 5),

              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Historique",
        ),
        centerTitle: true,
      ),

      body: user == null
          ? const Center(
              child: Text(
                "Vous devez être connecté.",
              ),
            )
          : Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    20,
                    15,
                    20,
                    10,
                  ),
                  child: TextField(
                    controller:
                        _searchController,
                    decoration:
                        InputDecoration(
                      hintText:
                          "Rechercher dans l'historique...",
                      prefixIcon:
                          const Icon(
                        Icons.search,
                      ),
                      suffixIcon:
                          _searchText.isNotEmpty
                              ? IconButton(
                                  icon:
                                      const Icon(
                                    Icons.clear,
                                  ),
                                  onPressed: () {
                                    _searchController
                                        .clear();
                                  },
                                )
                              : null,
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child:
                      StreamBuilder<
                          QuerySnapshot<
                              Map<String,
                                  dynamic>>>(
                    stream:
                        _historyStream(),
                    builder:
                        (context, snapshot) {
                      if (snapshot
                              .connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child:
                              CircularProgressIndicator(),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding:
                                const EdgeInsets
                                    .all(
                              20,
                            ),
                            child: Text(
                              "Erreur lors du chargement de l'historique.\n\n"
                              "${snapshot.error}",
                              textAlign:
                                  TextAlign.center,
                            ),
                          ),
                        );
                      }

                      if (!snapshot.hasData ||
                          snapshot
                              .data!
                              .docs
                              .isEmpty) {
                        return const Center(
                          child: Padding(
                            padding:
                                EdgeInsets.all(
                              30,
                            ),
                            child: Column(
                              mainAxisSize:
                                  MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.history,
                                  size: 70,
                                  color:
                                      Colors.grey,
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  "Aucune activité",
                                  style:
                                      TextStyle(
                                    fontSize:
                                        20,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  "Vos achats et transactions apparaîtront ici.",
                                  textAlign:
                                      TextAlign.center,
                                  style:
                                      TextStyle(
                                    color:
                                        Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // ------------------------------------------
                      // EXCLURE LES TRANSACTIONS MASQUÉES
                      // ------------------------------------------

                      final documents =
                          snapshot.data!.docs
                              .where((doc) {
                        final data =
                            doc.data();

                        final hidden =
                            data["hidden"] ==
                                true;

                        if (hidden) {
                          return false;
                        }

                        return _matchesSearch(
                          data,
                        );
                      }).toList();

                      if (documents.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding:
                                EdgeInsets.all(
                              30,
                            ),
                            child: Column(
                              mainAxisSize:
                                  MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 60,
                                  color:
                                      Colors.grey,
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  "Aucun résultat",
                                  style:
                                      TextStyle(
                                    fontSize:
                                        19,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  "Aucune transaction visible ne correspond à votre recherche.",
                                  textAlign:
                                      TextAlign.center,
                                  style:
                                      TextStyle(
                                    color:
                                        Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding:
                            const EdgeInsets
                                .fromLTRB(
                          20,
                          10,
                          20,
                          30,
                        ),
                        itemCount:
                            documents.length,
                        itemBuilder:
                            (context, index) {
                          final document =
                              documents[index];

                          return _buildHistoryItem(
                            document.id,
                            document.data(),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}