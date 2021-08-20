import 'package:shelf/shelf.dart';
import 'package:shelf_template/support/abstract_controller.dart';
import 'package:shelf_template/support/api_result.dart';

class ExtState<D> extends ApiResultState<D> {
  int extData;

  ExtState(this.extData, D data) : super(data);

  @override
  Map<String, dynamic> toJson() => {'data': data, 'extData': extData};
}

class UserController extends AbstractController {
  UserController() : super('/user/');

  @override
  void config() {
    super.router.get('/shit', _shit);

    // userId是名字匹配，而[0-9]+则是约束userId的值类型和长度
    router.get('/nameById/<userId|[0-9]+>', _nameById);

    // <..>似乎只能用于pathVariable，所以这个其实匹配不到【以后也许会优化】
    router.get('/queryParam?foo=<foo>&aaa=<aaa>', _queryParam);

    router.post('/login', _login);

    router.get('/result1', (req) {
      var result = ApiResult.successExec();
      return Response.ok(result.toJsonString());
    });

    router.get('/result2', (req) {
      var result = ApiResult.successTask();
      return Response.ok(result.toJsonString());
    });

    router.get('/result3', (req) {
      var result = ApiResult.successExec(data: '时代峰峻了', message: '消息啊啊啊');
      return Response.ok(result.toJsonString());
    });

    router.get('/result4', (req) {
      var result = ApiResult.successExec(
          data: '44sss', message: '消息啊啊啊', state: ExtState(99, '是否'));
      return Response.ok(result.toJsonString());
    });

    router.get('/result5', (req) {
      var result =
          ApiResult.successExec(message: '消息啊啊啊', state: ExtState(99, '是否'));
      return Response.ok(result.toJsonString());
    });

    router.get('/result6', (req) {
      var result = ApiResult.exceptionLogic();
      return Response.ok(result.toJsonString());
    });

    router.get('/result7', (req) {
      var result = ApiResult.errorStatus();
      return Response.ok(result.toJsonString());
    });

    router.get('/result8', (req) {
      var result = ApiResult.errorStatus('what isaaa是');
      return Response.ok(result.toJsonString());
    });

    router.get('/result9', (req) {
      var result = ApiResult.custom(
          codeEnum: ApiResultCodeEnum.exceptionLogic,
          data: 99,
          message: 'hello是')
        ..timestamp = DateTime.now().toString();
      return Response.ok(result.toJsonString());
    });
  }

  Response _shit(Request request) {
    return Response.ok('shit is this');
  }

  /// 可以测试一下用int userId是否可以(不行，目前只能是String，不会自动转换【以后也许会优化】）
  /// 【注意，返回类型必须是FutureOr<Response>
  /// 可以是Future<Response>或Response】因此这里用Future<String>作为返回类型是不行的
  Future<Response> _nameById(Request request, String userId) {
    return Future.sync(() {
      return Response.ok('userId is $userId');
    })
        .then((response) async =>
            Response.ok((await response.readAsString()) + 'fuck'))
        .onError((error, stackTrace) => throw ArgumentError('ssss'));
  }

  Response _queryParam(Request request, String foo, String aaa) {
    return Response.ok('foo: $foo, aaa: $aaa');
  }

  Future<Response> _login(Request req) async {
    var body = await req.readAsString();
    if (body.contains('username') && body.contains('silentdoer')) {
      return Response.ok('尊敬的silentdoer, 您登陆成功了');
    } else {
      return Response.forbidden('抱歉，您没有权限');
    }
  }
}
