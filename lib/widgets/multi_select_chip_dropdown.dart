import 'package:flutter/material.dart';

class MultiSelectChipDropdown extends StatefulWidget {
  final String hintText;
  final List<String> items;
  final List<String> selectedItems;
  final ValueChanged<List<String>> onChanged;

  const MultiSelectChipDropdown({
    super.key,
    required this.hintText,
    required this.items,
    required this.selectedItems,
    required this.onChanged,
  });

  @override
  State<MultiSelectChipDropdown> createState() => _MultiSelectChipDropdownState();
}

class _MultiSelectChipDropdownState extends State<MultiSelectChipDropdown> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final selected = await showDialog<List<String>>(
          context: context,
          builder: (context) => MultiSelectDialog(
            items: widget.items,
            initialSelectedItems: widget.selectedItems,
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.selectedItems.isEmpty
                    ? widget.hintText
                    : '${widget.selectedItems.length} ${widget.hintText}s selected',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}

class MultiSelectDialog extends StatefulWidget {
  final List<String> items;
  final List<String> initialSelectedItems;
  final String title;

  const MultiSelectDialog({
    super.key,
    required this.items,
    required this.initialSelectedItems,
    required this.title,
  });

  @override
  State<MultiSelectDialog> createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  late List<String> _filteredItems;
  late List<String> _selectedItems;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _selectedItems = List<String>.from(widget.initialSelectedItems);

    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _filteredItems = widget.items.where((item) => item.toLowerCase().contains(query)).toList();
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
      title: Text(widget.title),
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
            const SizedBox(height: 2),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  final isSelected = _selectedItems.contains(item);
                  return ListTile(
                    dense: true,
                    visualDensity: const VisualDensity(vertical: VisualDensity.minimumDensity),
                    title: Text(item),
                    trailing: isSelected ? const Icon(Icons.check) : null,
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedItems.remove(item);
                        } else {
                          _selectedItems.add(item);
                        }
                      });
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
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(_selectedItems);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
