import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';

/// Reusable PDF viewer screen.
///
/// Pass either a relative [path] (e.g. `docs/PDF1001912P1775630039.pdf`)
/// which is resolved against [ApiUrl.kImageUrl], or a full [url].
/// Optionally provide a [title] for the app bar.
class CommonPdfViewer extends StatefulWidget {
  final String? path;
  final String? url;
  final String title;

  const CommonPdfViewer({
    super.key,
    this.path,
    this.url,
    this.title = 'PDF Document',
  }) : assert(path != null || url != null, 'Provide either path or url');

  @override
  State<CommonPdfViewer> createState() => _CommonPdfViewerState();
}

class _CommonPdfViewerState extends State<CommonPdfViewer> {
  String? _localPath;
  bool _loading = true;
  String? _error;
  int _totalPages = 0;
  int _currentPage = 0;

  String get _downloadUrl {
    if (widget.url != null) return widget.url!;
    return ApiUrl.publicFileUrl(widget.path) ?? '';
  }

  @override
  void initState() {
    super.initState();
    _downloadPdf();
  }

  Future<void> _downloadPdf() async {
    final url = _downloadUrl;
    if (url.isEmpty) {
      if (mounted) setState(() { _error = 'Invalid PDF path'; _loading = false; });
      return;
    }

    try {
      final dir = await getTemporaryDirectory();
      final fileName = 'pdf_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = '${dir.path}/$fileName';

      debugPrint('CommonPdfViewer download: $url');

      await Dio().download(
        url,
        filePath,
        options: Options(
          followRedirects: true,
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      if (mounted) {
        setState(() { _localPath = filePath; _loading = false; });
      }
    } catch (e) {
      debugPrint('CommonPdfViewer error: $e');
      if (mounted) {
        setState(() { _error = 'Failed to load PDF'; _loading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeScreenWrapper(
      appBar: CommonAppBar.build(
        title: widget.title,
        actions: [
          if (_totalPages > 0)
            Padding(
              padding: EdgeInsets.only(right: 16.rw),
              child: Center(
                child: CommonText(
                  '${_currentPage + 1} / $_totalPages',
                  fontSize: 12.rf,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 48.rs,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: 12.rh),
                      CommonText(
                        _error!,
                        fontSize: 14.rf,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                )
              : PDFView(
                  filePath: _localPath!,
                  enableSwipe: true,
                  swipeHorizontal: false,
                  autoSpacing: true,
                  pageFling: true,
                  onRender: (pages) {
                    if (mounted) setState(() => _totalPages = pages ?? 0);
                  },
                  onPageChanged: (page, total) {
                    if (mounted) setState(() => _currentPage = page ?? 0);
                  },
                  onError: (error) {
                    if (mounted) {
                      setState(() => _error = 'Error rendering PDF');
                    }
                  },
                ),
    );
  }
}
