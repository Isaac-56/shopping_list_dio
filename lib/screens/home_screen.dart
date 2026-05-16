import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/shopping_provider.dart';
import '../models/shopping_item.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shoppingProvider);
    final notifier = ref.read(shoppingProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Shopping List')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (state.isLoading) const LinearProgressIndicator(),
            if (state.message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.grey[200],
                  child: Text(state.message),
                ),
              ),
            Expanded(
              child: Center(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => notifier.fetchAll(),
                      child: const Text('GET ALL'),
                    ),
                    ElevatedButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => const GetOneDialog(),
                      ).then((id) {
                        if (id != null) notifier.fetchSingle(id);
                      }),
                      child: const Text('GET ONE'),
                    ),
                    ElevatedButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => const AddDialog(),
                      ).then((item) {
                        if (item != null) notifier.addItem(item);
                      }),
                      child: const Text('ADD'),
                    ),
                    ElevatedButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => const UpdateDialog(),
                      ).then((result) {
                        if (result != null) {
                          notifier.updateItem(result.$1, result.$2);
                        }
                      }),
                      child: const Text('UPDATE'),
                    ),
                    ElevatedButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => const DeleteDialog(),
                      ).then((id) {
                        if (id != null) notifier.deleteItem(id);
                      }),
                      child: const Text('DELETE'),
                    ),
                  ],
                ),
              ),
            ),
            if (state.items.isNotEmpty)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Shopping List',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: state.items.length,
                        itemBuilder: (ctx, i) => Card(
                          child: ListTile(
                            title: Text(state.items[i].name),
                            subtitle: Text('Qty: ${state.items[i].quantity}'),
                            trailing: Icon(Icons.shopping_cart, color: Colors.green[700]),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (state.singleItem != null)
              Card(
                color: Colors.yellow[100],
                child: ListTile(
                  title: Text(state.singleItem!.name),
                  subtitle: Text('Qty: ${state.singleItem!.quantity}\nID: ${state.singleItem!.id}'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class GetOneDialog extends StatelessWidget {
  const GetOneDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    return AlertDialog(
      title: const Text('Enter ID'),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'Item ID'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final id = int.tryParse(controller.text);
            if (id != null) Navigator.pop(context, id);
            else Navigator.pop(context);
          },
          child: const Text('Fetch'),
        ),
      ],
    );
  }
}

class AddDialog extends StatelessWidget {
  const AddDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return AlertDialog(
      title: const Text('Add Item'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: qtyCtrl,
              decoration: const InputDecoration(labelText: 'Quantity'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              final item = ShoppingItem(
                name: nameCtrl.text,
                quantity: qtyCtrl.text,
              );
              Navigator.pop(context, item);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class UpdateDialog extends StatelessWidget {
  const UpdateDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final idCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();

    return AlertDialog(
      title: const Text('Update Item'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: idCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Item ID'),
          ),
          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: 'New Name'),
          ),
          TextField(
            controller: qtyCtrl,
            decoration: const InputDecoration(labelText: 'New Quantity'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final id = int.tryParse(idCtrl.text);
            if (id != null && nameCtrl.text.isNotEmpty) {
              final item = ShoppingItem(
                name: nameCtrl.text,
                quantity: qtyCtrl.text,
              );
              Navigator.pop(context, (id, item));
            } else {
              Navigator.pop(context);
            }
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}

class DeleteDialog extends StatelessWidget {
  const DeleteDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final idCtrl = TextEditingController();

    return AlertDialog(
      title: const Text('Delete Item'),
      content: TextField(
        controller: idCtrl,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'Item ID'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final id = int.tryParse(idCtrl.text);
            if (id != null) Navigator.pop(context, id);
            else Navigator.pop(context);
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}