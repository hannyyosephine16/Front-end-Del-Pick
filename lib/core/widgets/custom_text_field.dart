import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool isPassword; // Alias untuk obscureText
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final void Function(String)? onFieldSubmitted; // Alias untuk onSubmitted
  final void Function()? onTap;
  final bool readOnly;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final String? errorText;
  final String? helperText;
  final TextCapitalization textCapitalization;
  final EdgeInsetsGeometry? contentPadding;
  final Color? fillColor;
  final bool filled;
  final InputBorder? border;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final InputBorder? enabledBorder;
  final InputBorder? disabledBorder;
  final InputBorder? focusedErrorBorder;
  final TextStyle? style;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextStyle? errorStyle;
  final TextStyle? helperStyle;
  final Color? cursorColor;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final TextAlign textAlign;
  final bool autofocus;
  final bool autocorrect;
  final bool enableSuggestions;
  final String? initialValue;
  final FloatingLabelBehavior? floatingLabelBehavior;

  const CustomTextField({
    Key? key,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.isPassword = false, // Alias untuk obscureText
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onFieldSubmitted, // Alias untuk onSubmitted
    this.onTap,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.focusNode,
    this.errorText,
    this.helperText,
    this.textCapitalization = TextCapitalization.none,
    this.contentPadding,
    this.fillColor,
    this.filled = true,
    this.border,
    this.focusedBorder,
    this.errorBorder,
    this.enabledBorder,
    this.disabledBorder,
    this.focusedErrorBorder,
    this.style,
    this.labelStyle,
    this.hintStyle,
    this.errorStyle,
    this.helperStyle,
    this.cursorColor,
    this.cursorHeight,
    this.cursorRadius,
    this.textAlign = TextAlign.start,
    this.autofocus = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.initialValue,
    this.floatingLabelBehavior,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;
  bool _isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    // Gunakan isPassword jika diset, jika tidak gunakan obscureText
    _obscureText = widget.isPassword || widget.obscureText;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Color _getBorderColor(ThemeData theme) {
    if (widget.errorText != null) {
      return theme.colorScheme.error;
    }
    if (_isFocused) {
      return theme.primaryColor;
    }
    return theme.dividerColor;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          focusNode: _focusNode,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onFieldSubmitted ?? widget.onSubmitted,
          onTap: widget.onTap,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          inputFormatters: widget.inputFormatters,
          textCapitalization: widget.textCapitalization,
          textAlign: widget.textAlign,
          autofocus: widget.autofocus,
          autocorrect: widget.autocorrect,
          enableSuggestions: widget.enableSuggestions,
          cursorColor: widget.cursorColor ?? theme.primaryColor,
          cursorHeight: widget.cursorHeight,
          cursorRadius: widget.cursorRadius ?? const Radius.circular(2),
          style: widget.style ?? theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            errorText: widget.errorText,
            helperText: widget.helperText,
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: _isFocused
                        ? theme.primaryColor
                        : theme.iconTheme.color?.withOpacity(0.6),
                  )
                : null,
            suffixIcon: _buildSuffixIcon(theme),
            filled: widget.filled,
            fillColor: widget.fillColor ??
                (theme.brightness == Brightness.dark
                    ? theme.cardColor
                    : Colors.grey.shade50),
            contentPadding: widget.contentPadding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: widget.border ?? _buildBorder(theme),
            enabledBorder: widget.enabledBorder ?? _buildBorder(theme),
            focusedBorder: widget.focusedBorder ?? _buildFocusedBorder(theme),
            errorBorder: widget.errorBorder ?? _buildErrorBorder(theme),
            focusedErrorBorder:
                widget.focusedErrorBorder ?? _buildFocusedErrorBorder(theme),
            disabledBorder:
                widget.disabledBorder ?? _buildDisabledBorder(theme),
            labelStyle: widget.labelStyle ??
                theme.textTheme.bodyMedium?.copyWith(
                  color: _isFocused
                      ? theme.primaryColor
                      : theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
            hintStyle: widget.hintStyle ??
                theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                ),
            errorStyle: widget.errorStyle ??
                theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
            helperStyle: widget.helperStyle ??
                theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                ),
            floatingLabelBehavior:
                widget.floatingLabelBehavior ?? FloatingLabelBehavior.auto,
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon(ThemeData theme) {
    // Cek apakah ini password field (menggunakan isPassword atau obscureText)
    if (widget.isPassword || widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: theme.iconTheme.color?.withOpacity(0.6),
        ),
        onPressed: _toggleObscureText,
        tooltip: _obscureText ? 'Tampilkan password' : 'Sembunyikan password',
      );
    }
    return widget.suffixIcon;
  }

  OutlineInputBorder _buildBorder(ThemeData theme) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: theme.dividerColor,
        width: 1,
      ),
    );
  }

  OutlineInputBorder _buildFocusedBorder(ThemeData theme) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: theme.primaryColor,
        width: 2,
      ),
    );
  }

  OutlineInputBorder _buildErrorBorder(ThemeData theme) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: theme.colorScheme.error,
        width: 1,
      ),
    );
  }

  OutlineInputBorder _buildFocusedErrorBorder(ThemeData theme) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: theme.colorScheme.error,
        width: 2,
      ),
    );
  }

  OutlineInputBorder _buildDisabledBorder(ThemeData theme) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: theme.disabledColor,
        width: 1,
      ),
    );
  }
}

