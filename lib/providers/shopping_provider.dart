import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shopping_item.dart';
import '../services/api_service.dart';

final shoppingProvider = StateNotifierProvider<ShoppingNotifier, ShoppingState>((ref) {
  return ShoppingNotifier();
});

class ShoppingState {
  final List<ShoppingItem> items;
  final bool isLoading;
  final String message;
  final ShoppingItem? singleItem;

  ShoppingState({required this.items, this.isLoading = false, this.message = '', this.singleItem});
}

class ShoppingNotifier extends StateNotifier<ShoppingState> {
  final ApiService _api = ApiService();

  ShoppingNotifier() : super(ShoppingState(items: []));

  Future<void> fetchAll() async {
    state = ShoppingState(items: state.items, isLoading: true);
    try {
      final items = await _api.getItems();
      state = ShoppingState(items: items, message: 'Fetched ${items.length} items');
    } catch (e) {
      state = ShoppingState(items: [], message: 'Error: $e');
    }
  }

  Future<void> fetchSingle(int id) async {
    state = ShoppingState(items: state.items, isLoading: true);
    try {
      final item = await _api.getItemById(id);
      state = ShoppingState(items: state.items, singleItem: item, message: 'Fetched: ${item.name}');
    } catch (e) {
      state = ShoppingState(items: state.items, message: 'Error: $e');
    }
  }

  Future<void> addItem(ShoppingItem item) async {
    state = ShoppingState(items: state.items, isLoading: true);
    try {
      final newItem = await _api.createItem(item);
      final newList = [newItem, ...state.items].take(5).toList();
      state = ShoppingState(items: newList, message: 'Added: ${newItem.name}');
    } catch (e) {
      state = ShoppingState(items: state.items, message: 'Error: $e');
    }
  }

  Future<void> updateItem(int id, ShoppingItem item) async {
    state = ShoppingState(items: state.items, isLoading: true);
    try {
      final updated = await _api.updateItem(id, item);
      final newList = state.items.map((i) => i.id == id ? updated : i).toList();
      state = ShoppingState(items: newList, message: 'Updated: ${updated.name}');
    } catch (e) {
      state = ShoppingState(items: state.items, message: 'Error: $e');
    }
  }

  Future<void> deleteItem(int id) async {
    state = ShoppingState(items: state.items, isLoading: true);
    try {
      await _api.deleteItem(id);
      final newList = state.items.where((i) => i.id != id).toList();
      state = ShoppingState(items: newList, message: 'Deleted id $id');
    } catch (e) {
      state = ShoppingState(items: state.items, message: 'Error: $e');
    }
  }
}
