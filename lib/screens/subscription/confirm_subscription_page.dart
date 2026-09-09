import 'package:flutter/material.dart';

import '../../services/purchase_service.dart';
import '../home/home_page.dart';
import '../security/pin_verification_page.dart';

class ConfirmSubscriptionPage
    extends StatefulWidget {
  final Map<String, dynamic> subscription;

  final Map<String, dynamic>? beneficiary;

  const ConfirmSubscriptionPage({
    super.key,
    required this.subscription,
    this.beneficiary,
  });

  @override
  State<ConfirmSubscriptionPage> createState() =>
      _ConfirmSubscriptionPageState();
}

class _ConfirmSubscriptionPageState
    extends State<ConfirmSubscriptionPage> {
  final PurchaseService _purchaseService =
      PurchaseService();

  bool _loading = false;

  // ==========================================================
  // CONFIRMER L'ACHAT
  // ==========================================================

  Future<void> _confirmPurchase() async {
    if (_loading) {
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final String? beneficiaryUid =
          widget.beneficiary?["uid"]
              ?.toString();

      final dynamic priceValue =
          widget.subscription["prix"];

      final dynamic durationValue =
          widget.subscription["duree"];

      final int price =
          priceValue is int
              ? priceValue
              : (priceValue as num).toInt();

      final int duration =
          durationValue is int
              ? durationValue
              : (durationValue as num).toInt();

      final result =
          await _purchaseService
              .buySubscription(
        subscriptionId:
            widget.subscription["id"]
                .toString(),

        subscriptionName:
            widget.subscription["nom"]
                .toString(),

        price: price,

        duration: duration,

        beneficiaryUid:
            beneficiaryUid,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
      });

      if (result != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(result),
            backgroundColor: Colors.red,
          ),
        );

        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Abonnement acheté avec succès.",
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const HomePage(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Erreur lors de l'achat : $e",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ==========================================================
  // OUVRIR LA VÉRIFICATION PIN
  // ==========================================================

  void _openPinVerification() {
    if (_loading) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PinVerificationPage(
          onSuccess: () async {
            await _confirmPurchase();
          },
        ),
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final subscription =
        widget.subscription;

    final bool isForOther =
        widget.beneficiary != null;

    final String beneficiaryName =
        widget.beneficiary?["nom"]
                ?.toString() ??
            "";

    final String beneficiaryId =
        widget.beneficiary?["userId"]
                ?.toString() ??
            "";

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Confirmation",
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // ==================================================
            // TITRE
            // ==================================================

            const Text(
              "Récapitulatif",
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // ABONNEMENT
            // ==================================================

            Card(
              child: ListTile(
                leading:
                    const Icon(
                  Icons.wifi,
                  color: Colors.blue,
                ),

                title: Text(
                  subscription["nom"]
                      ?.toString() ??
                      "",
                ),

                subtitle: Text(
                  subscription[
                              "description"]
                          ?.toString() ??
                      "",
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ==================================================
            // DURÉE
            // ==================================================

            Card(
              child: ListTile(
                leading:
                    const Icon(
                  Icons.schedule,
                ),

                title:
                    const Text(
                  "Durée",
                ),

                trailing: Text(
                  "${subscription["duree"]} jour(s)",
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ==================================================
            // PRIX
            // ==================================================

            Card(
              child: ListTile(
                leading:
                    const Icon(
                  Icons.payments,
                ),

                title:
                    const Text(
                  "Prix",
                ),

                trailing: Text(
                  "${subscription["prix"]} FCFA",

                  style:
                      const TextStyle(
                    color: Colors.green,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ==================================================
            // BÉNÉFICIAIRE
            // ==================================================

            Card(
              child: ListTile(
                leading:
                    const Icon(
                  Icons.person,
                ),

                title:
                    const Text(
                  "Bénéficiaire",
                ),

                subtitle: isForOther
                    ? Text(
                        "$beneficiaryName\n"
                        "ID : $beneficiaryId",
                      )
                    : const Text(
                        "Moi-même",
                      ),
              ),
            ),

            const Spacer(),

            // ==================================================
            // BOUTON CONFIRMER
            // ==================================================

            SizedBox(
              width:
                  double.infinity,

              height: 55,

              child:
                  ElevatedButton.icon(
                onPressed:
                    _loading
                        ? null
                        : _openPinVerification,

                icon: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color:
                              Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.lock,
                      ),

                label: Text(
                  _loading
                      ? "Traitement..."
                      : "Confirmer l'achat",

                  style:
                      const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
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
}