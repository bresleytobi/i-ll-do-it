import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/transaction.dart';
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
                            onPressed: () {
                              // TODO: Implement withdrawal
                            },
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
                            onPressed: () {
                              // TODO: Implement add funds
                            },
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
    final isIncome = tx.receiverId == currentUserId;
    final currencyFormat = NumberFormat.currency(symbol: 'R ', decimalDigits: 2);
    final dateStr = DateFormat('MMM dd, yyyy').format(tx.createdAt);

    IconData icon;
    if (tx.type == 'withdrawal') {
      icon = Icons.account_balance_wallet_outlined;
    } else if (tx.type == 'payment') {
      icon = isIncome ? Icons.arrow_downward : Icons.arrow_upward;
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
              color: isIncome
                  ? AppColors.success.withOpacity(0.2)
                  : AppColors.error.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isIncome ? AppColors.success : AppColors.error,
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
            '${isIncome ? '+' : '-'}${currencyFormat.format(tx.amount)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isIncome ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}
