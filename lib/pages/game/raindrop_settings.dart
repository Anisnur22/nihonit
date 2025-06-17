import 'package:flutter/material.dart';

class RaindropSettings extends StatefulWidget {
  final Function(String scriptType, String? kanjiMode) onSettingsChanged;

  const RaindropSettings({super.key, required this.onSettingsChanged});

  @override
  State<RaindropSettings> createState() => _RaindropSettingsState();
}

class _RaindropSettingsState extends State<RaindropSettings> {
  String _scriptType = 'hiragana';
  String? _kanjiMode;

  final Map<String, String> scriptLabels = {
    'hiragana': 'Hiragana',
    'katakana': 'Katakana',
    'kanji': 'Kanji',
    'all': 'All (Random)',
  };

  void _notifyChange() {
    widget.onSettingsChanged(_scriptType, _kanjiMode);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Script Type",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.brown),
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            value: _scriptType,
            underline: const SizedBox(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _scriptType = value;
                  _kanjiMode = value == 'kanji' || value == 'all' ? 'meaning' : null;
                });
                _notifyChange();
              }
            },
            items: scriptLabels.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
