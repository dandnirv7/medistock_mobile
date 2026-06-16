import '../../../../core/models/paginated.dart';
import '../../models/supplier_model.dart';

class SupplierQuery {
  SupplierQuery({
    this.page = 1,
    this.limit = 10,
    this.search,
  });

  final int page;
  final int limit;
  final String? search;
}

abstract class SupplierRepository {
  Future<Paginated<SupplierModel>> getAll({SupplierQuery? query});

  Future<SupplierModel> getById(String id);

  Future<SupplierModel> create({
    required String name,
    String? phone,
    String? email,
    String? address,
    String? notes,
  });

  Future<SupplierModel> update(
    String id, {
    String? name,
    String? phone,
    String? email,
    String? address,
    String? notes,
    bool? isActive,
  });

  Future<void> delete(String id);
}
