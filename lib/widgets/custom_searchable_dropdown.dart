import 'package:flutter/material.dart';

class CustomSearchableDropdown extends StatefulWidget {
  final String hintText;
  final List<String> items;
  final String? selectedItem;
  final ValueChanged<String?> onChanged;

  const CustomSearchableDropdown({
    super.key,
    required this.hintText,
    required this.items,
    this.selectedItem,
    required this.onChanged,
  });

  @override
  State<CustomSearchableDropdown> createState() =>
      _CustomSearchableDropdownState();
}

class _CustomSearchableDropdownState extends State<CustomSearchableDropdown> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final selected = await showDialog<String>(
          context: context,
          builder: (context) => SearchableDropdownDialog(
            items: widget.items,
            title: widget.hintText,
          ),
        );
        if (selected != null) {
          widget.onChanged(selected);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 5.0,
            vertical: 5.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.selectedItem ?? widget.hintText),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}

class SearchableDropdownDialog extends StatefulWidget {
  final List<String> items;
  final String title;

  const SearchableDropdownDialog({
    super.key,
    required this.items,
    required this.title,
  });

  @override
  State<SearchableDropdownDialog> createState() =>
      _SearchableDropdownDialogState();
}

class _SearchableDropdownDialogState extends State<SearchableDropdownDialog> {
  late List<String> _filteredItems;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _filteredItems = widget.items
            .where((item) => item.toLowerCase().contains(query))
            .toList();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Buscar...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  return ListTile(
                    dense: false,
                    visualDensity: VisualDensity(
                      vertical: VisualDensity.minimumDensity,
                    ),
                    title: Text(item),
                    onTap: () {
                      Navigator.of(context).pop(item);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
