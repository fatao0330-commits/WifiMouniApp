import 'package:flutter/material.dart';

import '../../models/payment_method_model.dart';
import '../../models/subscription_model.dart';
import '../../services/payment_method_service.dart';
import '../../services/subscription_service.dart';

import 'confirm_recharge_page.dart';

class RechargePage extends StatefulWidget {
  const RechargePage({super.key});

  @override
  State<RechargePage> createState() => _RechargePageState();
}

class _RechargePageState extends State<RechargePage> {
  final PaymentMethodService _paymentMethodService =
      PaymentMethodService();

  final SubscriptionService _subscriptionService =
      SubscriptionService();

  final TextEditingController _amountController =
      TextEditingController();

  PaymentMethodModel? _selectedMethod;
  int? _selectedAmount;

  // ============================================================
  // INITIALISATION
  // ============================================================

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // ============================================================
  // SÉLECTION DU MOYEN DE PAIEMENT
  // ============================================================

  void _selectPaymentMethod(
    PaymentMethodModel method,
  ) {
    setState(() {
      _selectedMethod = method;
    });
  }

  // ============================================================
  // SÉLECTION D'UN MONTANT PROPOSÉ
  // ============================================================

  void _selectAmount(int amount) {
    setState(() {
      _selectedAmount = amount;
      _amountController.text = amount.toString();
      _amountController.selection =
          TextSelection.fromPosition(
        TextPosition(
          offset: _amountController.text.length,
        ),
      );
    });
  }

  // ============================================================
  // MONTANT SAISI MANUELLEMENT
  // ============================================================

  void _onAmountChanged(String value) {
    final amount = int.tryParse(value.trim());

    setState(() {
      _selectedAmount = amount;
    });
  }

  // ============================================================
  // CONTINUER
  // ============================================================

