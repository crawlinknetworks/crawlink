import 'dart:async';

import 'package:crawlink/crawlink.dart';
import 'package:flutter/material.dart';

/// Extract path information from location/url
class CrawlinkRoutePath {
  late String activePath;
  late String initialPath;

  Map<String, dynamic> data;

  CrawlinkRouter? router;
  List<Page>? pages;
  Size? _screenSize;
  bool _isSmallScreen = true;

  Completer? completer;

  late final Uri machableUri;
  late final Uri activeUri;
  late final Uri absoluteUri;
  CrawlinkRoutePath? historyPath;

  late final RouteInformation routeInformation;

  CrawlinkRoutePath({
    required this.activePath,
    required this.initialPath,
    this.completer,
    Map<String, String> params = const {},
    this.data = const {},
    this.historyPath,
  }) {
    machableUri = Uri.parse(activePath);
    activeUri = _parsePath(activePath, params);

    absoluteUri = Uri.parse(initialPath).resolveUri(activeUri);
    routeInformation = RouteInformation(location: absoluteUri.toString());
  }

  Uri _parsePath(String currentPath, Map<String, String> givenParams) {
    Uri uri = Uri.parse(currentPath).normalizePath();
    List<String> paths = [];
    // Map<String, String> params = {};
    uri.pathSegments.forEach((String segment) {
      if (segment.startsWith(':')) {
        var key = segment.substring(1);
        var value = givenParams[key] ?? '';
        paths.add(value);
        // params[key] = givenParams.remove(key) ?? '';
      } else {
        paths.add(segment);
      }
    });
    var path = paths.where((element) => element.trim().isNotEmpty).join('/');
    return Uri.parse(path);
    // ..queryParameters.addAll(givenParams);
  }

  /// Uri Query parameter
  Map<String, String> get queryParams => activeUri.queryParameters;

  /// Uri Query parameter
  List<String> get pathSegments => activeUri.pathSegments;

  /// Screen size, handle routing based on screen size
  Size? get screenSize => _screenSize;
  set screenSize(size) => _screenSize = size;

  /// Screen size, handle routing based on screen size, default true
  bool get isSmallScreen => _isSmallScreen;
  set isSmallScreen(enabled) => _isSmallScreen = enabled;

  @override
  String toString() {
    return activeUri.path;
  }
}
