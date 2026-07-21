import 'dart:async';
import '../models/tv_show_model.dart';
import '../models/tv_show_detail_model.dart';
import '../../../movies/data/models/genre_model.dart';
import '../../../../core/network/api_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class TVShowRemoteDataSource {
  Future<List<TVShowModel>> getAiringTodayTVShows();
  Future<List<TVShowModel>> getPopularTVShows();
  Future<List<TVShowModel>> getTopRatedTVShows();
  Future<TVShowDetailModel> getTVShowDetails(int id);
  Future<List<TVShowModel>> searchTVShows(String query);
}

class TVShowRemoteDataSourceImpl implements TVShowRemoteDataSource {
  final ApiClient _apiClient;

  TVShowRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<TVShowModel>> getAiringTodayTVShows() async {
    final response = await _apiClient.dio.get('/tv/airing_today');
    return _parseTVShowList(response.data);
  }

  @override
  Future<List<TVShowModel>> getPopularTVShows() async {
    final response = await _apiClient.dio.get('/tv/popular');
    return _parseTVShowList(response.data);
  }

  @override
  Future<List<TVShowModel>> getTopRatedTVShows() async {
    final response = await _apiClient.dio.get('/tv/top_rated');
    return _parseTVShowList(response.data);
  }

  @override
  Future<TVShowDetailModel> getTVShowDetails(int id) async {
    final response = await _apiClient.dio.get(
      '/tv/$id',
      queryParameters: {
        'append_to_response': 'images',
        'include_image_language': 'en,null',
      },
    );
    return TVShowDetailModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<TVShowModel>> searchTVShows(String query) async {
    final response = await _apiClient.dio.get(
      '/search/tv',
      queryParameters: {'query': query},
    );
    return _parseTVShowList(response.data);
  }

  List<TVShowModel> _parseTVShowList(dynamic data) {
    final results = data['results'] as List<dynamic>?;
    if (results == null) return [];
    return results
        .map((s) => TVShowModel.fromJson(s as Map<String, dynamic>))
        .toList();
  }
}

class MockTVShowRemoteDataSourceImpl implements TVShowRemoteDataSource {
  MockTVShowRemoteDataSourceImpl();

  Future<void> _simulateDelay() => Future.delayed(const Duration(milliseconds: 600));

  @override
  Future<List<TVShowModel>> getAiringTodayTVShows() async {
    await _simulateDelay();
    return _mockAiringToday;
  }

  @override
  Future<List<TVShowModel>> getPopularTVShows() async {
    await _simulateDelay();
    return _mockPopular;
  }

  @override
  Future<List<TVShowModel>> getTopRatedTVShows() async {
    await _simulateDelay();
    return _mockTopRated;
  }

  @override
  Future<TVShowDetailModel> getTVShowDetails(int id) async {
    await _simulateDelay();
    final allDetails = [..._mockDetailsAiringToday, ..._mockDetailsPopular, ..._mockDetailsTopRated];
    final match = allDetails.firstWhere(
      (s) => s.id == id,
      orElse: () => _mockDetailsAiringToday.first,
    );
    return match;
  }

