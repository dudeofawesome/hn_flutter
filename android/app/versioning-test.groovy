def androidMaxVersionCode = 2100000000

assert calc('0.12.0') == 1200999
assert calc('0.12.10') == 1210999
assert calc('0.12.10-10') == 1210010
assert calc('10.12.10-10') == 101210010
assert calc('10.0.0') == 100000999
assert calc('10.0.10-10') == 100010010

assert calc('0.12.10-0') < calc('0.12.10-12')
assert calc('0.12.10-12') < calc('0.12.10')
assert calc('0.12.10') < calc('0.12.11')
assert calc('0.12.11') < calc('0.13.0')
assert calc('0.13.0') < calc('0.13.10')
assert calc('0.13.10') < calc('1.0.0')
assert calc('1.0.0') < calc('1.0.1')
assert androidMaxVersionCode < Integer.MAX_VALUE
assert calc('99.0.0') < androidMaxVersionCode
assert calc('99.0.0') < androidMaxVersionCode
assert calc('209.99.99-99') < androidMaxVersionCode

def calc (flutterVersionName) {
    println('~~ ' + flutterVersionName + ' ~~')
    def flutterVersionCode = ''


    def segmentLength = [2, 2, 2, 3]

    def split = flutterVersionName
        .tokenize('.')
        .collect { it.tokenize('-') }
        .flatten()
    if (split.size() < 4) {
        split[3] = '999'
    }

    for (int i = 0; i < split.size(); i++) {
        split[i] = split[i]?.padLeft(segmentLength[i], '0')
    }
    flutterVersionCode = split.join().toInteger()



    println(flutterVersionCode)
    return flutterVersionCode
}
