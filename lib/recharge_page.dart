import 'package:flutter/material.dart';

import 'localization.dart';
import 'wallet_service.dart';

enum PaymentMethod { bankCard, mobileMoney, bankTransfer }

class RechargePage extends StatefulWidget {
  const RechargePage({super.key});

  @override
  State<RechargePage> createState() => _RechargePageState();
}

class _RechargePageState extends State<RechargePage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  PaymentMethod? _paymentMethod;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String? _validateAmount(String? value, AppLocalizations strings) {
    final normalized = (value ?? '').trim().replaceAll(',', '.');
    final amount = double.tryParse(normalized);
    if (amount == null || !amount.isFinite || amount < 0.01) return strings.text('amountInvalid');
    if (amount > 100000) return strings.text('amountTooHigh');
    return null;
  }

  String _paymentMethodLabel(PaymentMethod method, AppLocalizations strings) {
    switch (method) {
      case PaymentMethod.bankCard:
        return strings.text('bankCard');
      case PaymentMethod.mobileMoney:
        return strings.text('mobileMoney');
      case PaymentMethod.bankTransfer:
        return strings.text('bankTransfer');
    }
  }

  Future<void> _confirmRecharge(AppLocalizations strings) async {
    if (!_formKey.currentState!.validate()) return;
    if (_paymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(strings.text('paymentRequired'))));
      return;
    }

    final amount = double.parse(_amountController.text.trim().replaceAll(',', '.'));
    final amountCents = (amount * 100).round();
    setState(() => _isSubmitting = true);
    try {
      final newBalance = await WalletService.recharge(
        amountCents: amountCents,
        paymentMethod: _paymentMethod!.name,
      );
      if (!mounted) return;
      Navigator.of(context).pop(newBalance);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(strings.text('rechargeFailed'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.text('recharge'))),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(strings.text('rechargeSubtitle')),
            const SizedBox(height: 24),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: strings.text('amount'),
                prefixText: '${strings.text('currency')} ',
                border: const OutlineInputBorder(),
              ),
              validator: (value) => _validateAmount(value, strings),
            ),
            const SizedBox(height: 24),
            Text(strings.text('paymentMethod'), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...PaymentMethod.values.map(
              (method) => RadioListTile<PaymentMethod>(
                value: method,
                groupValue: _paymentMethod,
                title: Text(_paymentMethodLabel(method, strings)),
                onChanged: _isSubmitting ? null : (value) => setState(() => _paymentMethod = value),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isSubmitting ? null : () => _confirmRecharge(strings),
              icon: _isSubmitting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.check),
              label: Text(strings.text('confirmRecharge')),
            ),
          ],
        ),
      ),
    );
  }
}
