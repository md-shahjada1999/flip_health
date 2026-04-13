import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/core/services/permission_service.dart';
import 'package:flip_health/core/utils/custom_toast.dart';
import 'package:flip_health/data/repositories/consultation_order_repository.dart';
import 'package:flip_health/data/repositories/upload_repository.dart';
import 'package:flip_health/routes/app_routes.dart';
import 'package:flip_health/services/video_call/signaling_service.dart';
import 'package:flip_health/views/consultation/widgets/consultation_call_feedback_dialog.dart';
import 'package:flip_health/views/consultation/widgets/consultation_call_message_bubble.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// WebRTC consultation — aligned with patient_app [SocketView]: controls, in-call chat, end + feedback.
class ConsultationVideoCallScreen extends StatefulWidget {
  const ConsultationVideoCallScreen({super.key});

  @override
  State<ConsultationVideoCallScreen> createState() =>
      _ConsultationVideoCallScreenState();
}

class _ConsultationVideoCallScreenState extends State<ConsultationVideoCallScreen> {
  Signaling? _signaling;
  dynamic _peers;
  String? selfId;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  bool _inCalling = false;
  Session? _session;
  bool _waitAccept = false;
  late Map<String, dynamic> data;

  bool _micOn = true;
  bool _videoOn = true;
  bool _speakerOn = true;
  int _chatUnread = 0;
  bool _inChatSheet = false;
  bool _exitHandled = false;
  void Function(void Function())? _chatModalSetState;

  final _chatInput = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _uploadingChatAttachment = false;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    final args = Get.arguments;
    if (args is Map && args['data'] is Map) {
      data = Map<String, dynamic>.from(args['data'] as Map);
    } else {
      data = {};
    }
    _connect();
    _signaling?.CreatingLocalView(media: 'video', screenSharing: false);
    _initRenderers();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _chatInput.dispose();
    _localRenderer.srcObject = null;
    _remoteRenderer.srcObject = null;
    final sig = _signaling;
    _signaling = null;
    if (sig != null) {
      unawaited(sig.close());
    }
    WakelockPlus.disable();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  void _connect() {
    _signaling = Signaling(data);
    _signaling?.connect();

    _signaling?.onCallStateChange = (Session session, CallState state) async {
      switch (state) {
        case CallState.CallStateNew:
          setState(() => _session = session);
          break;
        case CallState.CallStateRinging:
          _accept();
          setState(() => _inCalling = true);
          break;
        case CallState.CallStateBye:
          setState(() {
            _localRenderer.srcObject = null;
            _remoteRenderer.srcObject = null;
            _inCalling = false;
            _session = null;
          });
          await _offerFeedbackAndExit();
          break;
        case CallState.CallStateInvite:
          _waitAccept = true;
          break;
        case CallState.CallStateConnected:
          if (_waitAccept) _waitAccept = false;
          setState(() => _inCalling = true);
          break;
        case CallState.NewMessages:
          setState(() {
            if (_inChatSheet) {
              _chatUnread = 0;
            } else {
              _chatUnread++;
            }
          });
          _chatModalSetState?.call(() {});
          break;
      }
    };

    _signaling?.onPeersUpdate = (event) {
      setState(() {
        selfId = event['self']?.toString();
        _peers = event['peers'];
      });
      final roomId = data['id']?.toString() ?? '';
      if (roomId.isNotEmpty && _peers != null) {
        _signaling?.makeCall(roomId, _peers, 'video', false);
      }
    };

    _signaling?.onLocalStream = (stream) {
      setState(() => _localRenderer.srcObject = stream);
      final aud = stream.getAudioTracks();
      final vid = stream.getVideoTracks();
      _micOn = aud.isNotEmpty ? aud.first.enabled : true;
      _videoOn = vid.isNotEmpty ? vid.first.enabled : true;
    };

    _signaling?.onAddRemoteStream = (_, stream) async {
      setState(() => _remoteRenderer.srcObject = stream);
      await Future<void>.delayed(const Duration(milliseconds: 500));
      final tracks = _remoteRenderer.srcObject?.getAudioTracks();
      if (tracks != null && tracks.isNotEmpty) {
        tracks.first.enableSpeakerphone(_speakerOn);
      }
    };

    _signaling?.onRemoveRemoteStream = (_, stream) {
      _remoteRenderer.srcObject = null;
    };
  }

  void _accept() {
    if (_session != null) {
      _signaling?.accept(_session!.sid);
    }
  }

  Future<void> _offerFeedbackAndExit() async {
    if (_exitHandled) return;
    _exitHandled = true;
    if (!mounted) return;
    final id = data['id']?.toString() ?? '';
    if (!Get.isRegistered<ConsultationOrderRepository>()) {
      Get.offAllNamed(AppRoutes.dashboard);
      return;
    }
    final repo = Get.find<ConsultationOrderRepository>();
    if (id.isNotEmpty) {
      await showConsultationCallFeedbackDialog(
        context: context,
        appointmentId: id,
        repository: repo,
      );
    }
    if (mounted) Get.offAllNamed(AppRoutes.dashboard);
  }

