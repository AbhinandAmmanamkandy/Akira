class ApiConstants {
  static const String anilabBaseUrl = 'https://anilab2.amdapi.click/api';
  static const String anidbBaseUrl = 'https://play.anidb.app/api';

  static const Map<String, String> headers = {
    'Accept': 'application/json',
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
  };

  static const Map<String, String> playerHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Referer': 'https://play.anidb.app/',
  };
}
