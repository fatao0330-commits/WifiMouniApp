import 'package:flutter/material.dart';

import '../../models/payment_method_model.dart';
import '../../services/recharge_service.dart';

class ConfirmRechargePage extends StatefulWidget {
  final PaymentMethodModel paymentMethod;
  final int amount;

  const ConfirmRechargePage({
    super.key,
    required this.paymentMethod,
    required this.amount,
  });

  @override
  State<ConfirmRechargePage> createState() =>
      _ConfirmRechargePageState();
}

class _ConfirmRechargePageState
    extends State<ConfirmRechargePage> {
  final RechargeService _rechargeService =
      RechargeService();

  final TextEditingController _phoneController =
      TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  // ============================================================
  // ENVOYER LA DEMANDE
  // ============================================================

  Future<void> _confirmRecharge() async {
    if (_loading) return;

    final phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Veuillez saisir votre numéro de paiement.",
          ),
        ),
      );
      return;
    }

    if (widget.amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Montant de recharge invalide.",
          ),
        ),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final error = await _rechargeService.recharge(
        amount: widget.amount,
        paymentMethod: widget.paymentMethod.nom,
        phoneNumber: phone,
      );

      if (!mounted) return;

      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // ========================================================
      // DEMANDE ENREGISTRÉE
      // ========================================================

      await _showPaymentInstructions();

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Erreur : $e",
          ),
          backgroundColor: Colors.red,
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

  // ============================================================
  // AFFICHER LES INSTRUCTIONS DE PAIEMENT
  // ============================================================

  Future<void> _showPaymentInstructions() async {
    final String ussdCode =
        widget.paymentMethod.codeUssd.trim();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Demande envoyée",
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  "Votre demande de paiement a bien "
                  "été enregistrée.",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Pour terminer le paiement :",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  "1. Allez dans l'application Téléphone "
                  "de votre téléphone.",
                ),

                const SizedBox(height: 8),

                const Text(
                  "2. Composez le code suivant :",
                ),

                const SizedBox(height: 12),

                // ==================================================
                // CODE USSD
                // ==================================================

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius:
                        BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.shade200,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      ussdCode.isEmpty
                          ? "Code USSD non configuré"
                          : ussdCode,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  "3. Suivez les instructions affichées "
                  "par votre opérateur.",
                ),

                const SizedBox(height: 8),

                const Text(
                  "4. Validez le paiement avec votre "
                  "code secret Mobile Money.",
                ),

                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius:
                        BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.shade200,
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_amber,
                        color: Colors.orange,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Ne communiquez jamais votre "
                          "code secret Mobile Money "
                          "à WiFi Mouni.",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  "Votre recharge restera en attente "
                  "jusqu'à la confirmation réelle "
                  "du paiement.",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "J'ai compris",
              ),
            ),
          ],
        );
      },
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
          "Confirmation de recharge",
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            const Text(
              "Confirmer votre recharge",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // MOYEN DE PAIEMENT
            // ==================================================

            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Image.asset(
                    "assets/logos/"
                    "${widget.paymentMethod.logo}",
                    width: 38,
                    height: 38,
                    fit: BoxFit.contain,
                    errorBuilder:
                        (_, __, ___) {
                      return const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.blue,
                      );
                    },
                  ),
                ),

                title: const Text(
                  "Moyen de paiement",
                ),

                subtitle: Text(
                  widget.paymentMethod.nom,
                ),

                trailing: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ==================================================
            // MONTANT
            // ==================================================

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.payments,
                  color: Colors.green,
                ),

                title: const Text(
                  "Montant",
                ),

                trailing: Text(
                  "${_formatAmount(widget.amount)} FCFA",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // NUMÉRO
            // ==================================================

            const Text(
              "Numéro de paiement",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Votre numéro",
                hintText: "Ex : 0700000000",
                prefixIcon: const Icon(
                  Icons.phone,
                ),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              "Entrez le numéro associé à "
              "${widget.paymentMethod.nom}.",
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // INFORMATION
            // ==================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius:
                    BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.shade200,
                ),
              ),
              child: const Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Après l'envoi de la demande, "
                      "vous recevrez les instructions "
                      "pour effectuer la validation "
                      "USSD du paiement.",
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // ==================================================
            // BOUTON
            // ==================================================

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed:
                    _loading
                        ? null
                        : _confirmRecharge,

                icon: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.send,
                      ),

                label: Text(
                  _loading
                      ? "Enregistrement..."
                      : "Envoyer la demande",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // FORMATAGE DU MONTANT
  // ============================================================

  String _formatAmount(int amount) {
    final text = amount.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 &&
          (text.length - i) % 3 == 0) {
        buffer.write(' ');
      }

      buffer.write(text[i]);
    }

    return buffer.toString();
  }
}