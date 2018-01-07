final htmlTagA = new RegExp(r'\<a.*?href\=\\?"(' + urlSafeCharacters + r'*)\\?".*?\>(.*?)\<\/a\>', caseSensitive: false);
final urlSafeCharacters = r"[a-zA-Z0-9\-\.\_\~\:\/\?\#\[\]\@\!\$\&\'\(\)\*\+\,\;\=]";
final fullUri = new RegExp(r'(\S+)\:\/\/([^\/\s]+)([\S]*)', caseSensitive: false);
final looseUrl = new RegExp(r'((\S+)\:\/\/)?([^\/\s]+?\.[^\/\s]+)([\S]*)', caseSensitive: false);
