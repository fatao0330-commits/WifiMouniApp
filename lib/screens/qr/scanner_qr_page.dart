import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../l10n/app_localizations.dart';
import '../../services/qr_service.dart';
import '../subscription/buy_subscription_page.dart';

class ScannerQrPage extends StatefulWidget {
  const ScannerQrPage({super.key});

  @override
  State<ScannerQrPage> createState() => _ScannerQrPageState();
}

class _ScannerQrPageState extends State<ScannerQrPage> {
  final MobileScannerController _controller =
  MobileScannerController(autoStart: false);

  final QrService _qrService = QrService();

  bool _alreadyScanned = false;
  bool _loading = false;
  String? _cameraError;

  Map<String, dynamic>? _beneficiary;

  @override
  void initState() {
    super.initState();
    _startScanner();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _processQrCode(String code) async {
    if (!mounted || _alreadyScanned || _loading) return;

    final scannedId = code.trim().toUpperCase();

    if (scannedId.isEmpty) return;

    setState(() {
      _alreadyScanned = true;
      _loading = true;
    });

    try {
      await _controller.stop();
      final user = await _qrService.findUserById(scannedId);

      if (!mounted) return;

      setState(() {
        _loading = false;
        _beneficiary = user;
      });

      if (user == null) {
        _showError(
          '${AppLocalizations.of(context).invalidQrCode}\n${AppLocalizations.of(context).qrUserNotFound}',
        );
        await _resumeScanner();
        return;
      }

      await _showBeneficiary(user);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      _showError(
        AppLocalizations.of(context).qrLookupFailed,
      );
      await _resumeScanner();
    }
  }

  Future<void> _startScanner() async {
    if (!mounted) return;
    try {
      await _controller.start();
      if (!mounted) return;
      setState(() => _cameraError = null);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _cameraError = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _resumeScanner() async {
    if (!mounted) return;
    setState(() {
      _alreadyScanned = false;
      _beneficiary = null;
      _loading = false;
    });
    await _startScanner();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _showBeneficiary(
    Map<String, dynamic> user,
  ) async {
    final nom = user["nom"]?.toString() ?? "";
    final userId = user["userId"]?.toString() ?? "";

    final scanAgain = await showModalBottomSheet<bool>(
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

              Text(
                AppLocalizations.of(sheetContext).qrUserFound,
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
                  label: Text(
                    AppLocalizations.of(sheetContext).buySubscription,
                  ),
                  onPressed: () async {
                    Navigator.pop(sheetContext, false);

                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            BuySubscriptionPage(
                          beneficiaryId: userId,
                        ),
                      ),
                    );
                    if (mounted) await _resumeScanner();
                  },
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(sheetContext, true);
                  },
                  child: Text(
                    AppLocalizations.of(sheetContext).scanAgain,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (mounted && scanAgain != false) {
      await _resumeScanner();
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            try {
              await _controller.stop();
            } catch (_) {}
            if (mounted) await Navigator.of(context).maybePop();
          },
        ),
        title: Text(strings.scanQrCode),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          if (_cameraError == null)
            MobileScanner(
              controller: _controller,
              onDetect: (capture) async {
                if (!mounted || _alreadyScanned || _loading) return;
                final barcodes = capture.barcodes;
                if (barcodes.isEmpty) return;
                final code = barcodes.first.rawValue;
                if (code == null || code.trim().isEmpty) return;
                await _processQrCode(code);
              },
            )
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.camera_alt_outlined, size: 56),
                    const SizedBox(height: 16),
                    Text(
                      _cameraError!.toLowerCase().contains('permission')
                          ? strings.cameraPermissionDenied
                          : strings.cameraUnavailable,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _startScanner,
                      icon: const Icon(Icons.refresh),
                      label: Text(strings.retry),
                    ),
                  ],
                ),
              ),
            ),

          if (_loading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: Colors.white,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      strings.qrVerifying,
                      style: const TextStyle(
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
              child: Text(
                strings.qrScannerHint,
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