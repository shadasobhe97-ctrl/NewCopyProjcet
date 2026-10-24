import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../logic/register_cubit.dart';
import '../../../logic/register_state.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/utils/app_validators.dart';

class DriverBasicInfoScreen extends StatefulWidget {
  const DriverBasicInfoScreen({super.key});

  @override
  State<DriverBasicInfoScreen> createState() => _DriverBasicInfoScreenState();
}

class _DriverBasicInfoScreenState extends State<DriverBasicInfoScreen> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();
  final _nameKey = GlobalKey<FormFieldState>();
  final _emailKey = GlobalKey<FormFieldState>();
  final _phoneKey = GlobalKey<FormFieldState>();
  final _altPhoneKey = GlobalKey<FormFieldState>();
  final _passwordKey = GlobalKey<FormFieldState>();
  final _confirmPasswordKey = GlobalKey<FormFieldState>();

  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _altPhoneFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _altPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedGender = 'male';

  XFile? _avatarXFile;
  Uint8List? _avatarBytes;
  final ImagePicker _picker = ImagePicker();

  String? _emailServerError;
  String? _phoneServerError;
  String? _altPhoneServerError;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      if (_emailServerError != null) {
        setState(() => _emailServerError = null);
      }
      if (_emailKey.currentState?.hasError == true) {
        if (AppValidators.validateEmail(_emailController.text) == null) {
          _emailKey.currentState?.validate();
        }
      }
    });

    _phoneController.addListener(() {
      if (_phoneServerError != null) {
        setState(() => _phoneServerError = null);
      }
      if (_phoneKey.currentState?.hasError == true) {
        if (AppValidators.validateLibyanPhone(_phoneController.text, isRequired: true, isAlternative: false) == null) {
          _phoneKey.currentState?.validate();
        }
      }
      if (_altPhoneKey.currentState?.hasError == true && _altPhoneController.text.trim().isNotEmpty) {
        if (AppValidators.validateLibyanPhone(_altPhoneController.text, isRequired: false, primaryPhone: _phoneController.text, isAlternative: true) == null) {
          _altPhoneKey.currentState?.validate();
        }
      }
    });

    _altPhoneController.addListener(() {
      if (_altPhoneServerError != null) {
        setState(() => _altPhoneServerError = null);
      }
      if (_altPhoneKey.currentState?.hasError == true) {
        if (AppValidators.validateLibyanPhone(_altPhoneController.text, isRequired: false, primaryPhone: _phoneController.text, isAlternative: true) == null) {
          _altPhoneKey.currentState?.validate();
        }
      }
    });

    _nameController.addListener(() {
      if (_nameKey.currentState?.hasError == true) {
        if (AppValidators.validateArabicTripleName(_nameController.text) == null) {
          _nameKey.currentState?.validate();
        }
      }
    });

    _passwordController.addListener(() {
      if (_passwordKey.currentState?.hasError == true) {
        if (AppValidators.validatePassword(_passwordController.text) == null) {
          _passwordKey.currentState?.validate();
        }
      }
      if (_confirmPasswordKey.currentState?.hasError == true && _confirmPasswordController.text.isNotEmpty) {
        if (AppValidators.validateConfirmPassword(_confirmPasswordController.text, _passwordController.text) == null) {
          _confirmPasswordKey.currentState?.validate();
        }
      }
    });

    _confirmPasswordController.addListener(() {
      if (_confirmPasswordKey.currentState?.hasError == true) {
        if (AppValidators.validateConfirmPassword(_confirmPasswordController.text, _passwordController.text) == null) {
          _confirmPasswordKey.currentState?.validate();
        }
      }
    });

    _nameFocusNode.addListener(() {
      if (!_nameFocusNode.hasFocus) {
        if (_nameController.text.trim().isNotEmpty || _nameKey.currentState?.hasError == true) {
          _nameKey.currentState?.validate();
        }
      }
    });

    _emailFocusNode.addListener(() {
      if (!_emailFocusNode.hasFocus) {
        if (_emailController.text.trim().isNotEmpty || _emailKey.currentState?.hasError == true) {
          _emailKey.currentState?.validate();
        }
      }
    });

    _phoneFocusNode.addListener(() {
      if (!_phoneFocusNode.hasFocus) {
        if (_phoneController.text.trim().isNotEmpty || _phoneKey.currentState?.hasError == true) {
          _phoneKey.currentState?.validate();
        }
      }
    });

    _altPhoneFocusNode.addListener(() {
      if (!_altPhoneFocusNode.hasFocus) {
        if (_altPhoneController.text.trim().isNotEmpty || _altPhoneKey.currentState?.hasError == true) {
          _altPhoneKey.currentState?.validate();
        }
      }
    });

    _passwordFocusNode.addListener(() {
      if (!_passwordFocusNode.hasFocus) {
        if (_passwordController.text.isNotEmpty || _passwordKey.currentState?.hasError == true) {
          _passwordKey.currentState?.validate();
        }
      }
    });

    _confirmPasswordFocusNode.addListener(() {
      if (!_confirmPasswordFocusNode.hasFocus) {
        if (_confirmPasswordController.text.isNotEmpty || _confirmPasswordKey.currentState?.hasError == true) {
          _confirmPasswordKey.currentState?.validate();
        }
      }
    });
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _altPhoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();

    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _altPhoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 75,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _avatarXFile = pickedFile;
          _avatarBytes = bytes;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل اختيار الصورة: $e')));
    }
  }

  void _showAvatarBottomSheet() {
    final primaryColor = Theme.of(context).primaryColor;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "الصورة الشخصية (اختيارية)",
                style: AppTextStyles.heading(
                  color: Theme.of(context).colorScheme.onSurface,
                ).copyWith(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: primaryColor.withValues(alpha: 0.1),
                  child: Icon(Icons.camera_alt_outlined, color: primaryColor),
                ),
                title: const Text("التقاط بواسطة الكاميرا"),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAvatar(ImageSource.camera);
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: primaryColor.withValues(alpha: 0.1),
                  child: Icon(
                    Icons.photo_library_outlined,
                    color: primaryColor,
                  ),
                ),
                title: const Text("اختيار من معرض الصور"),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAvatar(ImageSource.gallery);
                },
              ),
              if (_avatarBytes != null)
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0x1AF44336),
                    child: Icon(Icons.delete_outline, color: AppColors.red),
                  ),
                  title: const Text("إزالة الصورة الحالية"),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _avatarXFile = null;
                      _avatarBytes = null;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<RegisterCubit>();
    final altPhone = _altPhoneController.text.trim();

    cubit.fullName = _nameController.text.trim();
    cubit.email = _emailController.text.trim();
    cubit.phoneNumber = _phoneController.text.trim();
    cubit.alternativePhone = altPhone.isNotEmpty ? altPhone : null;
    cubit.gender = _selectedGender;
    cubit.password = _passwordController.text;
    cubit.avatarFile = _avatarXFile ?? _avatarBytes;

    // استدعاء المرحلة الأولى للسائق (إرسال البيانات وطلب الـ OTP)
    cubit.registerDriverFirstStage();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<RegisterCubit, RegisterState>(
          listener: (context, state) {
            if (state is DriverRegisterFirstStageSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.green,
                ),
              );
              Navigator.pushNamed(context, '/driverOtp');
            } else if (state is DriverRegisterFirstStageError) {
              final fieldErrors = state.fieldErrors;
              bool matched = false;
              final unhandledErrors = <String>[];

              // 1. فحص الأخطاء المفهرسة من الخادم وربط كل حقل بخطئه الخاص
              if (fieldErrors != null && fieldErrors.isNotEmpty) {
                for (final entry in fieldErrors.entries) {
                  final k = entry.key;
                  if (k == 'email') {
                    _emailServerError = entry.value;
                    matched = true;
                  } else if (k == 'phone') {
                    _phoneServerError = entry.value;
                    matched = true;
                  } else if (k == 'alternative_phone') {
                    _altPhoneServerError = entry.value;
                    matched = true;
                  } else {
                    unhandledErrors.add(entry.value);
                  }
                }
              }

              // 2. إذا لم تكن هناك أخطاء مفهرسة، تحقق إذا كانت الرسالة المفردة تخص حقلاً واحداً فقط
              if (!matched && unhandledErrors.isEmpty) {
                final err = state.errorMessage;
                final lower = err.toLowerCase();

                // رسائل تعذر أو فشل إرسال رمز التحقق هي رسائل نظام/خدمة يجب أن تظهر في SnackBar فقط
                final isOtpDeliveryError = err.contains('تعذر') ||
                    err.contains('فشل') ||
                    err.contains('رمز التحقق') ||
                    lower.contains('otp') ||
                    lower.contains('send') ||
                    (err.contains('إرسال') && (err.contains('تعذر') || err.contains('فشل')));

                if (!isOtpDeliveryError) {
                  final isAltPhone = err.contains('احتياطي') ||
                      err.contains('بديل') ||
                      err.contains('طوارئ') ||
                      lower.contains('alternative') ||
                      lower.contains('alt_phone') ||
                      lower.contains('backup');

                  final isEmail = (err.contains('بريد') ||
                      err.contains('الإلكتروني') ||
                      err.contains('الالكتروني') ||
                      err.contains('ايميل') ||
                      err.contains('إيميل') ||
                      lower.contains('email') ||
                      lower.contains('mail')) &&
                      !err.contains('هاتف') &&
                      !err.contains('phone');

                  final isPhone = (err.contains('هاتف') ||
                      err.contains('موبايل') ||
                      err.contains('جوال') ||
                      lower.contains('phone')) &&
                      !isAltPhone &&
                      !isEmail;

                  if (isEmail) {
                    _emailServerError = err;
                    matched = true;
                  } else if (isAltPhone) {
                    _altPhoneServerError = err;
                    matched = true;
                  } else if (isPhone) {
                    _phoneServerError = err;
                    matched = true;
                  }
                }
              }

              setState(() {});

              if (_emailServerError != null) {
                _emailKey.currentState?.validate();
              }
              if (_phoneServerError != null) {
                _phoneKey.currentState?.validate();
              }
              if (_altPhoneServerError != null) {
                _altPhoneKey.currentState?.validate();
              }

              // 1. إذا وُجدت أخطاء خادم غير مرتبطة بحقول الشاشة الظاهرة، تُعرض في SnackBar دون إهمالها
              if (unhandledErrors.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(unhandledErrors.join('\n')),
                    backgroundColor: AppColors.red,
                  ),
                );
              }
              // 2. إذا لم يرتبط الخطأ بحقل محدد (خطأ عام بالخادم أو اتصال)، يُعرض في SnackBar
              else if (!matched) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage),
                    backgroundColor: AppColors.red,
                  ),
                );
              }
            }
          },
          builder: (context, state) {
            final isLoading = state is DriverRegisterFirstStageLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),

                    // 🌟 مختار الصورة الشخصية العصري (Circular Avatar Picker)
                    Center(
                      child: GestureDetector(
                        onTap: _showAvatarBottomSheet,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark
                                    ? AppColors.grey800
                                    : primaryColor.withValues(alpha: 0.1),
                                border: Border.all(
                                  color: primaryColor,
                                  width: 2.5,
                                ),
                                image: _avatarBytes != null
                                    ? DecorationImage(
                                        image: MemoryImage(_avatarBytes!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: _avatarBytes == null
                                  ? Icon(
                                      Icons.person,
                                      size: 54,
                                      color: primaryColor,
                                    )
                                  : null,
                            ),
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: primaryColor,
                              child: const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        _avatarBytes != null
                            ? "اضغط لتغيير الصورة الشخصية"
                            : "أضف صورة شخصية (اختياري)",
                        style: AppTextStyles.style(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 1. الاسم الكامل (الثلاثي)
                    TextFormField(
                      key: _nameKey,
                      focusNode: _nameFocusNode,
                      controller: _nameController,
                      textAlign: TextAlign.right,
                      style: AppTextStyles.inputTextStyle(
                        color: isDark ? AppColors.white : AppColors.textPrimary,
                      ),
                      decoration: AppTheme.inputDecoration(
                        context,
                        labelText: "الاسم الكامل (الثلاثي بالعربي)",
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      validator: AppValidators.validateArabicTripleName,
                      onChanged: (val) {
                        if (_nameKey.currentState?.hasError == true) {
                          if (AppValidators.validateArabicTripleName(val) == null) {
                            _nameKey.currentState?.validate();
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // 2. البريد الإلكتروني
                    TextFormField(
                      key: _emailKey,
                      focusNode: _emailFocusNode,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textAlign: TextAlign.right,
                      style: AppTextStyles.inputTextStyle(
                        color: isDark ? AppColors.white : AppColors.textPrimary,
                      ),
                      decoration: AppTheme.inputDecoration(
                        context,
                        labelText: "البريد الإلكتروني",
                        hintText: "example@email.com",
                        prefixIcon: const Icon(Icons.email_outlined),
                        errorText: _emailServerError,
                      ),
                      validator: (value) =>
                          AppValidators.validateEmail(value) ?? _emailServerError,
                      onChanged: (val) {
                        if (_emailServerError != null) {
                          setState(() => _emailServerError = null);
                        }
                        if (_emailKey.currentState?.hasError == true) {
                          if (AppValidators.validateEmail(val) == null) {
                            _emailKey.currentState?.validate();
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // 3. رقم الهاتف الرئيسي (10 أرقام ويبدأ بـ 09 حتماً)
                    TextFormField(
                      key: _phoneKey,
                      focusNode: _phoneFocusNode,
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textAlign: TextAlign.right,
                      style: AppTextStyles.inputTextStyle(
                        color: isDark ? AppColors.white : AppColors.textPrimary,
                      ),
                      decoration: AppTheme.inputDecoration(
                        context,
                        labelText: "رقم الهاتف",
                        hintText: "09XXXXXXXX",
                        prefixIcon: const Icon(Icons.phone_android),
                        errorText: _phoneServerError,
                      ),
                      validator: (v) =>
                          AppValidators.validateLibyanPhone(
                            v,
                            isRequired: true,
                            isAlternative: false,
                          ) ??
                          _phoneServerError,
                      onChanged: (val) {
                        if (_phoneServerError != null) {
                          setState(() => _phoneServerError = null);
                        }
                        if (_phoneKey.currentState?.hasError == true) {
                          if (AppValidators.validateLibyanPhone(val, isRequired: true, isAlternative: false) == null) {
                            _phoneKey.currentState?.validate();
                          }
                        }
                        if (_altPhoneKey.currentState?.hasError == true && _altPhoneController.text.trim().isNotEmpty) {
                          if (AppValidators.validateLibyanPhone(_altPhoneController.text, isRequired: false, primaryPhone: val, isAlternative: true) == null) {
                            _altPhoneKey.currentState?.validate();
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // 4. رقم هاتف بديل / طوارئ (اختياري)
                    TextFormField(
                      key: _altPhoneKey,
                      focusNode: _altPhoneFocusNode,
                      controller: _altPhoneController,
                      keyboardType: TextInputType.phone,
                      textAlign: TextAlign.right,
                      style: AppTextStyles.inputTextStyle(
                        color: isDark ? AppColors.white : AppColors.textPrimary,
                      ),
                      decoration: AppTheme.inputDecoration(
                        context,
                        labelText: "رقم هاتف بديل/الطوارئ (اختياري)",
                        hintText: "09XXXXXXXX",
                        prefixIcon: const Icon(Icons.phone_outlined),
                        errorText: _altPhoneServerError,
                      ),
                      validator: (v) =>
                          AppValidators.validateLibyanPhone(
                            v,
                            isRequired: false,
                            primaryPhone: _phoneController.text,
                            isAlternative: true,
                          ) ??
                          _altPhoneServerError,
                      onChanged: (val) {
                        if (_altPhoneServerError != null) {
                          setState(() => _altPhoneServerError = null);
                        }
                        if (_altPhoneKey.currentState?.hasError == true) {
                          if (AppValidators.validateLibyanPhone(val, isRequired: false, primaryPhone: _phoneController.text, isAlternative: true) == null) {
                            _altPhoneKey.currentState?.validate();
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // 5. الجنس (ذكر / أنثى)
                    Text(
                      "الجنس",
                      style: AppTextStyles.style(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text("ذكر ")),
                            selected: _selectedGender == 'male',
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedGender = 'male');
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text("أنثى ")),
                            selected: _selectedGender == 'female',
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedGender = 'female');
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 6. كلمة المرور
                    TextFormField(
                      key: _passwordKey,
                      focusNode: _passwordFocusNode,
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.left,
                      style: AppTextStyles.inputTextStyle(
                        color: isDark ? AppColors.white : AppColors.textPrimary,
                      ),
                      decoration: AppTheme.inputDecoration(
                        context,
                        labelText: "كلمة المرور",
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () => setState(
                            () => _isPasswordVisible = !_isPasswordVisible,
                          ),
                        ),
                      ),
                      validator: AppValidators.validatePassword,
                      onChanged: (val) {
                        if (_passwordKey.currentState?.hasError == true) {
                          if (AppValidators.validatePassword(val) == null) {
                            _passwordKey.currentState?.validate();
                          }
                        }
                        if (_confirmPasswordKey.currentState?.hasError == true && _confirmPasswordController.text.isNotEmpty) {
                          if (AppValidators.validateConfirmPassword(_confirmPasswordController.text, val) == null) {
                            _confirmPasswordKey.currentState?.validate();
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // 7. تأكيد كلمة المرور
                    TextFormField(
                      key: _confirmPasswordKey,
                      focusNode: _confirmPasswordFocusNode,
                      controller: _confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.left,
                      style: AppTextStyles.inputTextStyle(
                        color: isDark ? AppColors.white : AppColors.textPrimary,
                      ),
                      decoration: AppTheme.inputDecoration(
                        context,
                        labelText: "تأكيد كلمة المرور",
                        prefixIcon: const Icon(Icons.lock_reset),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () => setState(
                            () => _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible,
                          ),
                        ),
                      ),
                      validator: (v) {
                        final error = AppValidators.validatePassword(v);
                        if (error != null) return error;
                        if (v != _passwordController.text) {
                          return "كلمة المرور غير متطابقة";
                        }
                        return null;
                      },
                      onChanged: (val) {
                        if (_confirmPasswordKey.currentState?.hasError == true) {
                          if (AppValidators.validateConfirmPassword(val, _passwordController.text) == null) {
                            _confirmPasswordKey.currentState?.validate();
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 32),

                    // زر الإرسال والمتابعة
                    ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      style: AppTheme.elevatedButtonStyle(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              "إرسال رمز التحقق (OTP)",
                              style: AppTextStyles.style(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