// Extension untuk validasi yang umum digunakan
extension CustomTextFieldValidators on String? {
  String? validateEmail() {
    if (this == null || this!.isEmpty) {
      return 'Email harus diisi';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(this!)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? validatePassword() {
    if (this == null || this!.isEmpty) {
      return 'Password harus diisi';
    }
    if (this!.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  String? validateRequired(String fieldName) {
    if (this == null || this!.isEmpty) {
      return '$fieldName harus diisi';
    }
    return null;
  }

  String? validatePhone() {
    if (this == null || this!.isEmpty) {
      return 'Nomor telepon harus diisi';
    }
    final phoneRegex = RegExp(r'^[0-9]{10,13}$');
    if (!phoneRegex.hasMatch(this!.replaceAll(RegExp(r'[^\d]'), ''))) {
      return 'Nomor telepon tidak valid';
    }
    return null;
  }

  String? validateName() {
    if (this == null || this!.isEmpty) {
      return 'Nama harus diisi';
    }
    if (this!.length < 3) {
      return 'Nama minimal 3 karakter';
    }
    if (this!.length > 50) {
      return 'Nama maksimal 50 karakter';
    }
    return null;
  }

  String? validatePrice() {
    if (this == null || this!.isEmpty) {
      return 'Harga harus diisi';
    }
    final price = double.tryParse(this!);
    if (price == null || price < 0) {
      return 'Harga harus berupa angka yang valid';
    }
    return null;
  }

  String? validateQuantity() {
    if (this == null || this!.isEmpty) {
      return 'Jumlah harus diisi';
    }
    final quantity = int.tryParse(this!);
    if (quantity == null || quantity < 0) {
      return 'Jumlah harus berupa angka yang valid';
    }
    return null;
  }
}

// Input formatters yang umum digunakan
class CustomInputFormatters {
  static final phoneFormatter = [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(13),
  ];

  static final priceFormatter = [
    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
  ];

  static final nameFormatter = [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
    LengthLimitingTextInputFormatter(50),
  ];

  static final addressFormatter = [
    LengthLimitingTextInputFormatter(255),
  ];

  static final descriptionFormatter = [
    LengthLimitingTextInputFormatter(500),
  ];

  static final quantityFormatter = [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(6),
  ];
}

// Specialized TextFields untuk use case tertentu
class EmailTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final String? errorText;
  final bool enabled;

  const EmailTextField({
    Key? key,
    this.controller,
    this.validator,
    this.onChanged,
    this.errorText,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      labelText: 'Email',
      hintText: 'Masukkan email Anda',
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: validator ?? (value) => value.validateEmail(),
      onChanged: onChanged,
      errorText: errorText,
      enabled: enabled,
      textCapitalization: TextCapitalization.none,
      autocorrect: false,
      enableSuggestions: false,
    );
  }
}

class PasswordTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final String? errorText;
  final bool enabled;
  final String? labelText;
  final String? hintText;

  const PasswordTextField({
    Key? key,
    this.controller,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.errorText,
    this.enabled = true,
    this.labelText,
    this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      labelText: labelText ?? 'Password',
      hintText: hintText ?? 'Masukkan password Anda',
      prefixIcon: Icons.lock_outlined,
      isPassword: true,
      textInputAction: TextInputAction.done,
      validator: validator ?? (value) => value.validatePassword(),
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      errorText: errorText,
      enabled: enabled,
      autocorrect: false,
      enableSuggestions: false,
    );
  }
}

class PhoneTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final String? errorText;
  final bool enabled;

  const PhoneTextField({
    Key? key,
    this.controller,
    this.validator,
    this.onChanged,
    this.errorText,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      labelText: 'Nomor Telepon',
      hintText: 'Masukkan nomor telepon Anda',
      prefixIcon: Icons.phone_outlined,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      validator: validator ?? (value) => value.validatePhone(),
      onChanged: onChanged,
      errorText: errorText,
      enabled: enabled,
      inputFormatters: CustomInputFormatters.phoneFormatter,
    );
  }
}

class PriceTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final String? errorText;
  final bool enabled;

  const PriceTextField({
    Key? key,
    this.controller,
    this.validator,
    this.onChanged,
    this.errorText,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      labelText: '',
      hintText: '',
      prefixIcon: Icons.attach_money,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      validator: validator ?? (value) => value.validatePrice(),
      onChanged: onChanged,
      errorText: errorText,
      enabled: enabled,
      inputFormatters: CustomInputFormatters.priceFormatter,
    );
  }
}
