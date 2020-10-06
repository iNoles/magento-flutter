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

  /// [FormFieldValidator] that requires the field's value to be greater than
  /// or equal to the provided number.
  static FormFieldValidator min(
    num min, {
    String errorText,
  }) {
    return (valueCandidate) {
      if (valueCandidate != null &&
          ((valueCandidate is num && valueCandidate < min) ||
              (valueCandidate is String &&
                  num.tryParse(valueCandidate) != null &&
                  num.tryParse(valueCandidate) < min))) {
        return errorText ?? 'Value must be greater than or equal to $min';
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
