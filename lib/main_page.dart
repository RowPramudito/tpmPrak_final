  import 'package:flutter/material.dart';
  import 'package:tpm_prak_final/pages/anime_page.dart';
  import 'package:tpm_prak_final/pages/profile_page.dart';
  import 'package:shared_preferences/shared_preferences.dart';

  class MainPage extends StatefulWidget {
    const MainPage({Key? key}) : super(key: key);

    @override
    State<MainPage> createState() => _MainPageState();
  }

  class _MainPageState extends State<MainPage> {
    List<String> appBarTitle = ['Anime', 'Watchlist', 'Profile'];
    int _selectedIndex = 0;
    SharedPreferences? _prefs;
    static const TextStyle optionStyle =
    TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
    late List<Widget> _widgetOptions;

    @override
    void initState() {
      super.initState();
      _widgetOptions = <Widget>[
        AnimePage(onBookmark: _saveBookmark),
        ProfilePage(),
      ];
      _initializeSharedPreferences();
    }


    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    Future<void> _initializeSharedPreferences() async {
      _prefs = await SharedPreferences.getInstance();
    }
    void _saveBookmark(String animeTitle) {
      if (_prefs != null) {
        final List<String> bookmarks = _prefs!.getStringList('bookmarks') ?? [];
        if (!bookmarks.contains(animeTitle)) {
          bookmarks.add(animeTitle);
          _prefs!.setStringList('bookmarks', bookmarks);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bookmark saved!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bookmark already exists!')),
          );
        }
      }
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('AniList'),
          backgroundColor: Colors.red,
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.movie),
              label: 'Anime',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.orange,
          unselectedItemColor: Colors.white,
          backgroundColor: Colors.red,
          onTap: _onItemTapped,
        ),
      );
    }
  }