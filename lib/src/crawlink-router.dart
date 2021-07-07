import 'package:crawlink/crawlink.dart';
import 'package:flutter/widgets.dart';

/// Router trigger infromation
class CrawlinkRouter {
  /// URL for routing
  /// * e.g.
  ///
  /// ```dart
  /// path: '/'
  /// ```
  /// ```dart
  /// path: '/root/path/:id/view'
  /// ```
  final String path;

  /// Trigger when new url pushed to the navigator,
  /// Return [List<Page>]
  ///
  /// * e.g.
  ///
  /// ```dart
  /// onPush: (CrawlinkRoutePath path) => <Page>[HomePage(path:path)]
  /// ```
  final List<Page> Function(CrawlinkRoutePath path) onPages;

  /// Check the router path and return new path if check failed.
  /// Return a [CrawlinkRoutePath] path from onPush to navigate
  /// Return the same path parameter if no change on the route navigation.
  ///
  /// * e.g.
  ///
  /// ##### Default navigation
  /// ```dart
  /// onPush : (CrawlinkRoutePath path) async => path;
  /// ```
  /// ##### Custome navigation
  /// ```dart
  /// onPush : (CrawlinkRoutePath path) async {
  ///     // Do something
  ///     // Construct new path if required
  ///   return new CrawlinkRoutePath(url:<new Url>, params:<new parms>, data: <new data>)
  /// }
  /// ```
  final Future<CrawlinkRoutePath> Function(CrawlinkRoutePath path)? onPush;

  ///  Find the return the back path of current route
  ///
  /// * e.g.
  ///
  /// ##### Back navigation
  ///
  /// ```dart
  /// onPop : (CrawlinkRoutePath currentPath) {
  ///     // Do something
  ///     // Construct new path to display on back press
  ///   return new CrawlinkRoutePath(url:<new back Url>, params:<new parms>, data: <new data>)
  /// }
  /// ```
  final CrawlinkRoutePath Function(CrawlinkRoutePath path)? onPop;

  /// Resolve route data before actual navigation, this data can be retrived
  /// `path.data` in onPush
  ///
  /// * e.g.
  /// ```dart
  /// onResolve: (
  ///   CrawlinkRoutePath path, Map<String, dynamic> data) async{
  ///       // Prepare data to before route
  ///       // ...
  ///
  ///        return data;
  ///   }
  /// ```
  final Future<Map<String, dynamic>> Function(
      CrawlinkRoutePath path, Map<String, dynamic> data)? onResolve;

  final Widget Function(
    CrawlinkRoutePath path,
  )? onLoadingWidget;

  late Uri machableUri;

  CrawlinkRouter({
    required this.path,
    required this.onPages,
    this.onPush,
    this.onPop,
    this.onResolve,
    this.onLoadingWidget,
  }) {
    machableUri = Uri.parse('/').resolve(path);
  }
}
