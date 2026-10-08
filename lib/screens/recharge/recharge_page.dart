import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../localization.dart';
import '../../models/payment_method_model.dart';
import '../../models/subscription_model.dart';
import '../../services/recharge_service.dart';
import '../../utils/phone_number_utils.dart';

class RechargePage extends StatefulWidget {
  const RechargePage({super.key});

  @override
  State<RechargePage> createState() => _RechargePageState();
}

class _RechargePageState extends State<RechargePage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _customerNumberController = TextEditingController();
  final _service = RechargeService();

  PaymentMethodModel? _paymentMethod;
  SubscriptionModel? _subscription;
  PlatformFile? _proof;
  bool _isSubmitting = false;

  static const _quickAmounts = [1000, 2000, 5000, 10000, 25000, 50000];

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _customerNumberController.dispose();
    super.dispose();
  }

  void _selectAmount(int amount) {
    setState(() {
      _subscription = null;
      _amountController.text = amount.toString();
    });
  }

  void _selectSubscription(SubscriptionModel subscription) {
    setState(() {
      _subscription = subscription;
      _amountController.text = subscription.prix.toString();
    });
  }

  String? _validateAmount(
    String? value,
    RechargeSettings settings,
    AppLocalizations strings,
  ) {
    final amount = int.tryParse((value ?? '').trim());
    if (amount == null ||
        amount < settings.minimumAmount ||
        amount > settings.maximumAmount) {
      return strings
          .text('amountRangeError')
          .replaceFirst('{min}', '${settings.minimumAmount}')
          .replaceFirst('{max}', '${settings.maximumAmount}');
    }
    return null;
  }

  Future<void> _pickProof() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (!mounted || result == null) return;

      final file = result.files.single;
      if (file.bytes == null) {
        _showError(AppLocalizations.of(context).text('proofReadFailed'));
        return;
      }
      if (file.size >= 10 * 1024 * 1024) {
        _showError(AppLocalizations.of(context).text('proofTooLarge'));
        return;
      }
      setState(() => _proof = file);
    } catch (error) {
      if (mounted) {
        _showError(
          '${AppLocalizations.of(context).text('proofReadFailed')} $error',
        );
      }
    }
  }

  Future<void> _submit(
    RechargeSettings settings,
    WalletSnapshot? wallet,
    AppLocalizations strings,
  ) async {
    if (_isSubmitting || !_formKey.currentState!.validate()) return;
    if (wallet == null) {
      _showError(strings.text('walletUnavailable'));
      return;
    }
    if (wallet.isBlocked) {
      _showError(strings.text('walletBlocked'));
      return;
    }
    if (_paymentMethod == null) {
      _showError(strings.text('paymentRequired'));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      String? proofUrl;
      if (_proof != null) {
        final extension = _proof!.extension?.toLowerCase() ?? 'jpeg';
        final mimeSubtype = extension == 'jpg' ? 'jpeg' : extension;
        proofUrl = await _service.uploadProof(
          bytes: _proof!.bytes!,
          fileName: _proof!.name,
          contentType: 'image/$mimeSubtype',
        );
      }

      await _service.createRechargeRequest(
        amount: int.parse(_amountController.text.trim()),
        currency: settings.currency,
        paymentMethod: _paymentMethod!,
        reference: _referenceController.text,
        customerNumber: _customerNumberController.text,
        proofUrl: proofUrl,
        subscriptionId: _subscription?.id,
      );

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 40),
          title: Text(strings.text('rechargeRequestSubmittedTitle')),
          content: Text(strings.text('rechargeRequestSubmitted')),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(strings.text('continue')),
            ),
          ],
        ),
      );
      if (mounted) Navigator.of(context).pop(true);
    } on FirebaseException catch (error) {
      if (mounted) {
        _showError(error.message ?? strings.text('rechargeRequestFailed'));
      }
    } catch (error) {
      if (mounted) {
        _showError('${strings.text('rechargeRequestFailed')} $error');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.text('recharge'))),
      body: StreamBuilder<RechargeSettings>(
        stream: _service.watchSettings(),
        builder: (context, settingsSnapshot) {
          if (settingsSnapshot.hasError) {
            return _buildLoadError(strings.text('rechargeSettingsUnavailable'));
          }
          if (!settingsSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final settings = settingsSnapshot.data!;
          return StreamBuilder<WalletSnapshot?>(
            stream: _service.watchWallet(),
            builder: (context, walletSnapshot) {
              if (walletSnapshot.hasError) {
                return _buildLoadError(strings.text('walletUnavailable'));
              }
              if (walletSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final wallet = walletSnapshot.data;
              return Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildWalletCard(wallet, settings.currency, strings),
                    const SizedBox(height: 20),
                    Text(
                      strings.text('subscriptionPlans'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    StreamBuilder<List<SubscriptionModel>>(
                      stream: _service.watchSubscriptions(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text(strings.text('plansUnavailable'));
                        }
                        final subscriptions = snapshot.data ?? [];
                        if (subscriptions.isEmpty) {
                          return Text(strings.text('noPlans'));
                        }
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: subscriptions
                              .where((subscription) =>
                                  subscription.actif && subscription.prix > 0)
                              .map(
                                (subscription) => ChoiceChip(
                                  label: Text(
                                    '${subscription.nom} - ${subscription.prix} ${settings.currency}',
                                  ),
                                  selected: _subscription?.id == subscription.id,
                                  onSelected: _isSubmitting
                                      ? null
                                      : (_) => _selectSubscription(subscription),
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      strings.text('customAmount'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _quickAmounts
                          .where((amount) =>
                              amount >= settings.minimumAmount &&
                              amount <= settings.maximumAmount)
                          .map(
                            (amount) => OutlinedButton(
                              onPressed: _isSubmitting
                                  ? null
                                  : () => _selectAmount(amount),
                              child: Text('$amount ${settings.currency}'),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _amountController,
                      enabled: !_isSubmitting,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: strings.text('amount'),
                        suffixText: settings.currency,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          _validateAmount(value, settings, strings),
                      onChanged: (_) {
                        if (_subscription != null) {
                          setState(() => _subscription = null);
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      strings.text('paymentMethod'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    StreamBuilder<List<PaymentMethodModel>>(
                      stream: _service.watchPaymentMethods(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text(
                            strings.text('paymentMethodsUnavailable'),
                          );
                        }
                        final methods = (snapshot.data ?? [])
                            .where((method) => method.actif)
                            .toList();
                        if (methods.isEmpty) {
                          return Text(strings.text('noPaymentMethods'));
                        }
                        return Column(
                          children: methods
                              .map(
                                (method) => RadioListTile<String>(
                                  value: method.id,
                                  groupValue: _paymentMethod?.id,
                                  title: Text(method.nom),
                                  subtitle: Text(
                                    [
                                      method.type,
                                      method.description,
                                    ].where((value) => value.isNotEmpty).join(' • '),
                                  ),
                                  onChanged: _isSubmitting
                                      ? null
                                      : (_) => setState(
                                            () => _paymentMethod = method,
                                          ),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                    if (_paymentMethod != null) ...[
                      const SizedBox(height: 8),
                      Card(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_paymentMethod!.phoneNumber.isNotEmpty)
                                Text(
                                  '${strings.text('phoneNumber')}: ${_paymentMethod!.phoneNumber}',
                                ),
                              if (_paymentMethod!.accountName.isNotEmpty)
                                Text(
                                  '${strings.text('accountName')}: ${_paymentMethod!.accountName}',
                                ),
                              if (_paymentMethod!.accountNumber.isNotEmpty)
                                Text(_paymentMethod!.accountNumber),
                              Text(
                                '${strings.text('exactAmount')}: ${_amountController.text} ${settings.currency}',
                              ),
                              if (_paymentMethod!.instructions.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(_paymentMethod!.instructions),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    TextFormField(
                      controller: _customerNumberController,
                      enabled: !_isSubmitting,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: strings.text('phoneNumber'),
                        hintText: '+2250700000000',
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final number = PhoneNumberUtils.normalize(value ?? '');
                        if (number.isEmpty) {
                          return strings.text('customerNumberRequired');
                        }
                        if (!PhoneNumberUtils.isValid(number)) {
                          return strings.text('invalidCustomerPhoneNumber');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _referenceController,
                      enabled: !_isSubmitting,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: strings.text('transactionReference'),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) => (value ?? '').trim().isEmpty
                          ? strings.text('referenceRequired')
                          : null,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _isSubmitting ? null : _pickProof,
                      icon: const Icon(Icons.attach_file),
                      label: Text(
                        _proof?.name ?? strings.text('attachProof'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _isSubmitting
                          ? null
                          : () => _submit(settings, wallet, strings),
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send),
                      label: Text(strings.text('paymentMade')),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildWalletCard(
    WalletSnapshot? wallet,
    String currency,
    AppLocalizations strings,
  ) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.account_balance_wallet_outlined),
        title: Text(strings.text('balance')),
        subtitle: Text(
          wallet == null
              ? strings.text('walletUnavailable')
              : '${wallet.balance} ${wallet.currency.isEmpty ? currency : wallet.currency}',
        ),
      ),
    );
  }

  Widget _buildLoadError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}
