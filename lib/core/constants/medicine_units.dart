/// Predefined medicine units (satuan obat) used across the app.
///
/// Displayed as a dropdown in medicine form. Add or remove entries
/// here to update the options everywhere — no DB migration needed.
class MedicineUnits {
  MedicineUnits._();

  static const List<String> all = [
    'Tablet',
    'Kaplet',
    'Kapsul',
    'Botol',
    'Sirup',
    'Strip',
    'Tube',
    'Ampul',
    'Vial',
    'Sachet',
    'Pcs',
    'Box',
  ];
}
