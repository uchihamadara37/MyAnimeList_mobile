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
  Set<String> _selectedGenres = {};
  String? _selectedRating;
  double _selectedMinScore = 0.0;
  // Tambahkan state untuk filter lain jika diperlukan (rating, genre, dll.)

  @override
  void initState() {
    super.initState();
    // Initialize _selectedStatus from provider if needed
    _selectedStatus =
        Provider.of<AnimeProvider>(context, listen: false).currentStatusFilter;
    _selectedGenres =
        Provider.of<AnimeProvider>(context, listen: false).currentGenreFilter;
    _selectedRating =
        Provider.of<AnimeProvider>(context, listen: false).currentRatingFilter;
    _selectedMinScore =
        Provider.of<AnimeProvider>(
          context,
          listen: false,
        ).currentMinScoreFilter;

    if (_selectedStatus != null && _selectedStatus!.isEmpty) {
      _selectedStatus = null;
    }
    if (_selectedGenres.isEmpty) {
      _selectedGenres = {};
    }
    if (_selectedRating != null && _selectedRating!.isEmpty) {
      _selectedRating = null;
    }

    print('Initial selected status: $_selectedStatus');
  }

  @override
  Widget build(BuildContext context) {
    final animeProvider = Provider.of<AnimeProvider>(context, listen: false);
    // Contoh daftar status (bisa diambil dari API atau hardcode)
    final List<Map<String, String>> statusOptions = [
      {'value': '', 'display': 'Semua Status'},
      {'value': 'airing', 'display': 'On-going'},
      {'value': 'complete', 'display': 'Selesai rilis'},
      {'value': 'upcoming', 'display': 'Akan Datang'},
    ];

    // Variabel yang mungkin Anda miliki di state halaman atau provider
    List<Map<String, dynamic>> allAvailableGenres =
        Provider.of<AnimeProvider>(context, listen: false).genres;
    // print('Available genres: $allAvailableGenres');
    // [
    //   'Action',
    //   'Adventure',
    //   'Comedy',
    //   'Drama',
    //   'Fantasy',
    //   'Sci-Fi',
    //   'Slice of Life',
    //   'Sports',
    //   'Supernatural',
    //   'Thriller',
    // ];
    List<Map<String, String>> allAvailableRatings = [
      {'value': 'g', 'display': 'G - All Ages'},
      {'value': 'pg', 'display': 'PG - Children'},
      {'value': 'pg13', 'display': 'PG-13 - Teens 13+'},
      {'value': 'r17', 'display': 'R - 17+ (Violence & Profanity)'},
      // {'value': 'r', 'display': 'R+ - Mild Nudity'},
      // {'value': 'rx', 'display': 'Rx - Hentai'}
    ];

    // Set<String> currentSelectedGenres = {};

    return AlertDialog(
      title: Text('Filter Anime'),
      content: SingleChildScrollView(
        // Use SingleChildScrollView for longer filter lists
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Status Filter
            Text(
              'Status:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 5),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              dropdownColor: Colors.grey[700],
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[600],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              hint: Text(
                'Pilih status',
                style: TextStyle(color: Colors.white54),
              ),
              items:
                  statusOptions.map((status) {
                    return DropdownMenuItem<String>(
                      value: status['value'],
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color:
                              status['value'] == _selectedStatus ||
                                      (_selectedStatus == null &&
                                          status['value'] == "")
                                  ? Colors.blue.shade400
                                  : Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          status['display']!,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedStatus = newValue;
                });
              },
            ),
            SizedBox(height: 20),
            // Genre Filter
            Text(
              'Genre',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Container(
              padding: const EdgeInsets.all(0.0),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children:
                    allAvailableGenres.map((genre) {
                      final isSelected = _selectedGenres.contains(genre["mal_id"].toString());
                      return FilterChip(
                        label: Text(
                          genre['name'] ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 11, // 1. Perkecil ukuran font jika perlu
                            color: (isSelected) ? Colors.white : Colors.white70,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedGenres.add(
                                genre["mal_id"].toString(),
                              ); // Menggunakan _tempSelectedGenres dari contoh filter sebelumnya
                            } else {
                              _selectedGenres.remove(
                                genre["mal_id"].toString(),
                              ); // Menggunakan _tempSelectedGenres dari contoh filter sebelumnya
                            }
                          });
                        },
                        backgroundColor: Colors.grey[700],
                        selectedColor: Colors.deepPurpleAccent,
                        checkmarkColor:
                            Colors.white, // Warna checkmark saat terpilih
                        // --- Properti untuk memperkecil padding/ukuran ---
                        labelPadding: EdgeInsets.symmetric(
                          horizontal: 6.0,
                          vertical: 0.0,
                        ), // 2. Padding di sekitar teks label
                        padding: EdgeInsets.all(
                          2.0,
                        ), // 3. Padding di sekitar seluruh konten chip (label & checkmark)
                        visualDensity:
                            VisualDensity
                                .compact, // 4. Membuat chip lebih ringkas
                        materialTapTargetSize:
                            MaterialTapTargetSize
                                .shrinkWrap, // 5. Mengurangi ukuran target sentuh

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            8.0,
                          ), // 6. Perkecil borderRadius agar lebih ringkas
                          side: BorderSide(
                            color:
                                isSelected
                                    ? Colors.deepPurpleAccent
                                    : Colors.grey[600]!,
                            width:
                                1.0, // Anda juga bisa mengatur ketebalan border
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),

            SizedBox(height: 20),

            // Rating Filter
            Text(
              'Rating',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedRating,
                dropdownColor: Colors.grey[700],
                decoration: InputDecoration(
                  border: InputBorder.none, // Menghilangkan border bawaan
                  hintText: 'Pilih Rating',
                  hintStyle: TextStyle(color: Colors.white54),
                ),
                isExpanded: true,
                items: [
                  // Opsi untuk "Semua Rating"
                  DropdownMenuItem<String>(
                    value:
                        null, // atau String kosong '' jika API Anda mengharapkannya
                    child: Text(
                      'Semua Rating',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  // Mapping dari list rating
                  ...allAvailableRatings.map((ratingMap) {
                    return DropdownMenuItem<String>(
                      value: ratingMap['value'],
                      child: Text(
                        ratingMap['display']!,
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRating = newValue;
                  });
                },
                style: TextStyle(color: Colors.white),
              ),
            ),

            const SizedBox(height: 20.0),

            // Minimum Score Filter
            Text(
              'Skor Minimum: ${_selectedMinScore.toStringAsFixed(1)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 0.0),
            Slider(
              value: _selectedMinScore,
              min: 0.0,
              max: 10.0,
              divisions:
                  20, // (10 - 0) / 0.5 = 20, untuk step 0.5. Atau 100 untuk step 0.1
              label: _selectedMinScore.toStringAsFixed(1),
              activeColor: Colors.deepPurpleAccent,
              inactiveColor: Colors.grey[600],
              onChanged: (double value) {
                setState(() {
                  _selectedMinScore = value;
                });
              },
            ),
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
            print('Applying filters:');
            print('Selected Status: $_selectedStatus');
            print('Selected Genres: $_selectedGenres');
            print('Selected Rating: $_selectedRating');
            print('Selected Minimum Score: $_selectedMinScore');

            animeProvider.applyStatusFilter(
              _selectedStatus ?? "",
              _selectedGenres,
              _selectedRating ?? "",
              _selectedMinScore,
            );
            print('Filters applied successfully');

            // Terapkan filter lain jika ada
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
