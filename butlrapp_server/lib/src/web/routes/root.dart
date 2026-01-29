import 'package:butlrapp_server/src/web/widgets/built_with_serverpod_page.dart';
import 'package:serverpod/serverpod.dart';

class RootRoute extends WidgetRoute {
  @override
  Future<TemplateWidget> build(Session session, Request request) async {
    return TemplateWidget(
      name: 'redirect',
      template: '<!DOCTYPE html><html><head><meta http-equiv="refresh" content="0; url=/app/"></head><body>Redirecting to app...</body></html>',
      values: {},
    );
  }
}