  Future<void> _toggleSpeaker() async {
    setState(() => _speakerOn = !_speakerOn);
    final tracks = _remoteRenderer.srcObject?.getAudioTracks();
    if (tracks != null && tracks.isNotEmpty) {
      tracks.first.enableSpeakerphone(_speakerOn);
    }
  }

  Future<void> _hangUp() async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('End call?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('No')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final roomId = data['id']?.toString() ?? '';
    try {
      if (Get.isRegistered<ConsultationOrderRepository>()) {
        await Get.find<ConsultationOrderRepository>().endCall(roomId);
      }
    } catch (_) {}
    final sid = _session?.sid ?? roomId;
    _signaling?.bye(sid);
  }

  static bool _msgTypeIsTxt(String? t) {
    final u = t?.trim().toUpperCase() ?? '';
    return u.isEmpty || u == 'TXT' || u == 'TEXT';
  }

  static bool _msgTypeIsImg(String? t) {
    final u = t?.trim().toUpperCase() ?? '';
    return u == 'IMG' || u == 'IMAGE';
  }

  static bool _msgTypeIsPdf(String? t) =>
      t?.trim().toUpperCase() == 'PDF';

  String _messageBody(Messages m) {
    final t = m.msg_type;
    if (_msgTypeIsTxt(t)) return m.message ?? '';
    return '${_msgTypeIsPdf(t) ? 'PDF' : 'Image'}: ${m.img_name ?? m.img_path ?? '—'}';
  }

  Widget _chatBubbleFor(Messages m) {
    final isPatient = m.user_type == 'patient';
    final t = m.msg_type;
    final fileUrl = ApiUrl.publicFileUrl(m.img_path);
    if (_msgTypeIsImg(t) && fileUrl != null && fileUrl.isNotEmpty) {
      return ConsultationCallMessageBubble(
        text: m.img_name ?? '',
        isPatient: isPatient,
        timeLabel: m.created_at,
        imageUrl: fileUrl,
      );
    }
    if (_msgTypeIsPdf(t) && fileUrl != null && fileUrl.isNotEmpty) {
      return ConsultationCallMessageBubble(
        text: m.img_name ?? 'Open PDF',
        isPatient: isPatient,
        timeLabel: m.created_at,
        onAttachmentTap: () async {
          final u = Uri.parse(fileUrl);
          if (await canLaunchUrl(u)) {
            await launchUrl(u, mode: LaunchMode.externalApplication);
          }
        },
      );
    }
    return ConsultationCallMessageBubble(
      text: _messageBody(m),
      isPatient: isPatient,
      timeLabel: m.created_at,
    );
  }

  Future<void> _uploadAndSendChatFile(
    String filePath,
    StateSetter setModal,
  ) async {
    if (_session == null || !Get.isRegistered<UploadRepository>()) return;
    final lower = filePath.toLowerCase();
    final ext = lower.endsWith('.pdf') ? 'PDF' : 'IMG';
    setModal(() => _uploadingChatAttachment = true);
    try {
      final upload = await Get.find<UploadRepository>().uploadFile(
        filePath: filePath,
        type: 'document',
      );
      final payload = <String, dynamic>{
        'type': ext,
        'message': upload.toJson(),
      };
      await _signaling?.sendMessage(
        _session!.sid,
        data['id'],
        payload,
        ext,
      );
      setModal(() {});
      _chatModalSetState?.call(() {});
      if (mounted) setState(() {});
    } on AppException catch (e) {
      ToastCustom.showSnackBar(subtitle: e.message);
    } catch (e) {
      ToastCustom.showSnackBar(subtitle: e.toString());
    } finally {
      if (mounted) {
        setModal(() => _uploadingChatAttachment = false);
      }
    }
  }

  Future<void> _pickImage(ImageSource source, StateSetter setModal) async {
    if (source == ImageSource.camera) {
      final ok = await PermissionService().requestCameraPermission();
      if (!ok) {
        ToastCustom.showSnackBar(subtitle: 'Camera permission is required');
        return;
      }
    }
    final x = await _imagePicker.pickImage(source: source);
    if (x == null) return;
    await _uploadAndSendChatFile(x.path, setModal);
  }

