import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../services/api_client.dart';

void main() => runApp(const TransactionsScreen());

/// A custom widget for a gap with a specific height.
class Gap extends StatelessWidget {
  final double h;
  const Gap(this.h, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: h);
  }
}

/// The main application widget
class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Payouts',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
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
      ),
      home: const PayoutsScreen(),
    );
  }
}

class PayoutsScreen extends StatefulWidget {
  const PayoutsScreen({super.key});
  @override
  State<PayoutsScreen> createState() => _PayoutsScreenState();
}

class _PayoutsScreenState extends State<PayoutsScreen> {
  // ---- unchanged UI state ----
  static const int _pageSize = 5;
  int _shownCount = _pageSize;
  bool _isLoadingMore = false;

  // ---- new: data state from Magento ----
  final _money = NumberFormat.currency(symbol: 'AED ', decimalDigits: 2);
  bool _loading = true;
  String? _error;

  DateTimeRange? _selectedRange;

  // Backing store after fetch
  List<Transaction> _allTransactions = [];
  double _totalPaid = 0.0;
  double _totalProcessing = 0.0;

  @override
  void initState() {
    super.initState();
    _refreshFromMagento();
  }

  Future<void> _refreshFromMagento() async {
    setState(() {
      _loading = true;
      _error = null;
      _shownCount = _pageSize;
    });

    try {
      final DateTime? from = _selectedRange?.start;
      final DateTime? to = _selectedRange?.end;

      final orders = await VendorApiClient().getVendorOrders(
        dateFrom: from,
        dateTo: to,
        currentPage: 1,
        pageSize: 200,
      );

      final txs = <Transaction>[];
      double paid = 0.0;
      double processing = 0.0;

      for (final o in orders) {
        final parsed = _mapOrderToTransaction(o);
        if (parsed != null) {
          txs.add(parsed);
          switch (parsed.status) {
            case TransactionStatus.paid:
              paid += _parseMoney(parsed.earnings);
              break;
            case TransactionStatus.onProcess:
              processing += _parseMoney(parsed.earnings);
              break;
            case TransactionStatus.failed:
              break;
          }
        }
      }

      setState(() {
        _allTransactions = txs;
        _totalPaid = paid;
        _totalProcessing = processing;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  double _parseMoney(String s) {
    final cleaned = s.replaceAll(RegExp(r'[^0-9.\-]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  Transaction? _mapOrderToTransaction(Map<String, dynamic> orderJson) {
    try {
      final incrementId = (orderJson['increment_id'] ?? '').toString();
      final entityId = (orderJson['entity_id'] ?? '').toString();

      final state = (orderJson['state'] ?? '').toString().toLowerCase();
      final status = (orderJson['status'] ?? '').toString().toLowerCase();

      final grandTotal = (orderJson['grand_total'] as num?)?.toDouble() ?? 0.0;
      final currency = (orderJson['order_currency_code'] ??
          orderJson['base_currency_code'] ??
          'AED').toString();

      // Date
      final createdAt = (orderJson['created_at'] ?? '').toString();
      final created =
      createdAt.isNotEmpty ? DateTime.parse(createdAt) : DateTime.now();

      TransactionStatus txStatus;
      if (state == 'complete' ||
          state == 'closed' ||
          status.contains('complete')) {
        txStatus = TransactionStatus.paid;
      } else if (state == 'canceled' ||
          state == 'holded' ||
          status.contains('canceled') ||
          status.contains('hold')) {
        txStatus = TransactionStatus.failed;
      } else {
        txStatus = TransactionStatus.onProcess;
      }

      final earningsStr =
      NumberFormat.currency(symbol: '$currency ', decimalDigits: 2)
          .format(grandTotal);

      return Transaction(
        id: entityId,
        transactionId: incrementId.isEmpty ? entityId : incrementId,
        status: txStatus,
        earnings: earningsStr,
        purchasedOn: created,
      );
    } catch (_) {
      return null;
    }
  }

  List<Transaction> get _filteredTransactions {
    if (_selectedRange == null) return _allTransactions;

    return _allTransactions.where((t) {
      return t.purchasedOn.isAfter(_selectedRange!.start.subtract(const Duration(days: 1))) &&
          t.purchasedOn.isBefore(_selectedRange!.end.add(const Duration(days: 1)));
    }).toList();
  }

  Future<void> _loadMore() async {
    final filtered = _filteredTransactions;
    if (_shownCount >= filtered.length || _isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _shownCount = (_shownCount + _pageSize).clamp(0, filtered.length);
      _isLoadingMore = false;
    });
  }

  void _showDownloadNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.downloadStarted),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _clearFilter() {
    setState(() {
      _selectedRange = null;
      _shownCount = _pageSize;
    });
    _refreshFromMagento();
  }

  Future<void> _pickDateRange() async {
    DateTimeRange tempRange =
        _selectedRange ??
            DateTimeRange(
              start: DateTime.now().subtract(const Duration(days: 30)),
              end: DateTime.now(),
            );

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AppLocalizations.of(context)!.filterByDate,
                    style: Theme.of(context).textTheme.titleMedium),
                const Gap(16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SfDateRangePicker(
                    selectionMode: DateRangePickerSelectionMode.range,
                    initialSelectedRange: PickerDateRange(
                      tempRange.start,
                      tempRange.end,
                    ),
                    showActionButtons: false,
                    backgroundColor: Colors.white,
                    headerStyle: const DateRangePickerHeaderStyle(
                      backgroundColor: Colors.white,
                      textAlign: TextAlign.center,
                      textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    monthCellStyle: const DateRangePickerMonthCellStyle(
                      textStyle: TextStyle(color: Colors.black87),
                      todayTextStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    selectionColor: Color(0xFFE51742),
                    startRangeSelectionColor: Color(0xFFE51742),
                    endRangeSelectionColor: Color(0xFFE51742),
                    rangeSelectionColor: Color(0xFFE51742).withOpacity(0.2),
                    todayHighlightColor: Color(0xFF273647),
                    onSelectionChanged: (args) {
                      if (args.value is PickerDateRange) {
                        final PickerDateRange range = args.value;
                        tempRange = DateTimeRange(
                          start: range.startDate!,
                          end: range.endDate ?? range.startDate!,
                        );
                      }
                    },
                  ),
                ),
                const Gap(20),
                Row(
                  children: [
                    if (_selectedRange != null)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _clearFilter();
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(AppLocalizations.of(context)!.clearFilter),
                        ),
                      ),
                    if (_selectedRange != null) const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedRange = tempRange;
                            _shownCount = _pageSize;
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "${AppLocalizations.of(context)!.filtered}: ${tempRange.start.toLocal()} → ${tempRange.end.toLocal()}",
                              ),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                          _refreshFromMagento();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE51742),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(AppLocalizations.of(context)!.apply),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')} / ${date.month.toString().padLeft(2, '0')} / ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = _filteredTransactions;
    final visibleTransactions = filteredTransactions.take(_shownCount).toList();
    final canLoadMore = _shownCount < filteredTransactions.length;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Gap(30),
            Text(
              AppLocalizations.of(context)!.payouts,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const Gap(20),
            BalanceCard(
              label: AppLocalizations.of(context)!.currentBalance,
              amount: _loading
                  ? '…'
                  : _money.format(_totalPaid),
              icon: Image.asset(
                'assets/icons/trending_up.png',
                width: 24,
                height: 24,
                color: Colors.white,
              ),
              backgroundColor: const Color(0xFF32A06E),
            ),
            const Gap(16),
            BalanceCard(
              label: AppLocalizations.of(context)!.currentBalance,
              amount: _loading
                  ? '…'
                  : _money.format(_totalProcessing),
              icon: Image.asset(
                'assets/icons/balance.png',
                width: 24,
                height: 24,
                color: Colors.white,
              ),
              backgroundColor: const Color(0xFFFFB800),
            ),
            const Gap(24),

            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.2)),
                ),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),

            _PayoutHistory(
              transactions: visibleTransactions,
              canLoadMore: canLoadMore,
              isLoadingMore: _isLoadingMore,
              onLoadMore: _loadMore,
              onDownload: _showDownloadNotification,
              onFilter: _pickDateRange,
              selectedRange: _selectedRange,
              onClearFilter: _clearFilter,
            ),
            const Gap(30),

            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Balance Card (unchanged)
class BalanceCard extends StatelessWidget {
  final String label;
  final String amount;
  final Widget icon;
  final Color backgroundColor;

  const BalanceCard({
    super.key,
    required this.label,
    required this.amount,
    required this.icon,
    required this.backgroundColor,
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
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: icon,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
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

/// Payout History Section (unchanged UI)
class _PayoutHistory extends StatelessWidget {
  final List<Transaction> transactions;
  final bool canLoadMore;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;
  final VoidCallback onDownload;
  final VoidCallback onFilter;
  final DateTimeRange? selectedRange;
  final VoidCallback onClearFilter;

  const _PayoutHistory({
    required this.transactions,
    required this.canLoadMore,
    required this.isLoadingMore,
    required this.onLoadMore,
    required this.onDownload,
    required this.onFilter,
    this.selectedRange,
    required this.onClearFilter,
  });

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')} / ${date.month.toString().padLeft(2, '0')} / ${date.year}';
  }

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
              Text(AppLocalizations.of(context)!.payoutHistory,
                  style: Theme.of(context).textTheme.titleLarge),
              Row(
                children: [
                  if (selectedRange != null)
                    IconButton(
                      onPressed: onClearFilter,
                      icon: const Icon(Icons.clear, color: Colors.red),
                      tooltip: AppLocalizations.of(context)!.clearFilter,
                    ),
                  IconButton(
                    onPressed: onFilter,
                    icon: const Icon(Icons.filter_list_rounded),
                    tooltip: AppLocalizations.of(context)!.filterByDate,
                  ),
                  IconButton(
                    onPressed: onDownload,
                    icon: Image.asset(
                      'assets/icons/download.png',
                      width: 20,
                      height: 20,
                    ),
                    tooltip: AppLocalizations.of(context)!.download,
                  ),
                ],
              ),
            ],
          ),
          if (selectedRange != null) ...[
            const Gap(8),
            Text(
              '${AppLocalizations.of(context)!.filtered}: ${_formatDate(selectedRange!.start)} - ${_formatDate(selectedRange!.end)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const Gap(16),
          if (transactions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(Icons.receipt_long, size: 48, color: Colors.grey[300]),
                  const Gap(16),
                  Text(
                    selectedRange != null
                        ? AppLocalizations.of(context)!.noTransactionsForDateRange
                        : AppLocalizations.of(context)!.noTransactionsAvailable,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
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

/// Transaction Model (unchanged)
enum TransactionStatus { paid, onProcess, failed }

class Transaction {
  final String id;
  final String transactionId;
  final TransactionStatus status;
  final String earnings;
  final DateTime purchasedOn;

  Transaction({
    required this.id,
    required this.transactionId,
    required this.status,
    required this.earnings,
    required this.purchasedOn,
  });
}

/// Transaction Item (unchanged UI)
class TransactionItem extends StatelessWidget {
  final Transaction transaction;
  const TransactionItem({super.key, required this.transaction});

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')} / ${date.month.toString().padLeft(2, '0')} / ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TransactionDetailRow(label: AppLocalizations.of(context)!.transactionIdLabel, value: transaction.id),
        _TransactionDetailRow(
            label: AppLocalizations.of(context)!.transactionId, value: transaction.transactionId),
        _TransactionDetailRow(label: AppLocalizations.of(context)!.status, status: transaction.status),
        _TransactionDetailRow(label: AppLocalizations.of(context)!.earnings, value: transaction.earnings),
        _TransactionDetailRow(
          label: AppLocalizations.of(context)!.purchasedOn,
          value: _formatDate(transaction.purchasedOn),
        ),
        const Gap(20),
        const Divider(height: 1),
      ],
    );
  }
}

class _TransactionDetailRow extends StatelessWidget {
  final String label;
  final String? value;
  final TransactionStatus? status;

  const _TransactionDetailRow({required this.label, this.value, this.status});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          if (status != null)
            _StatusPill(status: status!)
          else
            Text(
              value!,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
        ],
      ),
    );
  }
}

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

  String _label(BuildContext context) {
    switch (status) {
      case TransactionStatus.paid:
        return AppLocalizations.of(context)!.paid;
      case TransactionStatus.onProcess:
        return AppLocalizations.of(context)!.onProcess;
      case TransactionStatus.failed:
        return AppLocalizations.of(context)!.failed;
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
        _label(context),
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: _textColor,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// Load More Button (unchanged)
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
              Image.asset(
                'assets/icons/loading.png',
                width: 18,
                height: 18,
              ),
            const SizedBox(width: 10),
            Text(
              isLoading
                  ? AppLocalizations.of(context)!.loading
                  : AppLocalizations.of(context)!.loadMore,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}