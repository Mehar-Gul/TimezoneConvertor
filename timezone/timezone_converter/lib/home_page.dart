import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'format.dart';
import 'zones.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CityZone _source = zoneByLabel('London, UK');
  DateTime _wallClock = DateTime.now();
  bool _followNow = true;
  bool _use24h = true;
  List<String> _selected = [
    'New York, USA',
    'London, UK',
    'Berlin, Germany',
    'New Delhi, India',
    'Tokyo, Japan',
    'Sydney, Australia',
  ];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (_followNow) setState(() => _wallClock = _nowInSource());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('cities');
    final src = prefs.getString('source');
    final h24 = prefs.getBool('use24h');
    setState(() {
      if (saved != null && saved.isNotEmpty) _selected = saved;
      if (src != null) _source = zoneByLabel(src);
      if (h24 != null) _use24h = h24;
      _wallClock = _nowInSource();
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('cities', _selected);
    await prefs.setString('source', _source.label);
    await prefs.setBool('use24h', _use24h);
  }

  DateTime _nowInSource() => _source.toLocal(DateTime.now().toUtc());

  DateTime get _utc => _source.toUtc(_wallClock);

  Future<void> _pickSource() async {
    final picked = await _pickCity(exclude: const []);
    if (picked == null) return;
    setState(() {
      _source = picked;
      if (_followNow) _wallClock = _nowInSource();
    });
    _save();
  }

  Future<CityZone?> _pickCity({required List<String> exclude}) {
    return showModalBottomSheet<CityZone>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _CityPicker(exclude: exclude, referenceUtc: _utc),
    );
  }

  Future<void> _addCity() async {
    final picked = await _pickCity(exclude: _selected);
    if (picked == null) return;
    setState(() => _selected = [..._selected, picked.label]);
    _save();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _wallClock,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_wallClock),
    );
    if (time == null) return;
    setState(() {
      _followNow = false;
      _wallClock =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    final utc = _utc;
    final rows = _selected.map(zoneByLabel).toList()
      ..sort((a, b) => a.offsetMinutes(utc).compareTo(b.offsetMinutes(utc)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Zone Converter'),
        actions: [
          IconButton(
            tooltip: _use24h ? 'Switch to 12-hour' : 'Switch to 24-hour',
            onPressed: () {
              setState(() => _use24h = !_use24h);
              _save();
            },
            icon: Text(_use24h ? '24h' : '12h',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sourceCard(utc),
          const SizedBox(height: 16),
          Text('Comparison',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...rows.map((z) => _zoneTile(z, utc)),
          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCity,
        icon: const Icon(Icons.add),
        label: const Text('Add city'),
      ),
    );
  }

  Widget _sourceCard(DateTime utc) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('FROM',
                style: TextStyle(
                    letterSpacing: 1.5,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary)),
            const SizedBox(height: 6),
            InkWell(
              onTap: _pickSource,
              child: Row(
                children: [
                  Expanded(
                    child: Text(_source.label,
                        style: Theme.of(context).textTheme.titleLarge),
                  ),
                  const Icon(Icons.expand_more),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(formatTime(_wallClock, _use24h),
                    style: const TextStyle(
                        fontSize: 40, fontWeight: FontWeight.w600)),
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '${_source.abbr(utc)} · ${formatOffset(_source.offsetMinutes(utc))}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
            Text(formatDate(_wallClock),
                style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _pickDateTime,
                  icon: const Icon(Icons.edit_calendar_outlined, size: 18),
                  label: const Text('Set date & time'),
                ),
                const SizedBox(width: 8),
                FilledButton.tonalIcon(
                  onPressed: () => setState(() {
                    _followNow = true;
                    _wallClock = _nowInSource();
                  }),
                  icon: const Icon(Icons.schedule, size: 18),
                  label: const Text('Now'),
                ),
              ],
            ),
            if (_followNow)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('Live · updates automatically',
                    style: TextStyle(
                        fontSize: 12, color: Colors.green.shade700)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _zoneTile(CityZone z, DateTime utc) {
    final local = z.toLocal(utc);
    final diff = z.offsetMinutes(utc) - _source.offsetMinutes(utc);
    final isDay = local.hour >= 7 && local.hour < 19;
    final dayShift = local.day != _wallClock.day
        ? (local.isAfter(_wallClock) ? ' (next day)' : ' (prev day)')
        : '';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Icon(isDay ? Icons.light_mode : Icons.dark_mode,
            color: isDay ? Colors.amber.shade700 : Colors.indigo.shade400),
        title: Text(z.label, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
            '${formatDate(local)}$dayShift · ${z.abbr(utc)} ${formatOffset(z.offsetMinutes(utc))} · ${formatDiff(diff)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(formatTime(local, _use24h),
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w600)),
            IconButton(
              tooltip: 'Remove',
              icon: const Icon(Icons.close, size: 18),
              onPressed: () {
                setState(() =>
                    _selected = _selected.where((c) => c != z.label).toList());
                _save();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CityPicker extends StatefulWidget {
  const _CityPicker({required this.exclude, required this.referenceUtc});
  final List<String> exclude;
  final DateTime referenceUtc;

  @override
  State<_CityPicker> createState() => _CityPickerState();
}

class _CityPickerState extends State<_CityPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final items = allZones
        .where((z) => !widget.exclude.contains(z.label))
        .where((z) => z.label.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search city or country',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final z = items[i];
                  return ListTile(
                    title: Text(z.label),
                    subtitle: Text(
                        '${z.abbr(widget.referenceUtc)} · ${formatOffset(z.offsetMinutes(widget.referenceUtc))}'),
                    trailing: Text(
                        formatTime(z.toLocal(widget.referenceUtc), true)),
                    onTap: () => Navigator.pop(context, z),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
