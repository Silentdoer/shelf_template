import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_hotreload/shelf_hotreload.dart';
import 'package:shelf_template/app_config.dart';
import 'package:shelf_template/middlewares/auth_middleware.dart';

/// 保存代码后会自动hotreload，hotreload大概花费两秒
/// dart --enable-vm-service bin/shelf_template_debug.dart
/// 还可以以debug模式运行，比如VSCode的Start Debugging(F5)
void main(List<String> args) {
  withHotreload(() async {
    var config = AppConfig();
    // 先添加的中间件先处理请求，因此先添加的是在逻辑处理的最外围
    config.addMiddleware(logRequests()).addMiddleware(AuthMiddleware()());
    config.enableStaticResource = false;

    var server = await shelf_io.serve(config(), '0.0.0.0', 8888);
    // 设置到内存上的，因此是实时生效的
    server.autoCompress = true;

    print('Serving at http://${server.address.host}:${server.port}');
    return server;
  });
}
