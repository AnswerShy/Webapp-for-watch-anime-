import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedScreen = 0;

  final List<Widget> _screens = [
    const textFieldsWidget(),
    AboutPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Anime", style: TextStyle(
            fontSize: 32
          )),
          centerTitle: true,
        ),
        body: _screens[_selectedScreen],
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.menu),
              label: "Menu",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.info),
              label: "About",
            )
          ],
          currentIndex: _selectedScreen,
          onTap: (index) {
            setState(() {
              _selectedScreen = index;
            });
          },
        ),
      )
    );
  }

}

class textFieldsWidget extends StatefulWidget {
  const textFieldsWidget({super.key});

  @override
  _textFieldsWidget createState() => _textFieldsWidget();
}

class _textFieldsWidget extends State<textFieldsWidget>{
  bool loading = true;
  List<Anime> animeList = [];
  int? hoveredIndex;
  @override
  void initState() {
    super.initState();
    fetchAnimeList();
  }

  Future<void> fetchAnimeList() async {
    try {
      final response = await http.get(Uri.parse('https://ukranime-backend.fly.dev/api/anime_info'));

      if (response.statusCode == 200) {
        setState(() {
          animeList = (jsonDecode(response.body) as List)
              .map((json) => Anime.fromJson(json))
              .toList();
          loading = false;
        });
      } else {
        throw Exception('Failed to load anime data');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Anime List')),
      body: loading ? Center(child: CircularProgressIndicator()) : 
      ListView.builder(
        itemCount: animeList.length,
        itemBuilder: (context, index) {
          final anime = animeList[index];
          return ListTile(
            leading: Image.network(anime.poster, width: 50, height: 50,),
            title: Text(anime.title),
            subtitle: Text('Episodes: ${anime.episodes}; Genres: ${anime.genres.map((e){return e;})}'),
          );
        },
      )
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child:  Text(
        "Panka Kyrylo",
        style: TextStyle(
          fontSize: 64,
        ),
      ),
    );
  }
}

class Anime {
  final String title;
  final int episodes;
  final String poster;
  final List<String> genres;
  final String releaseDate;
  final String banner;
  final String description;

  Anime({
    required this.title,
    required this.episodes,
    required this.poster,
    required this.genres,
    required this.releaseDate,
    required this.banner,
    required this.description,
  });

  factory Anime.fromJson(Map<String, dynamic> json) => Anime(
    title: json['Title'],
    episodes: json['Episodes'],
    poster: json['Poster'],
    genres: List<String>.from(json['Genres']),
    releaseDate: json['Release_date'],
    banner: json['Banner'],
    description: json['Description'],
  );
}