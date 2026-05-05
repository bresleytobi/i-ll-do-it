import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/transaction.dart';
import '../../../../core/repositories/transaction_repository_impl.dart';
import '../../../../core/services/supabase_service.dart';
import '../providers/wallet_provider.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(balanceProvider);
    final historyAsync = ref.watch(transactionHistoryProvider);
    final currencyFormat = NumberFormat.currency(symbol: 'R ', decimalDigits: 2);
    final currentUserId = ref.watch(supabaseServiceProvider).currentUser?.id;

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        title: const Text('Wallet'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(balanceProvider);
          ref.invalidate(transactionHistoryProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Wallet Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Available Balance',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.darkBg,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    balanceAsync.when(
                      data: (balance) => Text(
                        currencyFormat.format(balance),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkBg,
                        ),
                      ),
                      loading: () => const SizedBox(
                        height: 44,
                        child: Center(
                            child: CircularProgressIndicator(
                                color: AppColors.darkBg)),
                      ),
                      error: (err, _) => const Text(
                        'R 0.00',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkBg,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _showWithdrawDialog(context, ref),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.darkBg,
                            ),
                            child: const Text(
                              'Withdraw',
                              style: TextStyle(color: AppColors.primary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _showDepositDialog(context, ref),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.darkBg,
                            ),
                            child: const Text(
                              'Add Funds',
                              style: TextStyle(color: AppColors.primary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Quick Stats
              Row(
                children: [
                  Expanded(
                    child: _buildStatBox('Pending', 'R 0.00'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatBox('Escrow', 'R 0.00'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Transaction History
              const Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              historyAsync.when(
                data: (transactions) => transactions.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Text(
                            'No transactions yet.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          return _buildTransactionItem(
                              transactions[index], currentUserId);
                        },
                      ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String amount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaction tx, String? currentUserId) {
    final currencyFormat = NumberFormat.currency(symbol: 'R ', decimalDigits: 2);
    final dateStr = DateFormat('MMM dd, yyyy').format(tx.createdAt);
    final isIncoming = tx.type == 'deposit' || (tx.type == 'payment' && tx.receiverId == currentUserId);

    IconData icon;
    if (tx.type == 'withdrawal') {
      icon = Icons.account_balance_wallet_outlined;
    } else if (tx.type == 'deposit') {
      icon = Icons.arrow_downward;
    } else if (tx.type == 'payment') {
      icon = isIncoming ? Icons.arrow_downward : Icons.arrow_upward;
    } else {
      icon = Icons.credit_card;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isIncoming
                  ? AppColors.success.withOpacity(0.2)
                  : AppColors.error.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isIncoming ? AppColors.success : AppColors.error,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.reference ?? 'Transaction',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isIncoming ? '+' : '-'}${currencyFormat.format(tx.amount)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isIncoming ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDepositDialog(BuildContext context, WidgetRef ref) async {
    final amountController = TextEditingController();
    final transactionRepository = ref.read(transactionRepositoryProvider);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Funds'),
          content: TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount',
              prefixText: 'R ',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final amount = double.tryParse(amountController.text.replaceAll(',', '.')) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount.')),
      );
      return;
    }

    try {
      await transactionRepository.depositFunds(
        amount: amount,
        reference: 'Wallet top-up',
      );
      ref.invalidate(balanceProvider);
      ref.invalidate(transactionHistoryProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Funds added successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add funds: $e')),
      );
    }
  }

  Future<void> _showWithdrawDialog(BuildContext context, WidgetRef ref) async {
    final amountController = TextEditingController();
    final accountController = TextEditingController();
    final transactionRepository = ref.read(transactionRepositoryProvider);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Withdraw Funds'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: 'R ',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: accountController,
                decoration: const InputDecoration(
                  labelText: 'Bank account / reference',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Request'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final amount = double.tryParse(amountController.text.replaceAll(',', '.')) ?? 0.0;
    final bankAccount = accountController.text.trim();
    if (amount <= 0 || bankAccount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount and bank account.')),
      );
      return;
    }

    try {
      await transactionRepository.withdrawFunds(
        amount: amount,
        bankAccount: bankAccount,
      );
      ref.invalidate(balanceProvider);
      ref.invalidate(transactionHistoryProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Withdrawal request submitted.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to withdraw funds: $e')),
      );
    }
  }
}
