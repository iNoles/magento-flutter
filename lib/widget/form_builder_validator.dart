import 'package:flutter/material.dart';

class FormBuilderValidators {
  /// [FormFieldValidator] that requires the field have a non-empty value.
  static FormFieldValidator required({
    String errorText = 'This field cannot be empty.',
  }) {
    return (valueCandidate) {
      if (valueCandidate == null ||
          ((valueCandidate is Iterable ||
                  valueCandidate is String ||
                  valueCandidate is Map) &&
              valueCandidate.length == 0)) {
        return errorText;
      }
      return null;
    };
  }

  /// Common validator method that tests [val] against [validators].  When a
  /// validation generates an error message, it it returned, otherwise null.
  static String validateValidators<T>(
      T val, List<FormFieldValidator> validators) {
    for (var i = 0; i < validators.length; i++) {
      final validatorResult = validators[i](val);
      if (validatorResult != null) {
        return validatorResult;
      }
    }
    return null;
  }
}