  @override
  Future<List<TVShowModel>> searchTVShows(String query) async {
    await _simulateDelay();
    if (query.isEmpty) return [];
    final allShows = {..._mockAiringToday, ..._mockPopular, ..._mockTopRated}.toList();
    return allShows
        .where((s) => s.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // --- MOCK TV SHOW DATASETS ---
  
  static final List<TVShowModel> _mockAiringToday = [
    const TVShowModel(
      id: 1396,
      name: 'Breaking Bad',
      overview: 'Walter White, a New Mexico chemistry teacher, is diagnosed with Stage III cancer and given a prognosis of two years to live. He becomes filled with a sense of fearlessness and an unrelenting desire to secure his family\'s financial future at any cost as he enters the dangerous world of drugs and crime.',
      posterPath: '/ztkUQVk6e9uH415vA6gHYAcqHG1.jpg',
      backdropPath: '/9faAn1mg5ty2nTHTdev7KF4chRk.jpg',
      firstAirDate: '2008-01-20',
      voteAverage: 8.9,
      genreIds: [18, 80],
    ),
    const TVShowModel(
      id: 66732,
      name: 'Stranger Things',
      overview: 'When a young boy vanishes, a small town uncovers a mystery involving secret experiments, terrifying supernatural forces and one strange little girl.',
      posterPath: '/49WJfeN0mhmN3IP4674gRzvFkU4.jpg',
      backdropPath: '/56v2DnL5aKuIMXLIUry67kJuQ24.jpg',
      firstAirDate: '2016-07-15',
      voteAverage: 8.6,
      genreIds: [18, 10765, 968],
    ),
    const TVShowModel(
      id: 1399,
      name: 'Game of Thrones',
      overview: 'Seven noble families fight for control of the mythical land of Westeros. Friction between the houses leads to full-scale war. All while a very ancient evil awakens in the farthest North.',
      posterPath: '/1XS12oi8zGh44NIvUF2WgxlYwGh.jpg',
      backdropPath: '/2OMB0722168vT8B06rHj6nDw42c.jpg',
      firstAirDate: '2011-04-17',
      voteAverage: 8.4,
      genreIds: [18, 10759, 10765],
    ),
    const TVShowModel(
      id: 87108,
      name: 'Chernobyl',
      overview: 'The dramatization of the true story of one of the worst man-made catastrophes in history, the Chernobyl Nuclear Power Plant disaster in April 1986, and the sacrifices made to save Europe from unimaginable disaster.',
      posterPath: '/hlLXt2t76zxJgKPNXZ6zRHYbgEv.jpg',
      backdropPath: '/900tO0CKNFD6gGg56Ex0FunO97r.jpg',
      firstAirDate: '2019-05-06',
      voteAverage: 8.6,
      genreIds: [18],
    ),
  ];

  static final List<TVShowModel> _mockPopular = [
    const TVShowModel(
      id: 100088,
      name: 'The Last of Us',
      overview: 'Twenty years after modern civilization has been destroyed, Joel, a hardened survivor, is hired to smuggle Ellie, a 14-year-old girl, out of an oppressive quarantine zone. What starts as a small job soon becomes a brutal, heartbreaking journey.',
      posterPath: '/uKvH5j205H7A217XZ489g35K7ds.jpg',
      backdropPath: '/uDgy6hyPd62jScw69Ty0t6qCj6n.jpg',
      firstAirDate: '2023-01-15',
      voteAverage: 8.6,
      genreIds: [18, 10759, 10765],
    ),
    const TVShowModel(
      id: 76479,
      name: 'Succession',
      overview: 'The Roy family is known for controlling the biggest media and entertainment company in the world. However, their world changes when their father steps down.',
      posterPath: '/7Y5ur03yydZ58sziiw548t63GJa.jpg',
      backdropPath: '/eZ53C474D9Qf14vN5p71Lpx3Swh.jpg',
      firstAirDate: '2018-06-03',
      voteAverage: 8.3,
      genreIds: [18],
    ),
    const TVShowModel(
      id: 76341,
      name: 'The Boys',
      overview: 'A fun, gritty, and dark take on what happens when superheroes—who are as popular as celebrities—abuse their superpowers rather than use them for good.',
      posterPath: '/7g1xUrA36g69614cM5z076Fp9Yy.jpg',
      backdropPath: '/n9WDX14364z8msh19fS9b08f4yA.jpg',
      firstAirDate: '2019-07-25',
      voteAverage: 8.5,
      genreIds: [10759, 10765],
    ),
    const TVShowModel(
      id: 139362,
      name: 'The Bear',
      overview: 'A young chef from the fine dining world returns to Chicago to run his family sandwich shop after a heartbreaking death.',
      posterPath: '/545xR5yB53jZqF7eW5zI1mJbM7Q.jpg',
      backdropPath: '/366914569c7eZ9vM839qD9Y3t3w.jpg',
      firstAirDate: '2022-06-23',
      voteAverage: 8.5,
      genreIds: [18, 35],
    ),
  ];

  static final List<TVShowModel> _mockTopRated = [
    const TVShowModel(
      id: 33137,
      name: 'Band of Brothers',
      overview: 'The story of Easy Company of the U.S. Army 101st Airborne Division, and their mission in World War II Europe, from Operation Overlord, through D-Day, and up to V-J Day.',
      posterPath: '/z2y7Q1W1o7Tz31Y1o7Tz31Y1o7T.jpg',
      backdropPath: '/h3g4Q65m1o7Tz31Y1o7Tz31Y1o7.jpg',
      firstAirDate: '2001-09-09',
      voteAverage: 9.1,
      genreIds: [18, 10768],
    ),
    const TVShowModel(
      id: 1438,
      name: 'The Wire',
      overview: 'Told from the points of view of both the homicide detectives and the drug dealers they are investigating, this series captures a world where easy distinctions between good and evil are non-existent.',
      posterPath: '/ogGs2QniE6E7vNIvXTLM3OI2C56A.jpg',
      backdropPath: '/eYmB03m25Im7Z18C2PLsuZg4Fc8.jpg',
      firstAirDate: '2002-06-02',
      voteAverage: 8.6,
      genreIds: [18, 80],
    ),
    const TVShowModel(
      id: 60625,
      name: 'Rick and Morty',
      overview: 'Rick is a mentally-unbalanced but scientifically gifted old man who has recently reconnected with his family. He spends most of his time involving his young grandson Morty in dangerous, outlandish adventures throughout space and alternate universes.',
      posterPath: '/cvBoNDPO2u0Y6a6mG01o5FzO5r6.jpg',
      backdropPath: '/mzz4GW7g2t29mOIvXTLM3OI2C56.jpg',
      firstAirDate: '2013-12-02',
      voteAverage: 8.7,
      genreIds: [16, 35, 10765],
    ),
    const TVShowModel(
      id: 19885,
      name: 'Sherlock',
      overview: 'A modern update finds the famous sleuth and his doctor partner solving crime in 21st century London.',
      posterPath: '/f9z31Y1o7Tz31Y1o7Tz31Y1o7Tz.jpg',
      backdropPath: '/5A771v4729g64Cwzrrn8617560V.jpg',
      firstAirDate: '2010-07-25',
      voteAverage: 8.5,
      genreIds: [18, 968, 80],
    ),
  ];

  static final List<TVShowDetailModel> _mockDetailsAiringToday = [
    const TVShowDetailModel(
      id: 1396,
      name: 'Breaking Bad',
      overview: 'Walter White, a New Mexico chemistry teacher, is diagnosed with Stage III cancer and given a prognosis of two years to live. He becomes filled with a sense of fearlessness and an unrelenting desire to secure his family\'s financial future at any cost as he enters the dangerous world of drugs and crime.',
      posterPath: '/ztkUQVk6e9uH415vA6gHYAcqHG1.jpg',
      backdropPath: '/9faAn1mg5ty2nTHTdev7KF4chRk.jpg',
      firstAirDate: '2008-01-20',
      voteAverage: 8.9,
      numberOfEpisodes: 62,
      numberOfSeasons: 5,
      genres: [
        GenreModel(id: 18, name: 'Drama'),
        GenreModel(id: 80, name: 'Crime'),
      ],
      tagline: 'All Hail the King.',
    ),
    const TVShowDetailModel(
      id: 66732,
      name: 'Stranger Things',
      overview: 'When a young boy vanishes, a small town uncovers a mystery involving secret experiments, terrifying supernatural forces and one strange little girl.',
      posterPath: '/49WJfeN0mhmN3IP4674gRzvFkU4.jpg',
      backdropPath: '/56v2DnL5aKuIMXLIUry67kJuQ24.jpg',
      firstAirDate: '2016-07-15',
      voteAverage: 8.6,
      numberOfEpisodes: 34,
      numberOfSeasons: 4,
      genres: [
        GenreModel(id: 18, name: 'Drama'),
        GenreModel(id: 10765, name: 'Sci-Fi & Fantasy'),
        GenreModel(id: 968, name: 'Mystery'),
      ],
      tagline: 'One summer can change everything.',
    ),
    const TVShowDetailModel(
      id: 1399,
      name: 'Game of Thrones',
      overview: 'Seven noble families fight for control of the mythical land of Westeros. Friction between the houses leads to full-scale war. All while a very ancient evil awakens in the farthest North.',
      posterPath: '/1XS12oi8zGh44NIvUF2WgxlYwGh.jpg',
      backdropPath: '/2OMB0722168vT8B06rHj6nDw42c.jpg',
      firstAirDate: '2011-04-17',
      voteAverage: 8.4,
      numberOfEpisodes: 73,
      numberOfSeasons: 8,
      genres: [
        GenreModel(id: 18, name: 'Drama'),
        GenreModel(id: 10759, name: 'Action & Adventure'),
        GenreModel(id: 10765, name: 'Sci-Fi & Fantasy'),
      ],
      tagline: 'Winter is Coming.',
    ),
    const TVShowDetailModel(
      id: 87108,
      name: 'Chernobyl',
      overview: 'The dramatization of the true story of one of the worst man-made catastrophes in history, the Chernobyl Nuclear Power Plant disaster in April 1986, and the sacrifices made to save Europe from unimaginable disaster.',
      posterPath: '/hlLXt2t76zxJgKPNXZ6zRHYbgEv.jpg',
      backdropPath: '/900tO0CKNFD6gGg56Ex0FunO97r.jpg',
      firstAirDate: '2019-05-06',
      voteAverage: 8.6,
      numberOfEpisodes: 5,
      numberOfSeasons: 1,
      genres: [
        GenreModel(id: 18, name: 'Drama'),
      ],
      tagline: 'What is the cost of lies?',
    ),
  ];

  static final List<TVShowDetailModel> _mockDetailsPopular = [
    const TVShowDetailModel(
      id: 100088,
      name: 'The Last of Us',
      overview: 'Twenty years after modern civilization has been destroyed, Joel, a hardened survivor, is hired to smuggle Ellie, a 14-year-old girl, out of an oppressive quarantine zone. What starts as a small job soon becomes a brutal, heartbreaking journey.',
      posterPath: '/uKvH5j205H7A217XZ489g35K7ds.jpg',
      backdropPath: '/uDgy6hyPd62jScw69Ty0t6qCj6n.jpg',
      firstAirDate: '2023-01-15',
      voteAverage: 8.6,
      numberOfEpisodes: 9,
      numberOfSeasons: 1,
      genres: [
        GenreModel(id: 18, name: 'Drama'),
        GenreModel(id: 10759, name: 'Action & Adventure'),
        GenreModel(id: 10765, name: 'Sci-Fi & Fantasy'),
      ],
      tagline: 'When you\'re lost in the darkness, look for the light.',
    ),
    const TVShowDetailModel(
      id: 76479,
      name: 'Succession',
      overview: 'The Roy family is known for controlling the biggest media and entertainment company in the world. However, their world changes when their father steps down.',
      posterPath: '/7Y5ur03yydZ58sziiw548t63GJa.jpg',
      backdropPath: '/eZ53C474D9Qf14vN5p71Lpx3Swh.jpg',
      firstAirDate: '2018-06-03',
      voteAverage: 8.3,
      numberOfEpisodes: 39,
      numberOfSeasons: 4,
      genres: [
        GenreModel(id: 18, name: 'Drama'),
      ],
      tagline: 'Make your move.',
    ),
    const TVShowDetailModel(
      id: 76341,
      name: 'The Boys',
      overview: 'A fun, gritty, and dark take on what happens when superheroes—who are as popular as celebrities—abuse their superpowers rather than use them for good.',
      posterPath: '/7g1xUrA36g69614cM5z076Fp9Yy.jpg',
      backdropPath: '/n9WDX14364z8msh19fS9b08f4yA.jpg',
      firstAirDate: '2019-07-25',
      voteAverage: 8.5,
      numberOfEpisodes: 32,
      numberOfSeasons: 4,
      genres: [
        GenreModel(id: 10759, name: 'Action & Adventure'),
        GenreModel(id: 10765, name: 'Sci-Fi & Fantasy'),
      ],
      tagline: 'Never meet your heroes.',
    ),
    const TVShowDetailModel(
      id: 139362,
      name: 'The Bear',
      overview: 'A young chef from the fine dining world returns to Chicago to run his family sandwich shop after a heartbreaking death.',
      posterPath: '/545xR5yB53jZqF7eW5zI1mJbM7Q.jpg',
      backdropPath: '/366914569c7eZ9vM839qD9Y3t3w.jpg',
      firstAirDate: '2022-06-23',
      voteAverage: 8.5,
      numberOfEpisodes: 28,
      numberOfSeasons: 3,
      genres: [
        GenreModel(id: 18, name: 'Drama'),
        GenreModel(id: 35, name: 'Comedy'),
      ],
      tagline: 'Every second counts.',
    ),
  ];

  static final List<TVShowDetailModel> _mockDetailsTopRated = [
    const TVShowDetailModel(
      id: 33137,
      name: 'Band of Brothers',
      overview: 'The story of Easy Company of the U.S. Army 101st Airborne Division, and their mission in World War II Europe, from Operation Overlord, through D-Day, and up to V-J Day.',
      posterPath: '/z2y7Q1W1o7Tz31Y1o7Tz31Y1o7T.jpg',
      backdropPath: '/h3g4Q65m1o7Tz31Y1o7Tz31Y1o7.jpg',
      firstAirDate: '2001-09-09',
      voteAverage: 9.1,
      numberOfEpisodes: 10,
      numberOfSeasons: 1,
      genres: [
        GenreModel(id: 18, name: 'Drama'),
        GenreModel(id: 10768, name: 'War & Politics'),
      ],
      tagline: 'They stood together as brothers.',
    ),
    const TVShowDetailModel(
      id: 1438,
      name: 'The Wire',
      overview: 'Told from the points of view of both the homicide detectives and the drug dealers they are investigating, this series captures a world where easy distinctions between good and evil are non-existent.',
      posterPath: '/ogGs2QniE6E7vNIvXTLM3OI2C56A.jpg',
      backdropPath: '/eYmB03m25Im7Z18C2PLsuZg4Fc8.jpg',
      firstAirDate: '2002-06-02',
      voteAverage: 8.6,
      numberOfEpisodes: 60,
      numberOfSeasons: 5,
      genres: [
        GenreModel(id: 18, name: 'Drama'),
        GenreModel(id: 80, name: 'Crime'),
      ],
      tagline: 'Listen carefully.',
    ),
    const TVShowDetailModel(
      id: 60625,
      name: 'Rick and Morty',
      overview: 'Rick is a mentally-unbalanced but scientifically gifted old man who has recently reconnected with his family. He spends most of his time involving his young grandson Morty in dangerous, outlandish adventures throughout space and alternate universes.',
      posterPath: '/cvBoNDPO2u0Y6a6mG01o5FzO5r6.jpg',
      backdropPath: '/mzz4GW7g2t29mOIvXTLM3OI2C56.jpg',
      firstAirDate: '2013-12-02',
      voteAverage: 8.7,
      numberOfEpisodes: 74,
      numberOfSeasons: 7,
      genres: [
        GenreModel(id: 16, name: 'Animation'),
        GenreModel(id: 35, name: 'Comedy'),
        GenreModel(id: 10765, name: 'Sci-Fi & Fantasy'),
      ],
      tagline: 'Wubba Lubba Dub Dub!',
    ),
    const TVShowDetailModel(
      id: 19885,
      name: 'Sherlock',
      overview: 'A modern update finds the famous sleuth and his doctor partner solving crime in 21st century London.',
      posterPath: '/f9z31Y1o7Tz31Y1o7Tz31Y1o7Tz.jpg',
      backdropPath: '/5A771v4729g64Cwzrrn8617560V.jpg',
      firstAirDate: '2010-07-25',
      voteAverage: 8.5,
      numberOfEpisodes: 13,
      numberOfSeasons: 4,
      genres: [
        GenreModel(id: 18, name: 'Drama'),
        GenreModel(id: 968, name: 'Mystery'),
        GenreModel(id: 80, name: 'Crime'),
      ],
      tagline: 'A new sleuth for the 21st century.',
    ),
  ];
}

class DynamicTVShowRemoteDataSourceImpl implements TVShowRemoteDataSource {
  final ApiClient _apiClient;
  late final TVShowRemoteDataSource _realDataSource;
  late final TVShowRemoteDataSource _mockDataSource;

  DynamicTVShowRemoteDataSourceImpl(this._apiClient) {
    _realDataSource = TVShowRemoteDataSourceImpl(_apiClient);
    _mockDataSource = MockTVShowRemoteDataSourceImpl();
  }

  TVShowRemoteDataSource get _activeDataSource {
    final envKey = dotenv.env['TMDB_API_KEY'] ?? '';
    final hasKey = envKey.trim().isNotEmpty;
    if (!hasKey) {
      return _mockDataSource;
    }
    return _realDataSource;
  }

  @override
  Future<List<TVShowModel>> getAiringTodayTVShows() => _activeDataSource.getAiringTodayTVShows();

  @override
  Future<List<TVShowModel>> getPopularTVShows() => _activeDataSource.getPopularTVShows();

  @override
  Future<List<TVShowModel>> getTopRatedTVShows() => _activeDataSource.getTopRatedTVShows();

  @override
  Future<TVShowDetailModel> getTVShowDetails(int id) => _activeDataSource.getTVShowDetails(id);

  @override
  Future<List<TVShowModel>> searchTVShows(String query) => _activeDataSource.searchTVShows(query);
}
