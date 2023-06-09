import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'package:tpm_prak_final/api/data_source.dart';
import 'package:tpm_prak_final/pages/anime_detail_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<String>('bookmarked_anime_titles');
  await SharedPreferences.getInstance();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AnimePage(onBookmark: (String ) {  },),
    );
  }
}

class AnimePage extends StatefulWidget {
  final Function(String) onBookmark;

  const AnimePage({Key? key, required this.onBookmark}) : super(key: key);

  @override
  _AnimePageState createState() => _AnimePageState();
}

class _AnimePageState extends State<AnimePage> {
  final List<String> categories = ['Top', 'Movie', 'TV', 'Airing', 'Upcoming', 'Completed'];
  final List<String> sorting = ['Select', 'Asc', 'Desc'];
  final List<String> orderBy = ['Select', 'Rank', 'Score', 'Popularity', 'Favorites'];

  String chosenCategory = 'Top';
  String chosenSorting = 'Select';
  String chosenOrderBy = 'Select';

  int currentPage = 1;
  bool isInFirstPage = true;

  bool isTopChosen = true;
  Box<String>? bookmarkedAnimeBox;
  List<String> bookmarkedAnimeTitles = [];

  @override
  void initState() {
    super.initState();
    _openBox();
    _loadBookmarkedAnimeTitles();
  }


  Future<void> _openBox() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
    bookmarkedAnimeBox = await Hive.openBox<String>('bookmarked_anime_titles');
  }

  Future<void> _loadBookmarkedAnimeTitles() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    bookmarkedAnimeTitles = sharedPreferences.getStringList('bookmarked_anime_titles') ?? [];
  }


  Future<void> _saveBookmarkedAnimeTitles() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setStringList('bookmarked_anime_titles', bookmarkedAnimeTitles);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _categoriesField(),
          _orderSortingField(),
          _bookmarkButton(),
          _animeListField(),
        ],
      ),
    );
  }

  Widget _categoriesField() {
    return Container(
      padding: const EdgeInsets.all(10),
      height: MediaQuery.of(context).size.height / 12,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
            width: 120,
            height: 15,
            child: OutlinedButton(
              child: Text(
                categories[index],
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              style: ElevatedButton.styleFrom(
                primary: identical(chosenCategory, categories[index]) ? Colors.red : Colors.white,
                onPrimary: identical(chosenCategory, categories[index]) ? Colors.white : Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                setState(() {
                  chosenCategory = categories[index];
                  if (chosenCategory != 'Top') {
                    isTopChosen = false;
                  }
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _orderSortingField() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      height: MediaQuery.of(context).size.height / 12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              const Text(
                'Order by: ',
              ),
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                width: 100,
                child: DropdownButton(
                  value: chosenOrderBy,
                  icon: const Icon(
                    Icons.arrow_downward,
                    size: 15,
                  ),
                  items: orderBy.map((String orderBy) {
                    return DropdownMenuItem(
                      value: orderBy,
                      child: Text(orderBy),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      chosenOrderBy = newValue!;
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.15),
          Row(
            children: [
              const Text(
                'Sorting: ',
              ),
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                width: 100,
                child: DropdownButton(
                  value: chosenSorting,
                  icon: const Icon(
                    Icons.arrow_downward,
                    size: 15,
                  ),
                  items: sorting.map((String sorting) {
                    return DropdownMenuItem(
                      value: sorting,
                      child: Text(sorting),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      chosenSorting = newValue!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bookmarkButton() {
    return ElevatedButton(
      onPressed: () async {
        await _saveBookmarkedAnimeTitles(); // Save bookmarked anime titles before navigating
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookmarkedAnimePage(bookmarkedAnimeTitles: bookmarkedAnimeTitles),
          ),
        );
      },
      child: const Text('Bookmarked Anime'),
    );
  }


  Widget _animeListField() {
    return Expanded(
      child: FutureBuilder<List<dynamic>>(
        future: DataSource.instance.loadAnimeList(chosenCategory, chosenOrderBy, chosenSorting),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error in fetching the data.'),
            );
          } else if (snapshot.hasData && snapshot.data != null) {
            return _buildSuccessSection(snapshot);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Widget _buildSuccessSection(AsyncSnapshot<List<dynamic>> data) {
    final animeList = data.data!;
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 250,
        childAspectRatio: 3 / 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: animeList.length,
      itemBuilder: (context, index) {
        final anime = animeList[index];
        final animeTitle = anime['titles'][0]['title'];
        final isBookmarked = bookmarkedAnimeTitles.contains(animeTitle);

        return Card(
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AnimeDetailPage(animeData: anime),
                ),
              );
            },
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        anime['images']['jpg']['image_url'],
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    animeTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20, bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            anime['aired']['prop']['from']['year'].toString(),
                          ),
                          Text(
                            'Score: ' + anime['score'].toString(),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20, bottom: 10),
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            if (isBookmarked) {
                              bookmarkedAnimeTitles.remove(animeTitle);
                            } else {
                              bookmarkedAnimeTitles.add(animeTitle);
                            }
                            _saveBookmarkedAnimeTitles();
                          });
                        },
                        icon: Icon(
                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color: isBookmarked ? Colors.red : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class BookmarkedAnimePage extends StatelessWidget {
  final List<String> bookmarkedAnimeTitles;

  const BookmarkedAnimePage({Key? key, required this.bookmarkedAnimeTitles}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarked Anime'),
      ),
      body: ListView.builder(
        itemCount: bookmarkedAnimeTitles.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(bookmarkedAnimeTitles[index]),
          );
        },
      ),
    );
  }
}
