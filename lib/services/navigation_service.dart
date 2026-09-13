import 'package:flutter/material.dart';

/// Global navigation and scaffold messenger keys to allow navigation
/// and global notification banners (e.g. on session expiration) without BuildContext.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> appMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
