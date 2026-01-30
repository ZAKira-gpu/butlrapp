import 'package:serverpod/serverpod.dart';

class RootRoute extends WidgetRoute {
  @override
  Future<WebWidget> build(Session session, Request request) async {
    return RedirectWidget(url: '/app/');
  }
}
