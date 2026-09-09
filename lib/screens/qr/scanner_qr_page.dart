import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../services/qr_service.dart';
import '../subscription/buy_subscription_page.dart';

class ScannerQrPage extends StatefulWidget {
  const ScannerQrPage({super.key});

  @override
  State<ScannerQrPage> createState() => _ScannerQrPageState();
}

class _ScannerQrPageState extends State<ScannerQrPage> {
  final MobileScannerController _controller =
      MobileScannerController();

  final QrService _qrService = QrService();

  bool _alreadyScanned = false;
  bool _loading = false;

  Map<String, dynamic>? _beneficiary;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _processQrCode(String code) async {
    if (_alreadyScanned || _loading) return;

    final scannedId = code.trim().toUpperCase();

    if (scannedId.isEmpty) return;

    setState(() {
      _alreadyScanned = true;
      _loading = true;
    });

    await _controller.stop();

    try {
      final user = await _qrService.findUserById(scannedId);

      if (!mounted) return;

      setState(() {
        _loading = false;
        _beneficiary = user;
      });

      if (user == null) {
        _showError(
          "QR Code invalide.\nUtilisateur introuvable.",
        );

        setState(() {
          _alreadyScanned = false;
        });

        await _controller.start();
        return;
      }

      _showBeneficiary(user);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      _showError(
        "Impossible de vérifier le QR Code.",
      );

      setState(() {
        _alreadyScanned = false;
      });

      await _controller.start();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showBeneficiary(
    Map<String, dynamic> user,
  ) {
    final nom = user["nom"]?.toString() ?? "";
    final userId = user["userId"]?.toString() ?? "";

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),

              const SizedBox(height: 15),

              const Text(
                "Utilisateur trouvé",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              CircleAvatar(
                radius: 35,
                child: Text(
                  nom.isEmpty
                      ? "?"
                      : nom[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                nom,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                "ID : $userId",
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.wifi),
                  label: const Text(
                    "Acheter un abonnement",
                  ),
                  onPressed: () {
                    Navigator.pop(sheetContext);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            BuySubscriptionPage(
                          beneficiaryId: userId,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);

                    setState(() {
                      _alreadyScanned = false;
                      _beneficiary = null;
                    });

                    _controller.start();
                  },
                  child: const Text(
                    "Scanner un autre QR Code",
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Scanner un QR Code",
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) async {
              if (_alreadyScanned || _loading) {
                return;
              }

              final barcodes = capture.barcodes;

              if (barcodes.isEmpty) return;

              final code =
                  barcodes.first.rawValue;

              if (code == null ||
                  code.trim().isEmpty) {
                return;
              }

              await _processQrCode(code);
            },
          ),

          if (_loading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.white,
                    ),
                    SizedBox(height: 15),
                    Text(
                      "Vérification...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          Positioned(
            left: 30,
            right: 30,
            bottom: 40,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius:
                    BorderRadius.circular(15),
              ),
              child: const Text(
                "Placez le QR Code WiFi Mouni dans le cadre.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}