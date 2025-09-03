import 'package:flutter/material.dart';
import 'conversion.dart';

void main() {
  runApp(const ConversionApp());
}

class ConversionApp extends StatelessWidget {
  const ConversionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Measures Converter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,                 // Material 2 look (blue AppBar)
        primarySwatch: Colors.blue,
      ),
      home: const ConverterScreen(),
    );
  }
}

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final _valueCtrl = TextEditingController();

  // Show all units in the "From" dropdown; "To" will be filtered to same category.
  // Defaults that match the screenshot.
  String _fromCode = 'm';  // meters
  String _toCode   = 'ft'; // feet

  String? _result;

  // Pretty, lowercase names to match screenshot text
  static const Map<String, String> _unitNames = {
    'm': 'meters',
    'km': 'kilometers',
    'mi': 'miles',
    'yd': 'yards',
    'ft': 'feet',
    'in': 'inches',
    'g': 'grams',
    'kg': 'kilograms',
    'lb': 'pounds',
    'oz': 'ounces',
  };

  List<UnitDef> get _fromUnits => units; // all units
  List<UnitDef> get _toUnits {
    final cat = unitByCode(_fromCode)!.cat;
    return units.where((u) => u.cat == cat).toList();
  }

  void _convert() {
    final raw = _valueCtrl.text.trim();
    final v = double.tryParse(raw);
    if (v == null) {
      setState(() => _result = null);
      return;
    }
    final out = convert(value: v, fromCode: _fromCode, toCode: _toCode);

    // Format to match screenshot: input 1 decimal, output 3 decimals.
    final inputStr  = v.toStringAsFixed(1);
    final outputStr = out.toStringAsFixed(3);
    final fromName  = _unitNames[_fromCode] ?? _fromCode;
    final toName    = _unitNames[_toCode] ?? _toCode;

    setState(() => _result = '$inputStr $fromName are $outputStr $toName');
  }

  @override
  void dispose() {
    _valueCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Measures Converter'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        children: [
          _SectionTitle('Value'),
          TextField(
            key: const Key('valueField'),
            controller: _valueCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 22),
            decoration: const InputDecoration(
              isDense: true,
              border: UnderlineInputBorder(),
            ),
            onSubmitted: (_) => _convert(),
          ),
          const SizedBox(height: 24),

          _SectionTitle('From'),
          DropdownButtonFormField<String>(
            key: const Key('fromDropdown'),
            isExpanded: true,
            initialValue: _fromCode,
            decoration: const InputDecoration(
              isDense: true,
              border: UnderlineInputBorder(), // underline look
            ),
            items: _fromUnits
                .map((u) => DropdownMenuItem<String>(
                      value: u.code,
                      child: Text(
                        _unitNames[u.code] ?? u.code,
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ))
                .toList(),
            onChanged: (code) {
              if (code == null) return;
              setState(() {
                _fromCode = code;
                // If target now mismatches category, pick first compatible.
                final cat = unitByCode(_fromCode)!.cat;
                if (unitByCode(_toCode)!.cat != cat) {
                  _toCode = _toUnits.first.code;
                }
              });
            },
          ),
          const SizedBox(height: 24),

          _SectionTitle('To'),
          DropdownButtonFormField<String>(
            key: const Key('toDropdown'),
            isExpanded: true,
            initialValue: _toCode,
            decoration: const InputDecoration(
              isDense: true,
              border: UnderlineInputBorder(),
            ),
            items: _toUnits
                .map((u) => DropdownMenuItem<String>(
                      value: u.code,
                      child: Text(
                        _unitNames[u.code] ?? u.code,
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ))
                .toList(),
            onChanged: (code) => setState(() => _toCode = code ?? _toCode),
          ),
          const SizedBox(height: 28),

          Center(
            child: ElevatedButton(
              key: const Key('convertButton'),
              onPressed: _convert,
              style: ElevatedButton.styleFrom(
                elevation: 2,
                backgroundColor: Colors.grey[200], // light grey fill
                foregroundColor: Theme.of(context).primaryColor, // blue text
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text('Convert'),
            ),
          ),
          const SizedBox(height: 28),

          if (_result != null)
            Center(
              child: Text(
                _result!,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.grey[700]),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 12),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}
