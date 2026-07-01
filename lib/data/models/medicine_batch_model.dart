/// DTO for a medicine batch returned by the API.
/// Used in `GET /medicines/:id` → `batches[]` (Req 1.9).
class MedicineBatchModel {
  final String batchNumber;

  /// Expiry date in YYYY-MM-DD format.
  final String expiredDate;

  final int quantity;

  const MedicineBatchModel({
    required this.batchNumber,
    required this.expiredDate,
    required this.quantity,
  });

  factory MedicineBatchModel.fromJson(Map<String, dynamic> json) {
    return MedicineBatchModel(
      batchNumber: (json['batchNumber'] ?? '').toString(),
      expiredDate: (json['expiredDate'] ?? '').toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'batchNumber': batchNumber,
        'expiredDate': expiredDate,
        'quantity': quantity,
      };

  @override
  String toString() =>
      'MedicineBatchModel(batchNumber: $batchNumber, expiredDate: $expiredDate, quantity: $quantity)';
}
