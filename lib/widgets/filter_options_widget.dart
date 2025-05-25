import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Import AnimeProvider
import '../providers/anime_providers.dart'; // Path might need adjustment

class FilterOptionsWidget extends StatefulWidget {
  @override
  _FilterOptionsWidgetState createState() => _FilterOptionsWidgetState();
}

class _FilterOptionsWidgetState extends State<FilterOptionsWidget> {
  String? _selectedStatus;
  // Tambahkan state untuk filter lain jika diperlukan (rating, genre, dll.)

  @override
  void initState() {
    super.initState();
    // Initialize _selectedStatus from provider if needed
    _selectedStatus = Provider.of<AnimeProvider>(context, listen: false).currentStatusFilter;
    if (_selectedStatus != null && _selectedStatus!.isEmpty) _selectedStatus = null;
  }

  @override
  Widget build(BuildContext context) {
    final animeProvider = Provider.of<AnimeProvider>(context, listen: false);
    // Contoh daftar status (bisa diambil dari API atau hardcode)
    final List<Map<String, String>> statusOptions = [
      {'value': '', 'display': 'Semua Status'},
      {'value': 'airing', 'display': 'Sedang Tayang'},
      {'value': 'complete', 'display': 'Selesai Tayang'},
      {'value': 'upcoming', 'display': 'Akan Datang'},
    ];

    return AlertDialog(
      title: Text('Filter Anime'),
      content: SingleChildScrollView( // Use SingleChildScrollView for longer filter lists
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Status:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              dropdownColor: Colors.grey[700],
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[600],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              hint: Text('Pilih status', style: TextStyle(color: Colors.white54)),
              items: statusOptions.map((status) {
                return DropdownMenuItem<String>(
                  value: status['value'],
                  child: Text(status['display']!, style: TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedStatus = newValue;
                });
              },
            ),
            SizedBox(height: 20),
            // Tambahkan filter lain di sini (Rating, Genre)
            // Contoh Genre (membutuhkan data genre dari provider)
            // if (animeProvider.genres.isNotEmpty && !animeProvider.isLoadingGenres) ...[
            //   Text('Genre:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            //   // Implementasi dropdown atau multi-select untuk genre
            // ] else if (animeProvider.isLoadingGenres) ...[
            //   Center(child: CircularProgressIndicator(strokeWidth: 2))
            // ],
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Reset', style: TextStyle(color: Colors.orangeAccent)),
          onPressed: () {
            setState(() {
              _selectedStatus = null;
            });
            animeProvider.clearFilters();
            // Navigator.of(context).pop(); // Optionally close dialog after reset
          },
        ),
        TextButton(
          child: Text('Batal', style: TextStyle(color: Colors.white70)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: Text('Terapkan'),
          onPressed: () {
            if (_selectedStatus != null) {
              animeProvider.applyStatusFilter(_selectedStatus!);
            } else {
              animeProvider.applyStatusFilter(''); // Atau cara lain untuk clear filter status
            }
            // Terapkan filter lain jika ada
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}