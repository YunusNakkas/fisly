import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';

class Category {
  final String id;
  final String? userId;
  final String name;
  final String icon;
  final String color;
  final bool isSystem;

  const Category({
    required this.id,
    required this.userId,
    required this.name,
    required this.icon,
    required this.color,
    required this.isSystem,
  });

  factory Category.fromJson(Map<String, dynamic> j) => Category(
    id: j['id'] as String,
    userId: j['user_id'] as String?,
    name: j['name'] as String,
    icon: j['icon'] as String,
    color: j['color'] as String,
    isSystem: j['is_system'] as bool,
  );
}

class CategoriesNotifier extends AsyncNotifier<List<Category>> {
  @override
  Future<List<Category>> build() async {
    final api = ref.read(apiClientProvider);
    final res = await api.dio.get('/categories');
    return (res.data as List)
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> create({
    required String name,
    required String icon,
    required String color,
  }) async {
    final api = ref.read(apiClientProvider);
    await api.dio.post(
      '/categories',
      data: {'name': name, 'icon': icon, 'color': color},
    );
    ref.invalidateSelf();
    await future;
  }

  Future<void> edit({
    required String id,
    String? name,
    String? icon,
    String? color,
  }) async {
    final api = ref.read(apiClientProvider);
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (icon != null) body['icon'] = icon;
    if (color != null) body['color'] = color;
    await api.dio.patch('/categories/$id', data: body);
    ref.invalidateSelf();
    await future;
  }

  Future<void> remove(String id) async {
    final api = ref.read(apiClientProvider);
    await api.dio.delete('/categories/$id');
    ref.invalidateSelf();
    await future;
  }
}

final categoriesProvider =
    AsyncNotifierProvider<CategoriesNotifier, List<Category>>(
      CategoriesNotifier.new,
    );
