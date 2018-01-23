import 'package:flutter_flux/flutter_flux.dart';
import 'package:tuple/tuple.dart';

import 'package:hn_flutter/sdk/stores/ui_store.dart';

final Action<int> selectItem = new Action();
final Action<SortModes> setStorySortMode = new Action();
final Action<Tuple2<int, double>> setStoryScrollPos = new Action();
