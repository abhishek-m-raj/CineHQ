enum Routes {
  home('/'),
  search('/search'),
  settings('/settings'),

  movieDetails('/movie/:id'),
  moviePlay('/play/movie/:id'),
  tvDetails('/tv/:id'),
  tvPlay('/play/tv/:id/:season/:episode'),

  logs('/logs');

  final String path;
  const Routes(this.path);
}
