// lib/widgets/common/error_widget.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CustomErrorWidget extends StatelessWidget {
  final String? title;
  final String message;
  final String? buttonText;
  final VoidCallback? onRetry;
  final Widget? icon;
  final bool showIcon;
  final EdgeInsetsGeometry? padding;

  const CustomErrorWidget({
    Key? key,
    this.title,
    required this.message,
    this.buttonText,
    this.onRetry,
    this.icon,
    this.showIcon = true,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showIcon) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child:
                  icon ??
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.errorColor,
                  ),
            ),
            const SizedBox(height: 24),
          ],
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(buttonText ?? 'Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? message;

  const NetworkErrorWidget({Key? key, this.onRetry, this.message})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      title: 'Connection Error',
      message:
          message ?? 'Please check your internet connection and try again.',
      buttonText: 'Retry',
      onRetry: onRetry,
      icon: const Icon(Icons.wifi_off, size: 48, color: AppColors.errorColor),
    );
  }
}

class NotFoundErrorWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback? onGoBack;

  const NotFoundErrorWidget({Key? key, this.title, this.message, this.onGoBack})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      title: title ?? 'Not Found',
      message: message ?? 'The item you\'re looking for could not be found.',
      buttonText: 'Go Back',
      onRetry: onGoBack ?? () => Navigator.pop(context),
      icon: const Icon(
        Icons.search_off,
        size: 48,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final Widget? icon;
  final Widget? illustration;

  const EmptyStateWidget({
    Key? key,
    required this.title,
    required this.message,
    this.buttonText,
    this.onButtonPressed,
    this.icon,
    this.illustration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          illustration ??
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.lightColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(60),
                ),
                child:
                    icon ??
                    const Icon(
                      Icons.inbox,
                      size: 64,
                      color: AppColors.textSecondary,
                    ),
              ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          if (onButtonPressed != null && buttonText != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onButtonPressed,
              icon: const Icon(Icons.add),
              label: Text(buttonText!),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class PermissionErrorWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback? onRequestPermission;

  const PermissionErrorWidget({
    Key? key,
    this.title,
    this.message,
    this.onRequestPermission,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      title: title ?? 'Permission Required',
      message:
          message ??
          'This feature requires permission to work properly. Please grant the necessary permissions.',
      buttonText: 'Grant Permission',
      onRetry: onRequestPermission,
      icon: const Icon(Icons.security, size: 48, color: AppColors.primaryColor),
    );
  }
}

class MaintenanceErrorWidget extends StatelessWidget {
  final String? message;

  const MaintenanceErrorWidget({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      title: 'Under Maintenance',
      message:
          message ??
          'We\'re currently performing maintenance. Please try again later.',
      showIcon: true,
      icon: const Icon(Icons.build, size: 48, color: AppColors.primaryColor),
    );
  }
}

// Error boundary widget for catching errors in widget tree
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(String error)? errorBuilder;

  const ErrorBoundary({Key? key, required this.child, this.errorBuilder})
    : super(key: key);

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  String? error;

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return widget.errorBuilder?.call(error!) ??
          CustomErrorWidget(
            title: 'Something went wrong',
            message: error!,
            buttonText: 'Reset',
            onRetry: () {
              setState(() {
                error = null;
              });
            },
          );
    }

    return widget.child;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    FlutterError.onError = (FlutterErrorDetails details) {
      setState(() {
        error = details.exception.toString();
      });
    };
  }
}

// Inline error widget for form fields and smaller spaces
class InlineErrorWidget extends StatelessWidget {
  final String message;
  final EdgeInsetsGeometry? padding;

  const InlineErrorWidget({Key? key, required this.message, this.padding})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.errorColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 16, color: AppColors.errorColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 12, color: AppColors.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}

// Success widget for positive feedback
class SuccessWidget extends StatelessWidget {
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const SuccessWidget({
    Key? key,
    required this.title,
    required this.message,
    this.buttonText,
    this.onButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.check_circle_outline,
              size: 48,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          if (onButtonPressed != null && buttonText != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onButtonPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(buttonText!),
            ),
          ],
        ],
      ),
    );
  }
}
