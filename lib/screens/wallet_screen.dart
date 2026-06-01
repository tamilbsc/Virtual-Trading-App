import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/portfolio_provider.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PortfolioProvider>();
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Funds'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Wallet Balance Card
                  Center(
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 800),
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF191919), Color(0xFF2C3E50)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet,
                              color: Colors.blueAccent,
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Available Margin',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            currencyFormatter.format(provider.walletBalance),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  const Text(
                    'Manage Funds',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Deposit & Withdraw Forms
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: const _FundForms(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FundForms extends StatefulWidget {
  const _FundForms();

  @override
  State<_FundForms> createState() => _FundFormsState();
}

class _FundFormsState extends State<_FundForms>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _ifscController = TextEditingController();
  final GlobalKey<FormState> _depositFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _withdrawFormKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _accountController.dispose();
    _ifscController.dispose();
    super.dispose();
  }

  void _processTransaction(bool isDeposit) async {
    final formKey = isDeposit ? _depositFormKey : _withdrawFormKey;

    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final amount = double.tryParse(_amountController.text) ?? 0;
      final provider = context.read<PortfolioProvider>();

      // Simulate network wait
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      bool success = true;
      if (isDeposit) {
        await provider.depositFunds(amount);
      } else {
        success = await provider.withdrawFunds(amount);
      }

      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isDeposit
                  ? 'Successfully deposited ₹$amount'
                  : 'Successfully withdrawn ₹$amount',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _amountController.clear();
        _accountController.clear();
        _ifscController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isDeposit ? 'Deposit failed' : 'Insufficient funds'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.blueAccent,
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.white54,
            tabs: const [
              Tab(text: 'Deposit'),
              Tab(text: 'Withdraw'),
            ],
          ),
          SizedBox(
            height: 380, // Fixed height for forms
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildForm(isDeposit: true),
                _buildForm(isDeposit: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm({required bool isDeposit}) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: isDeposit ? _depositFormKey : _withdrawFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Amount (₹)',
                prefixIcon: const Icon(Icons.currency_rupee),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.black12,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Enter a valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _accountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Bank Account Number',
                prefixIcon: const Icon(Icons.account_balance),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.black12,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter account number';
                }
                if (value.length < 8) {
                  return 'Account number is too short';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ifscController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: 'IFSC Code',
                prefixIcon: const Icon(Icons.pin),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.black12,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter IFSC code';
                }
                if (value.length < 11) {
                  return 'Invalid IFSC code';
                }
                return null;
              },
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () => _processTransaction(isDeposit),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDeposit ? Colors.green : Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      isDeposit ? 'Deposit Securely' : 'Initiate Withdrawal',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
