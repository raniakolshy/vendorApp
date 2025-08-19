import 'package:flutter/material.dart';

void main() => runApp(const TransactionsScreen());

/// A custom widget for a gap with a specific height.
class Gap extends StatelessWidget {
  /// The height of the gap.
  final double h;

  /// Creates a [Gap] widget with the specified height.
  const Gap(this.h, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: h);
  }
}

/// The main application widget for the Payouts UI.
class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Payouts',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF3F3F4),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B1B1B),
          primary: const Color(0xFF1B1B1B),
          onPrimary: Colors.white,
          secondary: const Color(0xFFD3D3D3),
          onSecondary: const Color(0xFF4A4A4A),
          surface: Colors.white,
          onSurface: const Color(0xFF1B1B1B),
          background: const Color(0xFFF3F3F4),
          onBackground: const Color(0xFF1B1B1B),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF1B1B1B)),
          bodyMedium: TextStyle(color: Color(0xFF1B1B1B)),
          bodySmall: TextStyle(color: Color(0xFF6B6B6B)),
          headlineSmall: TextStyle(
            color: Color(0xFF1B1B1B),
            fontWeight: FontWeight.bold,
          ),
          titleLarge: TextStyle(
            color: Color(0xFF1B1B1B),
            fontWeight: FontWeight.bold,
          ),
          titleSmall: TextStyle(color: Color(0xFF6B6B6B)),
        ),
      ),
      home: const PayoutsScreen(),
    );
  }
}

/// A screen that displays the user's payouts.
class PayoutsScreen extends StatefulWidget {
  const PayoutsScreen({super.key});

  @override
  State<PayoutsScreen> createState() => _PayoutsScreenState();
}

/// The state for the [PayoutsScreen].
class _PayoutsScreenState extends State<PayoutsScreen> {
  static const int _pageSize = 5;
  int _shownCount = _pageSize;
  bool _isLoadingMore = false;

  final List<Transaction> _allTransactions = List.generate(
    10,
        (index) => Transaction(
      id: '12345',
      transactionId: 'TXN${1000 + index}',
      status: index.isEven ? TransactionStatus.paid : TransactionStatus.onProcess,
      earnings: r'$7,750.88',
      purchasedOn: '12 / 12 / 2025',
    ),
  );

  /// Loads more transactions.
  Future<void> _loadMore() async {
    if (_shownCount >= _allTransactions.length || _isLoadingMore) return;

    setState(() => _isLoadingMore = true);
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _shownCount = (_shownCount + _pageSize).clamp(0, _allTransactions.length);
      _isLoadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final visibleTransactions = _allTransactions.take(_shownCount).toList();
    final canLoadMore = _shownCount < _allTransactions.length;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Gap(50),
            _buildAppBar(),
            const Gap(30),
            Text(
              'Payouts',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 24),
            ),
            const Gap(20),
            const BalanceCard(
              label: 'Current balance',
              amount: r'$128k',
              icon: Icons.trending_up,
            ),
            const Gap(16),
            const BalanceCard(
              label: 'Available for withdrawal',
              amount: r'$512.64',
              icon: Icons.attach_money,
            ),
            const Gap(24),
            _PayoutHistory(
              transactions: visibleTransactions,
              canLoadMore: canLoadMore,
              isLoadingMore: _isLoadingMore,
              onLoadMore: _loadMore,
            ),
            const Gap(30),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.menu),
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.home),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.person),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications),
            ),
          ],
        ),
      ],
    );
  }
}

/// A card displaying a balance amount.
class BalanceCard extends StatelessWidget {
  final String label;
  final String amount;
  final IconData icon;

  const BalanceCard({
    super.key,
    required this.label,
    required this.amount,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEEEF)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 24,
              color: const Color(0xFF333333),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Gap(4),
              Text(
                amount,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The section for payout history.
class _PayoutHistory extends StatelessWidget {
  final List<Transaction> transactions;
  final bool canLoadMore;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;

  const _PayoutHistory({
    required this.transactions,
    required this.canLoadMore,
    required this.isLoadingMore,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payout history',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.filter_list_rounded),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.file_download_outlined),
                  ),
                ],
              ),
            ],
          ),
          const Gap(16),
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: transactions.length,
            separatorBuilder: (_, __) => const Gap(20),
            itemBuilder: (context, i) =>
                TransactionItem(transaction: transactions[i]),
          ),
          const Gap(16),
          if (transactions.isNotEmpty && canLoadMore)
            Center(
              child: _LoadMoreButton(
                onPressed: onLoadMore,
                isLoading: isLoadingMore,
              ),
            ),
        ],
      ),
    );
  }
}

/// A single row for a transaction item.
class TransactionItem extends StatelessWidget {
  final Transaction transaction;

  const TransactionItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TransactionDetailRow(
          label: 'ID',
          value: transaction.id,
        ),
        _TransactionDetailRow(
          label: 'Transaction ID',
          value: transaction.transactionId,
        ),
        _TransactionDetailRow(
          label: 'Status',
          status: transaction.status,
        ),
        _TransactionDetailRow(
          label: 'Earnings',
          value: transaction.earnings,
        ),
        _TransactionDetailRow(
          label: 'Purchased on',
          value: transaction.purchasedOn,
        ),
        const Gap(20),
        const Divider(height: 1),
      ],
    );
  }
}

/// A row displaying a transaction detail.
class _TransactionDetailRow extends StatelessWidget {
  final String label;
  final String? value;
  final TransactionStatus? status;

  const _TransactionDetailRow({
    required this.label,
    this.value,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (status != null)
            _StatusPill(status: status!)
          else
            Text(
              value!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

/// A small pill-shaped widget for displaying transaction status.
class _StatusPill extends StatelessWidget {
  final TransactionStatus status;

  const _StatusPill({required this.status});

  Color get _bgColor {
    switch (status) {
      case TransactionStatus.paid:
        return const Color(0xFFDFF7E3);
      case TransactionStatus.onProcess:
        return const Color(0xFFFFF4CC);
      case TransactionStatus.failed:
        return const Color(0xFFFFE0E0);
    }
  }

  Color get _textColor {
    switch (status) {
      case TransactionStatus.paid:
        return const Color(0xFF2E7D32);
      case TransactionStatus.onProcess:
        return const Color(0xFFF57F17);
      case TransactionStatus.failed:
        return const Color(0xFFC62828);
    }
  }

  String get _label {
    switch (status) {
      case TransactionStatus.paid:
        return 'Paid';
      case TransactionStatus.onProcess:
        return 'On process';
      case TransactionStatus.failed:
        return 'Failed';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        _label,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: _textColor,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// A button for loading more items.
class _LoadMoreButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const _LoadMoreButton({
    required this.onPressed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onPressed,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.black.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              const Icon(Icons.restart_alt_rounded, size: 18),
            const SizedBox(width: 10),
            Text(
              'Load more',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The status of a transaction.
enum TransactionStatus { paid, onProcess, failed }

/// A model class for a single transaction.
class Transaction {
  final String id;
  final String transactionId;
  final TransactionStatus status;
  final String earnings;
  final String purchasedOn;

  Transaction({
    required this.id,
    required this.transactionId,
    required this.status,
    required this.earnings,
    required this.purchasedOn,
  });
}