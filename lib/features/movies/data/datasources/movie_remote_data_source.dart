import 'dart:async';
import '../models/movie_model.dart';
import '../models/movie_detail_model.dart';
import '../models/genre_model.dart';
import '../../../../core/network/api_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class MovieRemoteDataSource {
  Future<List<MovieModel>> getNowPlayingMovies();
  Future<List<MovieModel>> getPopularMovies();
  Future<List<MovieModel>> getTopRatedMovies();
  Future<MovieDetailModel> getMovieDetails(int id);
  Future<List<MovieModel>> searchMovies(String query);
}

class MovieRemoteDataSourceImpl implements MovieRemoteDataSource {
  final ApiClient _apiClient;

  MovieRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<MovieModel>> getNowPlayingMovies() async {
    final response = await _apiClient.dio.get('/movie/now_playing');
    return _parseMovieList(response.data);
  }

  @override
  Future<List<MovieModel>> getPopularMovies() async {
    final response = await _apiClient.dio.get('/movie/popular');
    return _parseMovieList(response.data);
  }

  @override
  Future<List<MovieModel>> getTopRatedMovies() async {
    final response = await _apiClient.dio.get('/movie/top_rated');
    return _parseMovieList(response.data);
  }

  @override
  Future<MovieDetailModel> getMovieDetails(int id) async {
    final response = await _apiClient.dio.get('/movie/$id');
    return MovieDetailModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<MovieModel>> searchMovies(String query) async {
    final response = await _apiClient.dio.get(
      '/search/movie',
      queryParameters: {'query': query},
    );
    return _parseMovieList(response.data);
  }

  List<MovieModel> _parseMovieList(dynamic data) {
    final results = data['results'] as List<dynamic>?;
    if (results == null) return [];
    return results
        .map((m) => MovieModel.fromJson(m as Map<String, dynamic>))
        .toList();
  }
}

class MockMovieRemoteDataSourceImpl implements MovieRemoteDataSource {
  MockMovieRemoteDataSourceImpl();

  // Artificial delay to make shimmers look alive
  Future<void> _simulateDelay() => Future.delayed(const Duration(milliseconds: 600));

  @override
  Future<List<MovieModel>> getNowPlayingMovies() async {
    await _simulateDelay();
    return _mockNowPlaying;
  }

  @override
  Future<List<MovieModel>> getPopularMovies() async {
    await _simulateDelay();
    return _mockPopular;
  }

  @override
  Future<List<MovieModel>> getTopRatedMovies() async {
    await _simulateDelay();
    return _mockTopRated;
  }

  @override
  Future<MovieDetailModel> getMovieDetails(int id) async {
    await _simulateDelay();
    final allDetails = [..._mockDetailsNowPlaying, ..._mockDetailsPopular, ..._mockDetailsTopRated];
    final match = allDetails.firstWhere(
      (m) => m.id == id,
      orElse: () => _mockDetailsNowPlaying.first,
    );
    return match;
  }

