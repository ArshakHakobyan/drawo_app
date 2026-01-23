import 'package:reactive_forms/reactive_forms.dart';

typedef TextControl = FormControl<String>;
typedef NumControl = FormControl<num>;
typedef BoolControl = FormControl<bool>;
typedef DateControl = FormControl<DateTime>;

abstract class FormController {
  FormGroup formGroup;

  FormController(this.formGroup);

  bool validate() {
    formGroup
      ..markAllAsTouched()
      ..updateValueAndValidity();

    return formGroup.valid;
  }

  void clear() {
    formGroup.controls.forEach((name, control) {
      control
        ..markAsUntouched()
        ..updateValue(null);
    });
  }
}

class MustMatchValidator extends Validator<dynamic> {
  final String controlName;
  final String matchingControlName;
  final bool markAsDirty;

  const MustMatchValidator(
    this.controlName,
    this.matchingControlName, {
    this.markAsDirty = true,
  }) : super();

  @override
  Map<String, dynamic>? validate(AbstractControl<dynamic> control) {
    final error = {ValidationMessage.mustMatch: true};

    if (control is! FormGroup) {
      return error;
    }

    final formControl = control.control(controlName);
    final matchingFormControl = control.control(matchingControlName);

    if (formControl.value != matchingFormControl.value &&
        matchingFormControl.touched) {
      matchingFormControl.setErrors(error, markAsDirty: markAsDirty);
    } else {
      matchingFormControl.removeError(ValidationMessage.mustMatch);
    }

    return null;
  }
}
