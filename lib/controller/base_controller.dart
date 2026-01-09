import 'package:flutter/material.dart';
import 'package:kedv/helper/error_message_helper.dart';
import 'package:kedv/model/base_response_model.dart';

class BaseController extends ChangeNotifier {
  String? errorMessage;

  /// Generic API çağrısı. T tipi BaseResponse olabilir.
  Future<BaseResponse<T>?> callService<T>(
    Future<BaseResponse<T>?> Function() apiCall,
  ) async {
    errorMessage = null;
    notifyListeners();

    try {
      final result = await apiCall();
      notifyListeners();
      return result;
    } catch (e) {
      errorMessage = ErrorMessageHelper.getErrorMessage(e);
      notifyListeners();
      return null;
    }
  }
}

