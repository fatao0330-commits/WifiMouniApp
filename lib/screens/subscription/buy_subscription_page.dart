import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/subscription_model.dart';
import '../../services/subscription_service.dart';
import 'confirm_subscription_page.dart';

class BuySubscriptionPage extends StatefulWidget {
  /// ID WiFi Mouni transmis par le scanner QR
  /// ou par la page Contact/Home.
  final String? beneficiaryId;

  /// Ancien nom utilisé par HomePage et ContactPage.
  ///
  /// On le conserve pour éviter de casser les pages
  /// déjà existantes.
  final String? initialReceiverId;

  const BuySubscriptionPage({
    super.key,
    this.beneficiaryId,
    this.initialReceiverId,
  });

  @override
  State<BuySubscriptionPage> createState() =>
      _BuySubscriptionPageState();
}

class _BuySubscriptionPageState
    extends State<BuySubscriptionPage> {
  final SubscriptionService _subscriptionService =
      SubscriptionService();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final TextEditingController _idController =
      TextEditingController();

  bool buyForMe = true;
  bool loadingUser = false;

  Map<String, dynamic>? beneficiary;

  String? beneficiaryUid;

  SubscriptionModel? selectedSubscription;

  String? get _initialBeneficiaryId {
    final id = widget.initialReceiverId ??
        widget.beneficiaryId;

    if (id == null || id.trim().isEmpty) {
      return null;
    }

    return id.trim().toUpperCase();
  }

  @override
  void initState() {
    super.initState();

    final initialId = _initialBeneficiaryId;

    if (initialId != null) {
      buyForMe = false;
      _idController.text = initialId;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _searchBeneficiary(initialId);
        }
      });
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  // ============================================================
  // RECHERCHER UN BÉNÉFICIAIRE
  // ============================================================

  Future<void> _searchBeneficiary(String value) async {
    final userId = value.trim().toUpperCase();

    if (userId.isEmpty) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      loadingUser = true;
      beneficiary = null;
      beneficiaryUid = null;
    });

    try {
      final result = await _firestore
          .collection("users")
          .where(
            "userId",
            isEqualTo: userId,
          )
          .limit(1)
          .get();

      if (!mounted) return;

      if (result.docs.isEmpty) {
        setState(() {
          loadingUser = false;
          beneficiary = null;
          beneficiaryUid = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Utilisateur introuvable.",
            ),
            backgroundColor: Colors.red,
          ),
        );

        return;
      }

      final document = result.docs.first;
      final data = document.data();
      final foundUid = document.id;

      final currentUser = _auth.currentUser;

      if (currentUser != null &&
          foundUid == currentUser.uid) {
        setState(() {
          loadingUser = false;
          beneficiary = null;
          beneficiaryUid = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Cet ID correspond à votre propre compte. "
              "Sélectionnez « Moi-même ».",
            ),
          ),
        );

        return;
      }

      final beneficiaryData =
          Map<String, dynamic>.from(data);

      beneficiaryData["uid"] = foundUid;

      setState(() {
        loadingUser = false;
        beneficiary = beneficiaryData;
        beneficiaryUid = foundUid;
        _idController.text = userId;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingUser = false;
        beneficiary = null;
        beneficiaryUid = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Erreur lors de la recherche : $e",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // ACHETER POUR MOI
  // ============================================================

  void _selectBuyForMe() {
    setState(() {
      buyForMe = true;
      beneficiary = null;
      beneficiaryUid = null;
      _idController.clear();
    });
  }

  // ============================================================
  // ACHETER POUR AUTRE PERSONNE
  // ============================================================

  void _selectBuyForOther() {
    setState(() {
      buyForMe = false;
      beneficiary = null;
      beneficiaryUid = null;
    });
  }

  // ============================================================
  // CONTINUER
  // ============================================================

  void _continuePurchase() {
    if (!buyForMe) {
      if (beneficiary == null ||
          beneficiaryUid == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Veuillez sélectionner un bénéficiaire.",
            ),
          ),
        );

        return;
      }
    }

    if (selectedSubscription == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Veuillez choisir un abonnement.",
          ),
        ),
      );

      return;
    }

    final subscription =
        selectedSubscription!;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ConfirmSubscriptionPage(
          subscription: {
            "id": subscription.id,
            "nom": subscription.nom,
            "description":
                subscription.description,
            "prix": subscription.prix,
            "duree": subscription.duree,
          },
          beneficiary:
              buyForMe
                  ? null
                  : beneficiary,
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Acheter un abonnement",
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<SubscriptionModel>>(
        stream: _subscriptionService
            .getSubscriptions(),
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
                padding:
                    const EdgeInsets.all(20),
                child: Text(
                  "Erreur lors du chargement "
                  "des abonnements.\n\n"
                  "${snapshot.error}",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final subscriptions =
              snapshot.data ?? [];

          return SingleChildScrollView(
            padding:
                const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  "Acheter pour",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                Card(
                  child: RadioListTile<bool>(
                    value: true,
                    groupValue: buyForMe,
                    title: const Text(
                      "Moi-même",
                    ),
                    secondary: const Icon(
                      Icons.person,
                    ),
                    onChanged: (_) =>
                        _selectBuyForMe(),
                  ),
                ),

                Card(
                  child: RadioListTile<bool>(
                    value: false,
                    groupValue: buyForMe,
                    title: const Text(
                      "Une autre personne",
                    ),
                    secondary: const Icon(
                      Icons.people,
                    ),
                    onChanged: (_) =>
                        _selectBuyForOther(),
                  ),
                ),

                if (!buyForMe) ...[
                  const SizedBox(height: 20),

                  const Text(
                    "Bénéficiaire",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller:
                        _idController,
                    textCapitalization:
                        TextCapitalization
                            .characters,
                    decoration:
                        InputDecoration(
                      labelText:
                          "ID WiFi Mouni",
                      hintText:
                          "Ex : 53456473M",
                      prefixIcon:
                          const Icon(
                        Icons.badge,
                      ),
                      suffixIcon:
                          IconButton(
                        icon: loadingUser
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.search,
                              ),
                        onPressed:
                            loadingUser
                                ? null
                                : () =>
                                    _searchBeneficiary(
                                      _idController
                                          .text,
                                    ),
                      ),
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(12),
                      ),
                    ),
                    onSubmitted:
                        _searchBeneficiary,
                  ),

                  const SizedBox(height: 15),

                  if (beneficiary != null)
                    Card(
                      elevation: 3,
                      color: Colors.green
                          .withOpacity(0.08),
                      child: ListTile(
                        leading:
                            const CircleAvatar(
                          child: Icon(
                            Icons.person,
                          ),
                        ),
                        title: Text(
                          (beneficiary![
                                      "nom"] ??
                                  "")
                              .toString(),
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          "ID : "
                          "${(beneficiary!["userId"] ?? "").toString()}",
                        ),
                        trailing:
                            const Icon(
                          Icons.check_circle,
                          color:
                              Colors.green,
                        ),
                      ),
                    ),
                ],

                const SizedBox(height: 25),

                const Text(
                  "Choisir un abonnement",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                if (subscriptions.isEmpty)
                  const Card(
                    child: Padding(
                      padding:
                          EdgeInsets.all(20),
                      child: Center(
                        child: Text(
                          "Aucun abonnement "
                          "disponible pour le moment.",
                          textAlign:
                              TextAlign.center,
                        ),
                      ),
                    ),
                  ),

                ...subscriptions.map(
                  (subscription) {
                    final isSelected =
                        selectedSubscription
                                ?.id ==
                            subscription.id;

                    return Card(
                      margin:
                          const EdgeInsets
                              .only(
                        bottom: 12,
                      ),
                      elevation:
                          isSelected ? 4 : 1,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(14),
                        side: BorderSide(
                          color: isSelected
                              ? Colors.green
                              : Colors.grey
                                  .shade300,
                          width: isSelected
                              ? 2
                              : 1,
                        ),
                      ),
                      child: InkWell(
                        borderRadius:
                            BorderRadius
                                .circular(14),
                        onTap: () {
                          setState(() {
                            selectedSubscription =
                                subscription;
                          });
                        },
                        child: Padding(
                          padding:
                              const EdgeInsets
                                  .all(15),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundColor:
                                    Colors.blue
                                        .withOpacity(
                                  0.12,
                                ),
                                child:
                                    const Icon(
                                  Icons.wifi,
                                  color:
                                      Colors.blue,
                                ),
                              ),

                              const SizedBox(
                                width: 15,
                              ),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Text(
                                      subscription
                                          .nom,
                                      style:
                                          const TextStyle(
                                        fontSize:
                                            17,
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),

                                    if (subscription
                                        .description
                                        .isNotEmpty)
                                      Padding(
                                        padding:
                                            const EdgeInsets
                                                .only(
                                          top: 5,
                                        ),
                                        child:
                                            Text(
                                          subscription
                                              .description,
                                        ),
                                      ),

                                    const SizedBox(
                                      height: 7,
                                    ),

                                    Text(
                                      "Durée : "
                                      "${subscription.duree} jour(s)",
                                    ),

                                    const SizedBox(
                                      height: 3,
                                    ),

                                    Text(
                                      "${subscription.prix} FCFA",
                                      style:
                                          const TextStyle(
                                        color:
                                            Colors.blue,
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(
                                width: 10,
                              ),

                              isSelected
                                  ? const Icon(
                                      Icons
                                          .check_circle,
                                      color:
                                          Colors.green,
                                      size: 30,
                                    )
                                  : const Icon(
                                      Icons
                                          .radio_button_unchecked,
                                      color:
                                          Colors.grey,
                                    ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child:
                      ElevatedButton.icon(
                    onPressed:
                        _continuePurchase,
                    icon: const Icon(
                      Icons.arrow_forward,
                    ),
                    label: const Text(
                      "Continuer",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}