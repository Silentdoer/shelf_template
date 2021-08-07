import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import 'package:shelf_template/app_config.dart';
import 'package:shelf_template/middlewares/auth_middleware.dart';

void main(List<String> arguments) async {
  var config = AppConfig();
  // 先添加的中间件先处理请求，因此先添加的是在逻辑处理的最外围
  config.addMiddleware(logRequests()).addMiddleware(AuthMiddleware()());
  config.enableStaticResource = false;

  var server = await shelf_io.serve(config(), '0.0.0.0', 8888);
  // 设置到内存上的，因此是实时生效的
  server.autoCompress = true;

  print('Serving at http://${server.address.host}:${server.port}');
}
