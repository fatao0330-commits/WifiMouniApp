import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../localization.dart';
import '../../../services/recharge_service.dart';

class RechargePage extends StatefulWidget {
  const RechargePage({super.key});

  @override
  State<RechargePage> createState() => _RechargePageState();
}

class _RechargePageState extends State<RechargePage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _service = RechargeService();
  PaymentMethod? _paymentMethod;
  Subscription? _subscription;
  PlatformFile? _proof;
  bool _isSubmitting = false;

  static const _quickAmounts = [1000, 2000, 5000, 10000, 25000, 50000];

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  void _selectSubscription(Subscription subscription) {
    setState(() {
      _subscription = subscription;
      _amountController.text = subscription.amount.toString();
    });
  }

  void _selectAmount(int amount) {
    setState(() {
      _subscription = null;
      _amountController.text = amount.toString();
    });
  }

  String? _validateAmount(String? value, RechargeSettings settings, AppLocalizations strings) {
    final amount = int.tryParse((value ?? '').trim());
    if (amount == null || amount < settings.minimumAmount || amount > settings.maximumAmount) {
      return strings.text('amountRangeError').replaceFirst('{min}', '${settings.minimumAmount}').replaceFirst('{max}', '${settings.maximumAmount}');
    }
    return null;
  }

  Future<void> _pickProof() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (!mounted || result == null || result.files.single.bytes == null) return;
    setState(() => _proof = result.files.single);
  }

  Future<void> _submit(RechargeSettings settings, AppLocalizations strings) async {
    if (!_formKey.currentState!.validate()) return;
    if (_paymentMethod == null) {
      _showError(strings.text('paymentRequired'));
      return;
    }
    if (_referenceController.text.trim().isEmpty) {
      _showError(strings.text('referenceRequired'));
      return;
    }

    final amount = int.parse(_amountController.text.trim());
    setState(() => _isSubmitting = true);
    try {
      String? proofUrl;
      if (_proof != null) {
        proofUrl = await _service.uploadProof(bytes: _proof!.bytes!, fileName: _proof!.name, contentType: 'image/${_proof!.extension ?? 'jpeg'}');
      }
      await _service.createRechargeRequest(
        amount: amount,
        currency: settings.currency,
        paymentMethod: _paymentMethod!,
        reference: _referenceController.text,
        proofUrl: proofUrl,
        subscriptionId: _subscription?.id,
      );
      if (!mounted) return;
      _showSuccess(strings.text('rechargeRequestSubmitted'));
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showError(strings.text('rechargeRequestFailed'));
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.text('recharge'))),
      body: StreamBuilder<RechargeSettings>(
        stream: _service.watchSettings(),
        builder: (context, settingsSnapshot) {
          final settings = settingsSnapshot.data ?? const RechargeSettings();
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                StreamBuilder<WalletSnapshot>(
                  stream: _service.watchWallet(),
                  builder: (context, snapshot) {
                    final wallet = snapshot.data;
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.account_balance_wallet_outlined),
                        title: Text(strings.text('balance')),
                        subtitle: Text(wallet == null ? '...' : '${wallet.balance} ${wallet.currency}'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Text(strings.text('subscriptionPlans'), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                StreamBuilder<List<Subscription>>(
                  stream: _service.watchSubscriptions(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) return Text(strings.text('plansUnavailable'));
                    final subscriptions = snapshot.data ?? const <Subscription>[];
                    if (subscriptions.isEmpty) return Text(strings.text('noPlans'));
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: subscriptions.map((subscription) => ChoiceChip(
                        label: Text('${subscription.name} - ${subscription.amount} ${subscription.currency}'),
                        selected: _subscription?.id == subscription.id,
                        onSelected: _isSubmitting ? null : (_) => _selectSubscription(subscription),
                      )).toList(),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Text(strings.text('customAmount'), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _quickAmounts.map((amount) => OutlinedButton(onPressed: _isSubmitting ? null : () => _selectAmount(amount), child: Text('$amount ${settings.currency}'))).toList(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: strings.text('amount'), suffixText: settings.currency, border: const OutlineInputBorder()),
                  validator: (value) => _validateAmount(value, settings, strings),
                  onChanged: (_) => setState(() => _subscription = null),
                ),
                const SizedBox(height: 20),
                Text(strings.text('paymentMethod'), style: Theme.of(context).textTheme.titleMedium),
                StreamBuilder<List<PaymentMethod>>(
                  stream: _service.watchPaymentMethods(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) return Text(strings.text('paymentMethodsUnavailable'));
                    final methods = snapshot.data ?? const <PaymentMethod>[];
                    if (methods.isEmpty) return Text(strings.text('noPaymentMethods'));
                    return Column(children: methods.map((method) => RadioListTile<PaymentMethod>(
                      value: method,
                      groupValue: _paymentMethod,
                      title: Text(method.name),
                      subtitle: Text(method.type),
                      onChanged: _isSubmitting ? null : (value) => setState(() => _paymentMethod = value),
                      contentPadding: EdgeInsets.zero,
                    )).toList());
                  },
                ),
                if (_paymentMethod != null) ...[
                  const SizedBox(height: 8),
                  Card(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        if (_paymentMethod!.phoneNumber?.isNotEmpty == true) Text('${strings.text('phoneNumber')}: ${_paymentMethod!.phoneNumber}'),
                        if (_paymentMethod!.accountName?.isNotEmpty == true) Text('${strings.text('accountName')}: ${_paymentMethod!.accountName}'),
                        Text('${strings.text('exactAmount')}: ${_amountController.text} ${settings.currency}'),
                        if (_paymentMethod!.instructions.isNotEmpty) Text(_paymentMethod!.instructions),
                      ]),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                TextFormField(
                  controller: _referenceController,
                  decoration: InputDecoration(labelText: strings.text('transactionReference'), hintText: 'OM123456789', border: const OutlineInputBorder()),
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(onPressed: _isSubmitting ? null : _pickProof, icon: const Icon(Icons.attach_file), label: Text(_proof?.name ?? strings.text('attachProof'))),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _isSubmitting ? null : () => _submit(settings, strings),
                  icon: _isSubmitting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send),
                  label: Text(strings.text('paymentMade')),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
