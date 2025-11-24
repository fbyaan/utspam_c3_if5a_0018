import 'package:flutter/material.dart';

/// Utility class untuk manage route observer
/// Digunakan untuk tracking navigation events di aplikasi
class RouteObserverUtil {
  static final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
}

/// Custom Route Observer untuk logging dan analytics
class CustomRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  
  /// Called when a route is pushed onto the navigator.
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) {
      _logRouteChange('PUSH', route.settings.name, previousRoute?.settings.name);
    }
  }

  /// Called when a route is popped off the navigator.
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (route is PageRoute) {
      _logRouteChange('POP', route.settings.name, previousRoute?.settings.name);
    }
  }

  /// Called when a route is replaced in the navigator.
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute is PageRoute) {
      _logRouteChange('REPLACE', newRoute.settings.name, oldRoute?.settings.name);
    }
  }

  /// Called when a route is removed from the navigator.
  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    if (route is PageRoute) {
      _logRouteChange('REMOVE', route.settings.name, previousRoute?.settings.name);
    }
  }

  /// Log route changes for debugging and analytics
  void _logRouteChange(String action, String? currentRoute, String? previousRoute) {
    final timestamp = DateTime.now().toIso8601String();
    debugPrint('[$timestamp] ROUTE $action: $previousRoute -> $currentRoute');
    
    // Bisa ditambahkan analytics tracking di sini
    // Contoh: Firebase Analytics, Sentry, dll.
    _trackRouteAnalytics(currentRoute, action);
  }

  /// Track route changes for analytics
  void _trackRouteAnalytics(String? routeName, String action) {
    // Implementasi analytics tracking bisa ditambahkan di sini
    // Contoh untuk Firebase Analytics:
    /*
    FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'screen_name': routeName,
        'action': action,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
    */
    
    // Atau untuk custom analytics:
    if (routeName != null) {
      debugPrint('Analytics: Screen $routeName viewed with action $action');
    }
  }
}

/// Mixin untuk memudahkan penggunaan route awareness di State classes
mixin RouteAwareMixin<T extends StatefulWidget> on State<T> implements RouteAware {
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route observer ketika dependencies berubah
    RouteObserverUtil.routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    // Unsubscribe dari route observer ketika widget di-dispose
    RouteObserverUtil.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPop() {
    // Called when the current route has been popped off.
    debugPrint('Route popped: ${ModalRoute.of(context)?.settings.name}');
  }

  @override
  void didPopNext() {
    // Called when the top route has been popped off, and the current route shows up.
    debugPrint('Returned to: ${ModalRoute.of(context)?.settings.name}');
  }

  @override
  void didPush() {
    // Called when the current route has been pushed.
    debugPrint('Route pushed: ${ModalRoute.of(context)?.settings.name}');
  }

  @override
  void didPushNext() {
    // Called when a new route has been pushed, and the current route is no longer visible.
    debugPrint('Navigated away from: ${ModalRoute.of(context)?.settings.name}');
  }
}

/// Extension untuk memudahkan navigation dengan route observer
extension RouteObserverExtension on NavigatorState {
  
  /// Push named route dengan route observer support
  Future<T?> pushNamedWithObserver<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return pushNamed<T>(routeName, arguments: arguments);
  }

  /// Push replacement named route dengan route observer support
  Future<T?> pushReplacementNamedWithObserver<T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) {
    return pushReplacementNamed<T, TO>(
      routeName,
      result: result,
      arguments: arguments,
    );
  }

  /// Push and remove until dengan route observer support
  Future<T?> pushNamedAndRemoveUntilWithObserver<T extends Object?>(
    String newRouteName,
    RoutePredicate predicate, {
    Object? arguments,
  }) {
    return pushNamedAndRemoveUntil<T>(
      newRouteName,
      predicate,
      arguments: arguments,
    );
  }
}

/// Helper class untuk route names management
class RouteNames {
  static const String rentalHistory = '/rental-history';
  static const String rentalDetail = '/rental-detail';
  static const String carList = '/car-list';
  static const String home = '/';
  
  // Tambahkan route names lainnya di sini
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String login = '/login';
}

/// Custom Page Route dengan enhanced functionality
class CustomPageRoute<T> extends PageRouteBuilder<T> {
  final WidgetBuilder builder;
  final String routeName;
  final bool fullscreenDialog;

  CustomPageRoute({
    required this.builder,
    required this.routeName,
    this.fullscreenDialog = false,
  }) : super(
          settings: RouteSettings(name: routeName),
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              builder(context),
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(
            opacity: animation,
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 300),
          fullscreenDialog: fullscreenDialog,
        );
}