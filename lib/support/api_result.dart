import 'dart:convert' as convert;

class ApiResult<T> {
  bool _ok = true;

  bool get ok => _ok;

  int code;

  String message;

  /// 从1970年的时间点开始到今天的本地时间
  int? timestamp;

  T? state;

  String? thirdCode;

  String? thirdMessage;

  ApiResult._(this.code, this.message);

  ApiResult._withState(this.code, this.message, this.state);

  Map<String, dynamic> toJson() => {
        'ok': ok,
        'code': code,
        'message': message,
        'timestamp': timestamp,
        'state': state,
        'thirdCode': thirdCode,
        'thirdMessage': thirdMessage
      };

  String toJsonString() {
    return convert.jsonEncode(this);
  }

  static ApiResult<D> successExec<D>(
      {D? state, String? message}) {
    var result = ApiResult<D>._withState(
        ApiResultCodeEnum.successExec.code,
        message ?? ApiResultCodeEnum.successExec.message,
        state);
    return result;
  }

  static ApiResult<D> successTask<D>(
      {D? state, String? message}) {
    var result = ApiResult<D>._withState(
        ApiResultCodeEnum.successTask.code,
        message ?? ApiResultCodeEnum.successTask.message,
        state);
    return result;
  }

  static ApiResult<Null> exceptionLogic([String? message]) {
    var result = ApiResult<Null>._(ApiResultCodeEnum.exceptionLogic.code,
        message ?? ApiResultCodeEnum.exceptionLogic.message)
      .._ok = false;
    return result;
  }

  static ApiResult<Null> errorStatus<D>([String? message]) {
    var result = ApiResult<Null>._(ApiResultCodeEnum.errorStatus.code,
        message ?? ApiResultCodeEnum.errorStatus.message)
      .._ok = false;
    return result;
  }

  static ApiResult<D> custom<D>(
      {required ApiResultCodeEnum codeEnum,
      D? state,
      String? message}) {
    var result = ApiResult<D>._withState(
        codeEnum.code,
        message ?? codeEnum.message,
        state);
    if (codeEnum.code >= 300000) {
      result._ok = false;
    }
    return result;
  }
}

/// enum status for ApiResult
class ApiResultCodeEnum {
  final int code;

  final String message;

  const ApiResultCodeEnum._(this.code, this.message);

  /// 同步执行任务成功
  static const successExec = ApiResultCodeEnum._(100000, '执行成功');

  /// 异步提交任务成功
  static const successTask = ApiResultCodeEnum._(100001, '提交任务成功');

  /// 部分执行成功，比如一次性提交了N个任务，但是只有部分执行成功了
  static const successParts = ApiResultCodeEnum._(200000, '部分执行成功');

  /// 通用异常逻辑，可预先判断处理，比如传递的参数不正确，json解析报错等
  static const exceptionLogic = ApiResultCodeEnum._(300000, '异常业务逻辑');

  /// 通用错误系统状态，非可预处理，比如第三方报错之类的，读取文件不存在，程序状态异常等【当然和300000有交叉，也要看严重等级来划分】
  static const errorStatus = ApiResultCodeEnum._(500000, '错误系统状态');
}
