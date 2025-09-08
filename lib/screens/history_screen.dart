import 'package:anime_app/models/history_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:anime_app/providers/history_provider.dart';
import 'package:anime_app/providers/user_provider.dart';
import 'package:anime_app/widgets/history_card.dart';

final selectedHistoryStatusProvider = StateProvider<String>((ref) => 'watching');

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final List<History> _listItems = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncList();
  }

  void _syncList() {
    final history = ref.watch(historyProvider).value ?? [];
    final selectedStatus = ref.watch(selectedHistoryStatusProvider);
    _listItems.clear();
    _listItems.addAll(history.where((item) => item.status == selectedStatus).toList());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(historyProvider, (_, _) => _syncList());
    ref.listen(selectedHistoryStatusProvider, (_, _) => _syncList());

    final historyAsync = ref.watch(historyProvider);
    final userAsync = ref.watch(userProvider);

    if (userAsync.value == null) {
      return const Center(child: Text('Please log in to view your history.'));
    }

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        ref.read(selectedHistoryStatusProvider.notifier).state = 'watching',
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ref.watch(selectedHistoryStatusProvider) == 'watching'
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).colorScheme.primary.withAlpha(180),
                    ),
                    child: const Text('Viendo', style: TextStyle(color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        ref.read(selectedHistoryStatusProvider.notifier).state = 'completed',
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ref.watch(selectedHistoryStatusProvider) == 'completed'
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).colorScheme.primary.withAlpha(180),
                    ),
                    child: const Text('Completados', style: TextStyle(color: Colors.black)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: historyAsync.when(
              data: (_) {
                if (_listItems.isEmpty) {
                  return const Center(child: Text('No items in this category.'));
                }
                final selectedStatus = ref.watch(selectedHistoryStatusProvider);
                return AnimatedList(
                  key: ValueKey(selectedStatus),
                  initialItemCount: _listItems.length,
                  itemBuilder: (context, index, animation) {
                    final item = _listItems[index];
                    return FadeTransition(
                      opacity: animation,
                      child: SizeTransition(
                        sizeFactor: animation,
                        child: HistoryCard(item: item),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text(e.toString())),
            ),
          ),
        ],
      ),
    );
  }
}