  void _continue() {
    // ----------------------------------------------------------
    // MOYEN DE PAIEMENT
    // ----------------------------------------------------------

    if (_selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Veuillez choisir un moyen de paiement.",
          ),
        ),
      );
      return;
    }

    // ----------------------------------------------------------
    // MONTANT
    // ----------------------------------------------------------

    final amount = int.tryParse(
      _amountController.text.trim(),
    );

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Veuillez saisir un montant valide.",
          ),
        ),
      );
      return;
    }

    // ----------------------------------------------------------
    // OUVRIR LA CONFIRMATION
    // ----------------------------------------------------------

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConfirmRechargePage(
          paymentMethod: _selectedMethod!,
          amount: amount,
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
          "Recharger le portefeuille",
        ),
        centerTitle: true,
      ),

      body: StreamBuilder<List<PaymentMethodModel>>(
        stream:
            _paymentMethodService.getPaymentMethods(),

        builder: (
          context,
          paymentSnapshot,
        ) {
          // ==================================================
          // CHARGEMENT MOYENS DE PAIEMENT
          // ==================================================

          if (paymentSnapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (paymentSnapshot.hasError) {
            return _buildError(
              "Erreur de chargement des moyens de paiement.",
            );
          }

          final methods =
              paymentSnapshot.data ?? [];

          return StreamBuilder<List<SubscriptionModel>>(
            stream:
                _subscriptionService
                    .getSubscriptions(),

            builder: (
              context,
              subscriptionSnapshot,
            ) {
              // ==================================================
              // CHARGEMENT ABONNEMENTS
              // ==================================================

              if (subscriptionSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (subscriptionSnapshot.hasError) {
                return _buildError(
                  "Erreur de chargement des abonnements.",
                );
              }

              final subscriptions =
                  subscriptionSnapshot.data ?? [];

              // ==================================================
              // RÉCUPÉRER LES PRIX DES ABONNEMENTS
              // ==================================================

              final List<int> amounts = subscriptions
                  .map(
                    (subscription) =>
                        subscription.prix,
                  )
                  .where(
                    (price) => price > 0,
                  )
                  .toSet()
                  .toList()
                ..sort();

              return ListView(
                padding:
                    const EdgeInsets.all(20),

                children: [

                  // ==================================================
                  // MOYENS DE PAIEMENT
                  // ==================================================

                  const Text(
                    "Moyen de paiement",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Choisissez le moyen avec lequel "
                    "vous souhaitez effectuer la recharge.",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 18),

                  if (methods.isEmpty)
                    _buildEmptyCard(
                      "Aucun moyen de paiement disponible "
                      "pour le moment.",
                    ),

                  // ==================================================
                  // AFFICHER TOUS LES MOYENS FIRESTORE
                  // ==================================================

                  ...methods.map(
                    (method) {
                      final selected =
                          _selectedMethod?.id ==
                              method.id;

                      return Card(
                        margin:
                            const EdgeInsets.only(
                          bottom: 12,
                        ),

                        elevation:
                            selected ? 4 : 1,

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            14,
                          ),
                          side:
                              BorderSide(
                            color: selected
                                ? Colors.green
                                : Colors.grey
                                    .shade300,
                            width:
                                selected ? 2 : 1,
                          ),
                        ),

                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(
                            14,
                          ),

                          onTap: () {
                            _selectPaymentMethod(
                              method,
                            );
                          },

                          child: Padding(
                            padding:
                                const EdgeInsets.all(
                              12,
                            ),

                            child: Row(
                              children: [

                                // LOGO
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor:
                                      Colors.white,

                                  child: ClipRRect(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      30,
                                    ),

                                    child:
                                        Image.asset(
                                      "assets/logos/${method.logo}",

                                      width: 42,
                                      height: 42,

                                      fit: BoxFit
                                          .contain,

                                      errorBuilder:
                                          (
                                        _,
                                        __,
                                        ___,
                                      ) {
                                        return const Icon(
                                          Icons
                                              .account_balance_wallet,
                                          color:
                                              Colors.blue,
                                          size: 30,
                                        );
                                      },
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  width: 14,
                                ),

                                // NOM + PAYS
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,

                                    children: [
                                      Text(
                                        method.nom,
                                        style:
                                            const TextStyle(
                                          fontSize:
                                              16,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                      ),

                                      const SizedBox(
                                        height: 4,
                                      ),

                                      Text(
                                        method.pays,
                                        style:
                                            const TextStyle(
                                          color:
                                              Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // SÉLECTION
                                if (selected)
                                  const Icon(
                                    Icons
                                        .check_circle,
                                    color:
                                        Colors.green,
                                    size: 28,
                                  )
                                else
                                  const Icon(
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

                  const SizedBox(height: 20),

                  // ==================================================
                  // MONTANT
                  // ==================================================

                  const Text(
                    "Montant de la recharge",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Les montants proposés correspondent "
                    "aux prix des abonnements disponibles. "
                    "Vous pouvez également saisir un montant libre.",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ==================================================
                  // MONTANTS DES ABONNEMENTS
                  // ==================================================

                  if (amounts.isEmpty)
                    _buildEmptyCard(
                      "Aucun prix d'abonnement disponible "
                      "pour le moment.",
                    ),

                  if (amounts.isNotEmpty)
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,

                      children:
                          amounts.map(
                        (amount) {
                          final selected =
                              _selectedAmount ==
                                  amount;

                          return ChoiceChip(
                            selected:
                                selected,

                            label: Text(
                              "${_formatAmount(amount)} FCFA",

                              style:
                                  TextStyle(
                                fontWeight:
                                    FontWeight
                                        .bold,

                                color: selected
                                    ? Colors.white
                                    : null,
                              ),
                            ),

                            onSelected:
                                (_) {
                              _selectAmount(
                                amount,
                              );
                            },
                          );
                        },
                      ).toList(),
                    ),

                  const SizedBox(height: 22),

                  // ==================================================
                  // CHAMP DE MONTANT LIBRE
                  // ==================================================

                  TextField(
                    controller:
                        _amountController,

                    keyboardType:
                        TextInputType.number,

                    inputFormatters: const [],

                    decoration:
                        InputDecoration(
                      labelText:
                          "Montant à recharger",

                      hintText:
                          "Ex : 3000",

                      prefixIcon:
                          const Icon(
                        Icons.payments,
                      ),

                      suffixText:
                          "FCFA",

                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),
                      ),
                    ),

                    onChanged:
                        _onAmountChanged,
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Vous pouvez saisir le montant de votre choix.",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ==================================================
                  // RÉCAPITULATIF
                  // ==================================================

                  if (_selectedMethod != null &&
                      _selectedAmount != null &&
                      _selectedAmount! > 0)
                    Card(
                      elevation: 2,

                      child: Padding(
                        padding:
                            const EdgeInsets.all(
                          16,
                        ),

                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            const Text(
                              "Récapitulatif",
                              style:
                                  TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),

                            const SizedBox(
                              height: 15,
                            ),

                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,

                              children: [
                                const Text(
                                  "Moyen de paiement",
                                ),

                                Flexible(
                                  child: Text(
                                    _selectedMethod!
                                        .nom,

                                    textAlign:
                                        TextAlign
                                            .right,

                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 10,
                            ),

                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,

                              children: [
                                const Text(
                                  "Montant",
                                ),

                                Text(
                                  "${_formatAmount(_selectedAmount!)} FCFA",

                                  style:
                                      const TextStyle(
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                    color:
                                        Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 25),

                  // ==================================================
                  // CONTINUER
                  // ==================================================

                  SizedBox(
                    width:
                        double.infinity,

                    height: 55,

                    child:
                        ElevatedButton.icon(
                      onPressed:
                          _continue,

                      icon:
                          const Icon(
                        Icons.arrow_forward,
                      ),

                      label:
                          const Text(
                        "Continuer",

                        style:
                            TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 30,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // ============================================================
  // CARTE ERREUR
  // ============================================================

  Widget _buildError(
    String message,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(20),

        child: Text(
          message,
          textAlign:
              TextAlign.center,
        ),
      ),
    );
  }

  // ============================================================
  // CARTE VIDE
  // ============================================================

  Widget _buildEmptyCard(
    String message,
  ) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(18),

        child: Center(
          child: Text(
            message,

            textAlign:
                TextAlign.center,

            style:
                const TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FORMATAGE
  // Exemple : 1000 -> 1 000
  // ============================================================

  String _formatAmount(
    int amount,
  ) {
    final text =
        amount.toString();

    final buffer =
        StringBuffer();

    for (
      int i = 0;
      i < text.length;
      i++
    ) {
      if (
        i > 0 &&
        (text.length - i) % 3 == 0
      ) {
        buffer.write(' ');
      }

      buffer.write(
        text[i],
      );
    }

    return buffer.toString();
  }
}