  Future<void> _pickPdf(StateSetter setModal) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
    if (result == null || result.files.isEmpty) return;
    final path = result.files.first.path;
    if (path == null) return;
    await _uploadAndSendChatFile(path, setModal);
  }

  void _showAttachmentPicker(StateSetter setModal) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      builder: (c) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take photo'),
              onTap: () {
                Navigator.pop(c);
                _pickImage(ImageSource.camera, setModal);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose image'),
              onTap: () {
                Navigator.pop(c);
                _pickImage(ImageSource.gallery, setModal);
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined),
              title: const Text('Choose PDF'),
              onTap: () {
                Navigator.pop(c);
                _pickPdf(setModal);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openChatSheet() async {
    if (_session == null) {
      ToastCustom.showSnackBar(
        subtitle: 'You can chat after the call connects',
      );
      return;
    }
    final roomId = data['id']?.toString() ?? '';
    if (roomId.isEmpty) return;
    _signaling?.getAllMessagesApi(roomId);
    if (!mounted) return;
    setState(() {
      _inChatSheet = true;
      _chatUnread = 0;
    });
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      isDismissible: true,
      builder: (ctx) {
        return PopScope(
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) {
              _chatModalSetState = null;
              setState(() => _inChatSheet = false);
            }
          },
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(ctx).bottom,
              ),
              child: StatefulBuilder(
                builder: (context, setModal) {
                  _chatModalSetState = setModal;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.rw, vertical: 8.rh),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(ctx),
                              icon: const Icon(Icons.close_rounded),
                            ),
                            Expanded(
                              child: Text(
                                'Chat with doctor',
                                style: TextStyle(
                                  fontSize: 16.rf,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(width: 48.rw),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      SizedBox(
                        height: MediaQuery.of(ctx).size.height * 0.42,
                        child: _signaling!.allMessages.isEmpty
                            ? Center(
                                child: Text(
                                  'Start the conversation',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14.rf,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.rw,
                                  vertical: 8.rh,
                                ),
                                reverse: true,
                                itemCount: _signaling!.allMessages.length,
                                itemBuilder: (_, i) {
                                  final m = _signaling!.allMessages[i];
                                  return _chatBubbleFor(m);
                                },
                              ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(12.rw, 4.rh, 12.rw, 12.rh),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_uploadingChatAttachment)
                              Padding(
                                padding: EdgeInsets.only(bottom: 8.rh),
                                child: const LinearProgressIndicator(),
                              ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: _uploadingChatAttachment
                                      ? null
                                      : () => _showAttachmentPicker(setModal),
                                  icon: Icon(
                                    Icons.attach_file_rounded,
                                    color: _uploadingChatAttachment
                                        ? AppColors.textSecondary
                                        : AppColors.primary,
                                  ),
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: _chatInput,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    decoration: InputDecoration(
                                      hintText: 'Message',
                                      filled: true,
                                      fillColor: AppColors.backgroundSecondary,
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.rs),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: _uploadingChatAttachment
                                      ? null
                                      : () async {
                                          final text = _chatInput.text.trim();
                                          if (text.isEmpty) return;
                                          final payload = <String, dynamic>{
                                            'message': text,
                                            'type': 'TXT',
                                          };
                                          await _signaling?.sendMessage(
                                            _session!.sid,
                                            data['id'],
                                            payload,
                                            'TXT',
                                          );
                                          _chatInput.clear();
                                          setModal(() {});
                                          if (mounted) setState(() {});
                                        },
                                  icon: Icon(
                                    Icons.send_rounded,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
    _chatModalSetState = null;
    if (mounted) setState(() => _inChatSheet = false);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (_inCalling)
                Positioned.fill(
                  child: RTCVideoView(
                    _remoteRenderer,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                )
              else
                Center(
                  child: Text(
                    'Waiting for doctor…',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              Positioned(
                right: 16,
                top: 16,
                child: GestureDetector(
                  onTap: () => _signaling?.switchCamera(),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 110,
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: RTCVideoView(
                            _localRenderer,
                            mirror: true,
                            objectFit:
                                RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Icon(
                          Icons.flip_camera_android_outlined,
                          color: Colors.white.withValues(alpha: 0.85),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                    color: Color.fromARGB(255, 58, 58, 58),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _circleIcon(
                        icon: _videoOn ? Icons.videocam : Icons.videocam_off,
                        color: _videoOn ? Colors.green : Colors.grey,
                        onTap: () {
                          final v = _signaling?.videoOnOff();
                          setState(() => _videoOn = v ?? !_videoOn);
                        },
                      ),
                      _circleIcon(
                        icon: _speakerOn ? Icons.volume_up : Icons.hearing_disabled,
                        color: Colors.green,
                        onTap: _toggleSpeaker,
                      ),
                      _circleIcon(
                        icon: _micOn ? Icons.mic : Icons.mic_off,
                        color: _micOn ? Colors.green : Colors.grey,
                        onTap: () {
                          final m = _signaling?.muteMic();
                          setState(() => _micOn = m ?? !_micOn);
                        },
                      ),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          _circleIcon(
                            icon: Icons.chat_bubble_outline,
                            color: Colors.white70,
                            onTap: _openChatSheet,
                          ),
                          if (_chatUnread > 0 && !_inChatSheet)
                            Positioned(
                              right: -4,
                              top: -4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 18,
                                  minHeight: 18,
                                ),
                                child: Text(
                                  _chatUnread > 9 ? '9+' : '$_chatUnread',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                      FloatingActionButton(
                        onPressed: _hangUp,
                        backgroundColor: Colors.pink,
                        heroTag: 'end_call',
                        mini: true,
                        child: const Icon(Icons.call_end),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circleIcon({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, color: color, size: 26),
        ),
      ),
    );
  }
}
