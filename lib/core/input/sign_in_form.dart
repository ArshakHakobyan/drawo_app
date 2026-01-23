import 'package:drawo_app/core/input/base_form.dart';
import 'package:reactive_forms/reactive_forms.dart';

class SignInForm extends FormController {
  static const _emailControlName = 'email';
  static const _passwordControlName = 'password';

  SignInForm()
    : super(
        FormGroup({
          _emailControlName: FormControl<String>(
            validators: [Validators.required, Validators.email],
          ),
          _passwordControlName: FormControl<String>(
            validators: [Validators.required],
          ),
        }),
      );

  TextControl get emailControl =>
      formGroup.control(_emailControlName) as TextControl;
  TextControl get passwordControl =>
      formGroup.control(_passwordControlName) as TextControl;
}