  @override
  Future<List<MovieModel>> searchMovies(String query) async {
    await _simulateDelay();
    if (query.isEmpty) return [];
    final allMovies = {..._mockNowPlaying, ..._mockPopular, ..._mockTopRated}.toList();
    return allMovies
        .where((m) => m.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // --- MOCK DATA DATASETS ---
  
  static final List<MovieModel> _mockNowPlaying = [
    const MovieModel(
      id: 27205,
      title: 'Inception',
      overview: 'Cobb, a skilled thief who steals valuable secrets from deep within the subconscious during the dream state, is offered a chance to have his history erased as payment for a seemingly impossible task: "inception", the implantation of another person\'s idea into a target\'s subconscious.',
      posterPath: '/o0q4rfcc3CT9e2wzJuRv7SEZ7jF.jpg',
      backdropPath: '/8Zuzn22Aq4ny97o27iH251I1wJ7.jpg',
      releaseDate: '2010-07-15',
      voteAverage: 8.4,
      genreIds: [28, 878, 12],
    ),
    const MovieModel(
      id: 157336,
      title: 'Interstellar',
      overview: 'The adventures of a group of explorers who make use of a newly discovered wormhole to surpass the limitations on human space travel and conquer the vast distances involved in an interstellar voyage.',
      posterPath: '/gEU2QniE6E7vNIvXTLM3OI2C56A.jpg',
      backdropPath: '/p2ss06m25Im7Z18C2PLsuZg4Fc8.jpg',
      releaseDate: '2014-11-05',
      voteAverage: 8.4,
      genreIds: [12, 18, 878],
    ),
    const MovieModel(
      id: 299536,
      title: 'Avengers: Infinity War',
      overview: 'As the Avengers and their allies have continued to protect the world from threats too large for any one hero to handle, a new danger has emerged from the cosmic shadows: Thanos.',
      posterPath: '/7WsyCh634J4e4qUqN31336PA357.jpg',
      backdropPath: '/bOG171ZfX7pt5765j2uWnyp5D8M.jpg',
      releaseDate: '2018-04-25',
      voteAverage: 8.3,
      genreIds: [12, 28, 878],
    ),
    const MovieModel(
      id: 577922,
      title: 'Tenet',
      overview: 'Armed with only one word - Tenet - and fighting for the survival of the entire world, the Protagonist journeys through a twilight world of international espionage on a mission that will unfold in something beyond real time.',
      posterPath: '/a56Ifkkg5z4hb5IO2xrFFRLrznn.jpg',
      backdropPath: '/wZrx8jA51nEQ34eH5n444zsQ6Rt.jpg',
      releaseDate: '2020-08-22',
      voteAverage: 7.2,
      genreIds: [28, 878, 53],
    ),
  ];

  static final List<MovieModel> _mockPopular = [
    const MovieModel(
      id: 155,
      title: 'The Dark Knight',
      overview: 'Batman raises the stakes in his war on crime. With the help of Lt. Jim Gordon and District Attorney Harvey Dent, Batman sets out to dismantle the remaining criminal organizations that plague the streets.',
      posterPath: '/qJ2tWGB252r77G8Xhp7XLMQAxCD.jpg',
      backdropPath: '/nMKdUU7Pauqqg4iWDv0r1kgRzGB.jpg',
      releaseDate: '2008-07-16',
      voteAverage: 8.5,
      genreIds: [18, 28, 80, 53],
    ),
    const MovieModel(
      id: 680,
      title: 'Pulp Fiction',
      overview: 'A burger-loving hitman, his philosophical partner, a drug-addled gangster\'s moll, and a washed-up boxer converge in this sprawling, comedic crime caper. Their adventures unfollow in three stories.',
      posterPath: '/d5iIlvFJ20j7GKjnl5jAF0lhSj1.jpg',
      backdropPath: '/sua7g256176gIMRMfOI09NBRmBr.jpg',
      releaseDate: '1994-09-10',
      voteAverage: 8.5,
      genreIds: [53, 80],
    ),
    const MovieModel(
      id: 496243,
      title: 'Parasite',
      overview: 'All unemployed, Ki-taek\'s family takes peculiar interest in the wealthy and glamorous Parks for their livelihood until they get entangled in an unexpected incident.',
      posterPath: '/7IiTT10mX0gSS9axNV3xR5U45Es.jpg',
      backdropPath: '/tuFaF74B4A45w3wJ1vH47j819r5.jpg',
      releaseDate: '2019-05-30',
      voteAverage: 8.5,
      genreIds: [35, 18, 53],
    ),
    const MovieModel(
      id: 24428,
      title: 'The Avengers',
      overview: 'When an unexpected enemy emerges and threatens global safety and security, Nick Fury, director of the international peacekeeping agency known as S.H.I.E.L.D., finds himself in need of a team.',
      posterPath: '/RYMX2wcwHcbj6m08q5Et7htj9q.jpg',
      backdropPath: '/9BBGo4685v75YvJ2nux44m2i4Gg.jpg',
      releaseDate: '2012-04-25',
      voteAverage: 7.7,
      genreIds: [878, 28, 12],
    ),
  ];

  static final List<MovieModel> _mockTopRated = [
    const MovieModel(
      id: 238,
      title: 'The Godfather',
      overview: 'Spanning the years 1945 to 1955, a chronicle of the fictional Italian-American Corleone crime family. When organized crime family patriarch, Vito Corleone survives an attempt on his life, his youngest son, Michael, steps in.',
      posterPath: '/3bhkrj6PMMmSt9vP0tEyp00D4TY.jpg',
      backdropPath: '/tmU7GeKVXm6Sq5spaceWPPw6Cc65.jpg',
      releaseDate: '1972-03-14',
      voteAverage: 8.7,
      genreIds: [18, 80],
    ),
    const MovieModel(
      id: 244,
      title: 'Whiplash',
      overview: 'Under the direction of a ruthless instructor, a talented young drummer begins to pursue perfection at any cost, even his humanity.',
      posterPath: '/7ry4w4l05c7Eq7LU6j4ofUFgsiA.jpg',
      backdropPath: '/6A771v4729g64Cwzrrn8617560V.jpg',
      releaseDate: '2014-10-10',
      voteAverage: 8.4,
      genreIds: [18, 10402],
    ),
    const MovieModel(
      id: 129,
      title: 'Spirited Away',
      overview: 'A young girl, Chihiro, becomes trapped in a strange new world of spirits. When her parents undergo a mysterious transformation, she must call upon the courage she never knew she had to free her family.',
      posterPath: '/393mh1e064Fiy8fv75g5SZZTLpt.jpg',
      backdropPath: '/Ab8ZbvFSVOeAWuH6xZ2WJW07e48.jpg',
      releaseDate: '2001-07-20',
      voteAverage: 8.5,
      genreIds: [14, 16, 10751],
    ),
    const MovieModel(
      id: 278,
      title: 'The Shawshank Redemption',
      overview: 'Framed in the 1940s for the double murder of his wife and her lover, upstanding banker Andy Dufresne begins a new life at the Shawshank prison, where he puts his accounting skills to work for an amoral warden.',
      posterPath: '/9cqN0025o7T5TBi48tcl6yclcuT.jpg',
      backdropPath: '/kXfqK2UBmGhqRNSn4KK6FXrmG4Z.jpg',
      releaseDate: '1994-09-23',
      voteAverage: 8.7,
      genreIds: [18, 80],
    ),
  ];

  static final List<MovieDetailModel> _mockDetailsNowPlaying = [
    const MovieDetailModel(
      id: 27205,
      title: 'Inception',
      overview: 'Cobb, a skilled thief who steals valuable secrets from deep within the subconscious during the dream state, is offered a chance to have his history erased as payment for a seemingly impossible task: "inception", the implantation of another person\'s idea into a target\'s subconscious.',
      posterPath: '/o0q4rfcc3CT9e2wzJuRv7SEZ7jF.jpg',
      backdropPath: '/8Zuzn22Aq4ny97o27iH251I1wJ7.jpg',
      releaseDate: '2010-07-15',
      voteAverage: 8.4,
      runtime: 148,
      genres: [
        GenreModel(id: 28, name: 'Action'),
        GenreModel(id: 878, name: 'Science Fiction'),
        GenreModel(id: 12, name: 'Adventure'),
      ],
      tagline: 'Your mind is the scene of the crime.',
    ),
    const MovieDetailModel(
      id: 157336,
      title: 'Interstellar',
      overview: 'The adventures of a group of explorers who make use of a newly discovered wormhole to surpass the limitations on human space travel and conquer the vast distances involved in an interstellar voyage.',
      posterPath: '/gEU2QniE6E7vNIvXTLM3OI2C56A.jpg',
      backdropPath: '/p2ss06m25Im7Z18C2PLsuZg4Fc8.jpg',
      releaseDate: '2014-11-05',
      voteAverage: 8.4,
      runtime: 169,
      genres: [
        GenreModel(id: 12, name: 'Adventure'),
        GenreModel(id: 18, name: 'Drama'),
        GenreModel(id: 878, name: 'Science Fiction'),
      ],
      tagline: 'Mankind was born on Earth. It was never meant to die here.',
    ),
    const MovieDetailModel(
      id: 299536,
      title: 'Avengers: Infinity War',
      overview: 'As the Avengers and their allies have continued to protect the world from threats too large for any one hero to handle, a new danger has emerged from the cosmic shadows: Thanos. A despot of intergalactic infamy, his goal is to collect all six Infinity Stones, artifacts of unimaginable power, and use them to inflict his twisted will on all of reality.',
      posterPath: '/7WsyCh634J4e4qUqN31336PA357.jpg',
      backdropPath: '/bOG171ZfX7pt5765j2uWnyp5D8M.jpg',
      releaseDate: '2018-04-25',
      voteAverage: 8.3,
      runtime: 149,
      genres: [
        GenreModel(id: 12, name: 'Adventure'),
        GenreModel(id: 28, name: 'Action'),
        GenreModel(id: 878, name: 'Science Fiction'),
      ],
      tagline: 'An entire universe. Once and for all.',
    ),
    const MovieDetailModel(
      id: 577922,
      title: 'Tenet',
      overview: 'Armed with only one word - Tenet - and fighting for the survival of the entire world, the Protagonist journeys through a twilight world of international espionage on a mission that will unfold in something beyond real time. Not time travel. Inversion.',
      posterPath: '/a56Ifkkg5z4hb5IO2xrFFRLrznn.jpg',
      backdropPath: '/wZrx8jA51nEQ34eH5n444zsQ6Rt.jpg',
      releaseDate: '2020-08-22',
      voteAverage: 7.2,
      runtime: 150,
      genres: [
        GenreModel(id: 28, name: 'Action'),
        GenreModel(id: 878, name: 'Science Fiction'),
        GenreModel(id: 53, name: 'Thriller'),
      ],
      tagline: 'Time runs out.',
    ),
  ];

  static final List<MovieDetailModel> _mockDetailsPopular = [
    const MovieDetailModel(
      id: 155,
      title: 'The Dark Knight',
      overview: 'Batman raises the stakes in his war on crime. With the help of Lt. Jim Gordon and District Attorney Harvey Dent, Batman sets out to dismantle the remaining criminal organizations that plague the streets. The partnership proves to be effective, but they soon find themselves prey to a reign of chaos unleashed by a rising criminal mastermind known to the terrified citizens of Gotham as the Joker.',
      posterPath: '/qJ2tWGB252r77G8Xhp7XLMQAxCD.jpg',
      backdropPath: '/nMKdUU7Pauqqg4iWDv0r1kgRzGB.jpg',
      releaseDate: '2008-07-16',
      voteAverage: 8.5,
      runtime: 152,
      genres: [
        GenreModel(id: 18, name: 'Drama'),
        GenreModel(id: 28, name: 'Action'),
        GenreModel(id: 80, name: 'Crime'),
        GenreModel(id: 53, name: 'Thriller'),
      ],
      tagline: 'Why So Serious?',
    ),
    const MovieDetailModel(
      id: 680,
      title: 'Pulp Fiction',
      overview: 'A burger-loving hitman, his philosophical partner, a drug-addled gangster\'s moll, and a washed-up boxer converge in this sprawling, comedic crime caper. Their adventures unfold in three stories that weave together in an offbeat non-linear narrative.',
      posterPath: '/d5iIlvFJ20j7GKjnl5jAF0lhSj1.jpg',
      backdropPath: '/sua7g256176gIMRMfOI09NBRmBr.jpg',
      releaseDate: '1994-09-10',
      voteAverage: 8.5,
      runtime: 154,
      genres: [
        GenreModel(id: 53, name: 'Thriller'),
        GenreModel(id: 80, name: 'Crime'),
      ],
      tagline: 'Just because you are a character doesn\'t mean that you have character.',
    ),
    const MovieDetailModel(
      id: 496243,
      title: 'Parasite',
      overview: 'All unemployed, Ki-taek\'s family takes peculiar interest in the wealthy and glamorous Parks for their livelihood until they get entangled in an unexpected incident.',
      posterPath: '/7IiTT10mX0gSS9axNV3xR5U45Es.jpg',
      backdropPath: '/tuFaF74B4A45w3wJ1vH47j819r5.jpg',
      releaseDate: '2019-05-30',
      voteAverage: 8.5,
      runtime: 132,
      genres: [
        GenreModel(id: 35, name: 'Comedy'),
        GenreModel(id: 18, name: 'Drama'),
        GenreModel(id: 53, name: 'Thriller'),
      ],
      tagline: 'Act like you own the place.',
    ),
    const MovieDetailModel(
      id: 24428,
      title: 'The Avengers',
      overview: 'When an unexpected enemy emerges and threatens global safety and security, Nick Fury, director of the international peacekeeping agency known as S.H.I.E.L.D., finds himself in need of a team to pull the world back from the brink of disaster. Spanning the globe, a daring recruitment effort begins.',
      posterPath: '/RYMX2wcwHcbj6m08q5Et7htj9q.jpg',
      backdropPath: '/9BBGo4685v75YvJ2nux44m2i4Gg.jpg',
      releaseDate: '2012-04-25',
      voteAverage: 7.7,
      runtime: 143,
      genres: [
        GenreModel(id: 878, name: 'Science Fiction'),
        GenreModel(id: 28, name: 'Action'),
        GenreModel(id: 12, name: 'Adventure'),
      ],
      tagline: 'Some assembly required.',
    ),
  ];

  static final List<MovieDetailModel> _mockDetailsTopRated = [
    const MovieDetailModel(
      id: 238,
      title: 'The Godfather',
      overview: 'Spanning the years 1945 to 1955, a chronicle of the fictional Italian-American Corleone crime family. When organized crime family patriarch, Vito Corleone survives an attempt on his life, his youngest son, Michael, steps in to take care of the would-be killers, launching a campaign of bloody revenge.',
      posterPath: '/3bhkrj6PMMmSt9vP0tEyp00D4TY.jpg',
      backdropPath: '/tmU7GeKVXm6Sq5spaceWPPw6Cc65.jpg',
      releaseDate: '1972-03-14',
      voteAverage: 8.7,
      runtime: 175,
      genres: [
        GenreModel(id: 18, name: 'Drama'),
        GenreModel(id: 80, name: 'Crime'),
      ],
      tagline: 'An offer you can\'t refuse.',
    ),
    const MovieDetailModel(
      id: 244,
      title: 'Whiplash',
      overview: 'Under the direction of a ruthless instructor, a talented young drummer begins to pursue perfection at any cost, even his humanity.',
      posterPath: '/7ry4w4l05c7Eq7LU6j4ofUFgsiA.jpg',
      backdropPath: '/6A771v4729g64Cwzrrn8617560V.jpg',
      releaseDate: '2014-10-10',
      voteAverage: 8.4,
      runtime: 107,
      genres: [
        GenreModel(id: 18, name: 'Drama'),
        GenreModel(id: 10402, name: 'Music'),
      ],
      tagline: 'Not quite my tempo.',
    ),
    const MovieDetailModel(
      id: 129,
      title: 'Spirited Away',
      overview: 'A young girl, Chihiro, becomes trapped in a strange new world of spirits. When her parents undergo a mysterious transformation, she must call upon the courage she never knew she had to free her family and return to the human world.',
      posterPath: '/393mh1e064Fiy8fv75g5SZZTLpt.jpg',
      backdropPath: '/Ab8ZbvFSVOeAWuH6xZ2WJW07e48.jpg',
      releaseDate: '2001-07-20',
      voteAverage: 8.5,
      runtime: 125,
      genres: [
        GenreModel(id: 14, name: 'Fantasy'),
        GenreModel(id: 16, name: 'Animation'),
        GenreModel(id: 10751, name: 'Family'),
      ],
      tagline: 'Nothing that happens is ever forgotten, even if you can\'t remember it.',
    ),
    const MovieDetailModel(
      id: 278,
      title: 'The Shawshank Redemption',
      overview: 'Framed in the 1940s for the double murder of his wife and her lover, upstanding banker Andy Dufresne begins a new life at the Shawshank prison, where he puts his accounting skills to work for an amoral warden. During his long years in prison, he befriends a fellow inmate named Red and helps them keep hope alive.',
      posterPath: '/9cqN0025o7T5TBi48tcl6yclcuT.jpg',
      backdropPath: '/kXfqK2UBmGhqRNSn4KK6FXrmG4Z.jpg',
      releaseDate: '1994-09-23',
      voteAverage: 8.7,
      runtime: 142,
      genres: [
        GenreModel(id: 18, name: 'Drama'),
        GenreModel(id: 80, name: 'Crime'),
      ],
      tagline: 'Fear can hold you prisoner. Hope can set you free.',
    ),
  ];
}

class DynamicMovieRemoteDataSourceImpl implements MovieRemoteDataSource {
  final ApiClient _apiClient;
  late final MovieRemoteDataSource _realDataSource;
  late final MovieRemoteDataSource _mockDataSource;

  DynamicMovieRemoteDataSourceImpl(this._apiClient) {
    _realDataSource = MovieRemoteDataSourceImpl(_apiClient);
    _mockDataSource = MockMovieRemoteDataSourceImpl();
  }

  MovieRemoteDataSource get _activeDataSource {
    final envKey = dotenv.env['TMDB_API_KEY'] ?? '';
    final hasKey = envKey.trim().isNotEmpty;
    if (!hasKey) {
      return _mockDataSource;
    }
    return _realDataSource;
  }

  @override
  Future<List<MovieModel>> getNowPlayingMovies() => _activeDataSource.getNowPlayingMovies();

  @override
  Future<List<MovieModel>> getPopularMovies() => _activeDataSource.getPopularMovies();

  @override
  Future<List<MovieModel>> getTopRatedMovies() => _activeDataSource.getTopRatedMovies();

  @override
  Future<MovieDetailModel> getMovieDetails(int id) => _activeDataSource.getMovieDetails(id);

  @override
  Future<List<MovieModel>> searchMovies(String query) => _activeDataSource.searchMovies(query);
}
