import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/anime_providers.dart';
import '../utils/shared_prefs_util.dart';

class FilterOptionsWidget extends StatefulWidget {
  @override
  _FilterOptionsWidgetState createState() => _FilterOptionsWidgetState();
}

class _FilterOptionsWidgetState extends State<FilterOptionsWidget> {
  String? _selectedStatus;
  Set<String> _selectedGenres = {};
  String? _selectedRating;
  double _selectedMinScore = 0.0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final animeProvider = Provider.of<AnimeProvider>(context, listen: false);

      setState(() {
        _selectedStatus =
            animeProvider.currentStatusFilter.isEmpty
                ? null
                : animeProvider.currentStatusFilter;
        _selectedGenres = animeProvider.currentGenreFilter;
        _selectedRating =
            animeProvider.currentRatingFilter.isEmpty
                ? null
                : animeProvider.currentRatingFilter;
        _selectedMinScore = animeProvider.currentMinScoreFilter;
      });

      print('Initial selected status: $_selectedStatus');
    });
  }

  @override
  Widget build(BuildContext context) {
    final animeProvider = Provider.of<AnimeProvider>(context, listen: false);

    final statusOptions = [
      {'value': '', 'display': 'Semua Status'},
      {'value': 'airing', 'display': 'On-going'},
      {'value': 'complete', 'display': 'Selesai rilis'},
      {'value': 'upcoming', 'display': 'Akan Datang'},
    ];

    final genres = animeProvider.genres;
    final ratings = [
      {'value': 'g', 'display': 'G - All Ages'},
      {'value': 'pg', 'display': 'PG - Children'},
      {'value': 'pg13', 'display': 'PG-13 - Teens 13+'},
      {'value': 'r17', 'display': 'R - 17+ (Violence & Profanity)'},
    ];

    return AlertDialog(
      title: Text('Filter Anime'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
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
                      child: Text(
                        status['display']!,
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
              onChanged: (value) => setState(() => _selectedStatus = value),
            ),
            SizedBox(height: 20),
            Text(
              'Genre',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children:
                  genres.map((genre) {
                    final genreId = genre["mal_id"].toString();
                    final selected = _selectedGenres.contains(genreId);
                    return FilterChip(
                      label: Text(
                        genre['name'] ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 11,
                          color: selected ? Colors.white : Colors.white70,
                        ),
                      ),
                      selected: selected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedGenres.add(genreId);
                          } else {
                            _selectedGenres.remove(genreId);
                          }
                        });
                      },
                      backgroundColor: Colors.grey[700],
                      selectedColor: Colors.deepPurpleAccent,
                      checkmarkColor: Colors.white,
                      labelPadding: EdgeInsets.symmetric(horizontal: 6),
                      padding: EdgeInsets.all(2),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color:
                              selected
                                  ? Colors.deepPurpleAccent
                                  : Colors.grey[600]!,
                        ),
                      ),
                    );
                  }).toList(),
            ),
            SizedBox(height: 20),
            Text(
              'Rating',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedRating,
              dropdownColor: Colors.grey[700],
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Pilih Rating',
                hintStyle: TextStyle(color: Colors.white54),
              ),
              isExpanded: true,
              items: [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text(
                    'Semua Rating',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                ...ratings.map(
                  (r) => DropdownMenuItem<String>(
                    value: r['value'],
                    child: Text(
                      r['display']!,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
              onChanged: (val) => setState(() => _selectedRating = val),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20),
            Text(
              'Skor Minimum: ${_selectedMinScore.toStringAsFixed(1)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Slider(
              value: _selectedMinScore,
              min: 0,
              max: 10,
              divisions: 20,
              label: _selectedMinScore.toStringAsFixed(1),
              activeColor: Colors.deepPurpleAccent,
              inactiveColor: Colors.grey[600],
              onChanged: (val) => setState(() => _selectedMinScore = val),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              _selectedStatus = null;
              _selectedGenres.clear();
              _selectedRating = null;
              _selectedMinScore = 0.0;
            });
            animeProvider.clearFilters();
          },
          child: Text('Reset', style: TextStyle(color: Colors.orangeAccent)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Batal', style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          onPressed: () async {
            await SharedPrefsUtil.saveFilterPreferences(
              status: _selectedStatus ?? '',
              genres: _selectedGenres,
              rating: _selectedRating ?? '',
              minScore: _selectedMinScore,
            );
            animeProvider.applyStatusFilter(
              _selectedStatus ?? '',
              _selectedGenres,
              _selectedRating ?? '',
              _selectedMinScore,
            );
            Navigator.pop(context);
          },
          child: Text('Terapkan'),
        ),
      ],
    );
  }
}
