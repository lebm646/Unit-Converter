// lib/conversion.dart
// Pure conversion logic with small, tested helpers.
// Follows Effective Dart naming and documentation guidelines.

/// The categories supported by the converter.
enum MeasureCategory { length, weight }

/// Simple representation of a unit tied to a category, system, and a factor
/// to convert to a chosen base unit (meters for length, grams for weight).
class UnitDef {
  final String code;         // e.g., 'km'
  final String label;        // e.g., 'Kilometers (km)'
  final MeasureCategory cat; // length | weight
  final String system;       // 'metric' | 'imperial'
  final double toBase;       // factor to base (m or g)

  const UnitDef({
    required this.code,
    required this.label,
    required this.cat,
    required this.system,
    required this.toBase,
  });
}

/// App-wide registry of units.
/// Base units: meters for length, grams for weight.
const units = <UnitDef>[
  // Length (base: meter)
  UnitDef(code: 'm',  label: 'Meters (m)',      cat: MeasureCategory.length, system: 'metric',   toBase: 1.0),
  UnitDef(code: 'km', label: 'Kilometers (km)', cat: MeasureCategory.length, system: 'metric',   toBase: 1000.0),
  UnitDef(code: 'mi', label: 'Miles (mi)',      cat: MeasureCategory.length, system: 'imperial', toBase: 1609.344),
  UnitDef(code: 'yd', label: 'Yards (yd)',      cat: MeasureCategory.length, system: 'imperial', toBase: 0.9144),
  UnitDef(code: 'ft', label: 'Feet (ft)',       cat: MeasureCategory.length, system: 'imperial', toBase: 0.3048),
  UnitDef(code: 'in', label: 'Inches (in)',     cat: MeasureCategory.length, system: 'imperial', toBase: 0.0254),

  // Weight (base: gram)
  UnitDef(code: 'g',  label: 'Grams (g)',       cat: MeasureCategory.weight, system: 'metric',   toBase: 1.0),
  UnitDef(code: 'kg', label: 'Kilograms (kg)',  cat: MeasureCategory.weight, system: 'metric',   toBase: 1000.0),
  UnitDef(code: 'lb', label: 'Pounds (lb)',     cat: MeasureCategory.weight, system: 'imperial', toBase: 453.59237),
  UnitDef(code: 'oz', label: 'Ounces (oz)',     cat: MeasureCategory.weight, system: 'imperial', toBase: 28.349523125),
];

/// Returns units for a given category.
List<UnitDef> unitsFor(MeasureCategory cat) =>
    units.where((u) => u.cat == cat).toList();

/// Returns units for a given category and (optionally) system filter.
List<UnitDef> unitsForWithSystem(MeasureCategory cat, {String? system}) {
  final filtered = unitsFor(cat);
  if (system == null) return filtered;
  return filtered.where((u) => u.system == system).toList();
}

/// Finds a unit by its code (e.g., 'km').
UnitDef? unitByCode(String code) {
  for (final u in units) {
    if (u.code == code) return u;
  }
  return null;
}

/// Converts [value] from [fromCode] to [toCode].
///
/// Throws [ArgumentError] if a code is unknown or categories mismatch.
double convert({
  required double value,
  required String fromCode,
  required String toCode,
}) {
  final from = unitByCode(fromCode);
  final to = unitByCode(toCode);

  if (from == null || to == null) {
    throw ArgumentError('Unknown unit code(s): from=$fromCode to=$toCode');
  }
  if (from.cat != to.cat) {
    throw ArgumentError('Cannot convert across categories.');
  }
  // Normalize to the base unit (meters or grams), then to the target.
  final inBase = value * from.toBase;
  final result = inBase / to.toBase;
  return result;
}
