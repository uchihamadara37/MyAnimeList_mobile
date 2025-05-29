import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
//import 'package:my_anime_list_gemini/screens/anime_list_screen.dart';
import 'package:provider/provider.dart';
// import 'dart:io'; // Required for Platform.isAndroid, etc.

// Import Providers
import 'providers/anime_providers.dart';
import 'providers/bookmark_provider.dart';

// Import Screens
import 'screens/home_screen.dart';
import 'utils/shared_prefs_util.dart';

// Import Services (Database Helper needs to be initialized)
// import 'services/database_helper.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  await SharedPrefsUtil.saveLastOpened(); // Simpan saat aplikasi dibuka
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AnimeProvider()),
        ChangeNotifierProvider(create: (_) => BookmarkProvider()),
      ],
      child: MaterialApp(
        title: 'My Anime List',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          brightness: Brightness.dark, // Tema gelap agar lebih nyaman untuk aplikasi anime
          appBarTheme: AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.grey[900], // Warna AppBar
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            iconTheme: IconThemeData(color: Colors.white),
          ),
          scaffoldBackgroundColor: Colors.grey[850], // Warna latar belakang Scaffold
          cardTheme: CardThemeData(
            color: Colors.grey[800],
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          ),
          textTheme: TextTheme(
            bodyLarge: TextStyle(color: Colors.white70),
            bodyMedium: TextStyle(color: Colors.white60),
            titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[700],
            hintStyle: TextStyle(color: Colors.white38),
            labelStyle: TextStyle(color: Colors.white70),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Colors.grey[900],
            selectedItemColor: Colors.blue[100],
            unselectedItemColor: Colors.white54,
          ),
          dialogTheme: DialogThemeData(
            backgroundColor: Colors.grey[800],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            contentTextStyle: TextStyle(color: Colors.white70),
          ),
        ),
        home: HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}