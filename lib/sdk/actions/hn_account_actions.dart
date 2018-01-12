import 'package:flutter_flux/flutter_flux.dart';

import 'package:hn_flutter/sdk/models/hn_account.dart';

final Action<HNAccount> addHNAccount = new Action();
final Action<String> removeHNAccount = new Action();
final Action<String> setPrimaryHNAccount = new Action();
