final htmlTagA = new RegExp(r'\<a.*?href\=\\?"([a-z0-9\/\-_\.:\&\?\=\#\%]*)\\?".*?\>(.*?)\<\/a\>', caseSensitive: false);
final fullUri = new RegExp(r'(\S+)\:\/\/([^\/\s]+)([\S]*)', caseSensitive: false);
final looseUrl = new RegExp(r'((\S+)\:\/\/)?([^\/\s]+?\.[^\/\s]+)([\S]*)', caseSensitive: false);
