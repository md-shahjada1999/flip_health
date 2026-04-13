import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flip_health/main.dart' show accessToken;
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'websocket.dart';
import 'package:http/http.dart' as http;

Map<String, String> _chatAuthHeaders() => {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

/// Upload/chat paths may be `folder/file.jpg` or a bare filename — never index `[1]` on [String.split].
String _fileNameFromChatPath(dynamic path) {
  final s = path?.toString().trim() ?? '';
  if (s.isEmpty) return '';
  return s.split('/').last;
}

bool _apiChatTypeIsTxt(dynamic raw) {
  final u = raw?.toString().trim().toUpperCase() ?? '';
  return u == 'TXT' || u == 'TEXT';
}

bool _apiChatTypeIsPdf(dynamic raw) =>
    raw?.toString().trim().toUpperCase() == 'PDF';

bool _apiChatTypeIsImg(dynamic raw) {
  final u = raw?.toString().trim().toUpperCase() ?? '';
  return u == 'IMG' || u == 'IMAGE';
}

dynamic _mapPathByKeys(dynamic root, List<String> keys) {
  dynamic cur = root;
  for (final k in keys) {
    if (cur is! Map) return null;
    cur = cur[k];
  }
  return cur;
}

enum SignalingState {
  ConnectionOpen,
  ConnectionClosed,
  ConnectionError,
}

enum CallState {
  CallStateNew,
  CallStateRinging,
  CallStateInvite,
  CallStateConnected,
  CallStateBye,
  NewMessages,
}

class Session {
  Session({required this.sid, required this.pid});
  String pid;
  String sid;
  RTCPeerConnection? pc;
  RTCDataChannel? dc;
  List<RTCIceCandidate> remoteCandidates = [];
}

class Signaling {
  var data;
  var socketMessage = {
    "status": 1,
    "type": "MESSAGE",
    "source": "ROOM",
    "sourceId": "abc",
    "data": ""
  };
  Signaling(data) {
    this.data = data;
    socketMessage['sourceId'] = data['id'];
  }

  SimpleWebSocket? _socket;
  // var _url = 'ws://192.168.0.100:8080';
  // var _url = 'ws://ec2-15-206-146-154.ap-south-1.compute.amazonaws.com:8080';
  // var _url =  'wss://toajkwk8t2.execute-api.ap-south-1.amazonaws.com/development';
  var _url = "wss://wi38lavjc8.execute-api.ap-south-1.amazonaws.com/production";

  Map<String, Session> _sessions = {};
  MediaStream? _localStream;
  List<MediaStream> _remoteStreams = <MediaStream>[];

  Function(SignalingState state)? onSignalingStateChange;
  Function(Session session, CallState state)? onCallStateChange;
  Function(MediaStream stream)? onLocalStream;
  Function(Session session, MediaStream stream)? onAddRemoteStream;
  Function(Session session, MediaStream stream)? onRemoveRemoteStream;
  Function(dynamic event)? onPeersUpdate;
  Function(Session session, RTCDataChannel dc, RTCDataChannelMessage data)?
      onDataChannelMessage;
  Function(Session session, RTCDataChannel dc)? onDataChannel;

  List<Messages> allMessages = List<Messages>.empty(growable: true);
  List<dynamic> messages = List<dynamic>.empty(growable: true);
  List<MediaDeviceInfo>? _mediaDevicesList;

  String get sdpSemantics =>
      WebRTC.platformIsWindows ? 'plan-b' : 'unified-plan';

  Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'url': 'stun:stun.l.google.com:19302'},
      /*
       * turn server configuration example.
      {
        'url': 'turn:123.45.67.89:3478',
        'username': 'change_to_real_user',
        'credential': 'change_to_real_secret'
      },
      */
    ]
  };

  final Map<String, dynamic> _config = {
    'mandatory': {},
    'optional': [
      {'DtlsSrtpKeyAgreement': true},
    ]
  };

  final Map<String, dynamic> _dcConstraints = {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': true,
    },
    'optional': [],
  };

  close() async {
    await _cleanSessions();
    _socket?.close();
  }

  /// Front/back toggle; may fail on emulators or single-camera devices.
  Future<void> switchCamera() async {
    final stream = _localStream;
    if (stream == null) return;
    final tracks = stream.getVideoTracks();
    if (tracks.isEmpty) return;
    try {
      await Helper.switchCamera(tracks.first);
    } on PlatformException catch (e) {
      debugPrint('switchCamera: ${e.message ?? e.code}');
    } catch (e) {
      debugPrint('switchCamera: $e');
    }
  }

  bool muteMic() {
    if (_localStream != null) {
      bool enabled = _localStream!.getAudioTracks()[0].enabled;
      return _localStream!.getAudioTracks()[0].enabled = !enabled;
    }
    return true;
  }

  bool videoOnOff() {
    if (_localStream != null) {
      bool enabled = _localStream!.getVideoTracks()[0].enabled;
      return _localStream!.getVideoTracks()[0].enabled = !enabled;
    }
    return true;
  }

  void makeCall(
      String sessionId, String peerId, String media, bool useScreen) async {
    print("Invite${peerId} to ${sessionId}");
    Session session = await _createSession(null,
        peerId: peerId,
        sessionId: sessionId,
        media: media,
        screenSharing: useScreen);
    _sessions[sessionId] = session;
    _createOffer(session, media);
    onCallStateChange?.call(session, CallState.CallStateNew);
    onCallStateChange?.call(session, CallState.CallStateInvite);
  }

  void bye(String sessionId) {
    _send({"type": "LEAVE", 'sourceId': sessionId});
    var sess = _sessions[sessionId];
    if (sess != null) {
      _closeSession(sess);
    }
  }

  // endcallApi() async {
  //   print("yes");
  //   Uri url = Uri.parse("${Apis.base_url}/${Apis.pharma}");
  //   var resp = await http.get(url, headers: customHeader());
  //   var response = resp.body;
  //   print(response);
  //   if (resp.statusCode == 200) {
  //   } else {}
  // }
//FIXME:Implement scroll issue
  getAllMessagesApi(String chatId) async {
    final url = Uri.parse(
        '${ApiUrl.BASE_URL}/patient/chat/messages/$chatId?limit=100');
    http.Response resp = await http.get(url, headers: _chatAuthHeaders());

    dynamic response = json.decode(resp.body);
    if (resp.statusCode == 200) {
      print("allMsgs: ${response['messages']}");
      messages.clear();
      allMessages.clear();

      messages = response["messages"];

      messages.forEach((element) {
        final isTxt = _apiChatTypeIsTxt(element['type']);
        final isPdf = _apiChatTypeIsPdf(element['type']);
        final isImg = _apiChatTypeIsImg(element['type']);
        final msgType = isTxt ? 'TXT' : (isPdf ? 'PDF' : 'IMG');
        final hasMedia = isPdf || isImg;
        allMessages.insert(
          0,
          Messages(
              pid: element['user_id'].toString(),
              message: element['message'].toString(),
              user_type: element['user_type'].toString(),
              msg_type: msgType,
              sent: element['user_type'].toString() == 'patient' ? true : false,
              img_name: hasMedia
                  ? _fileNameFromChatPath(
                      element['message'] is Map
                          ? (element['message'] as Map)['path']
                          : null)
                  : "null",
              img_path: hasMedia
                  ? (element['message'] is Map
                      ? (element['message'] as Map)['path']
                      : null)
                  : "null",
              created_at: element['createdAt'].toString(),
              updated_at: element['updatedAt'].toString()),
        );
      });
    } else {}
  }

  sendMessageApi(chatId, data2, sessionId, type) async {
    final url = Uri.parse('${ApiUrl.BASE_URL}/patient/chat/$chatId');
    print("Url: ${url}");
    print("Object sending: ${json.encode(data2)}");

    var resp =
        await http.post(url, body: json.encode(data2), headers: _chatAuthHeaders());
    var response = resp.body;
    print("Response SendMsg: ${response.toString()}");
    print("Response SendMsg Status Code: ${resp.statusCode}");
    if (resp.statusCode == 200) {
      Session? session = _sessions[sessionId];
      socketMessage["data"] = {
        "type": "message",
        "content": data2,
        "sourceId": sessionId
      };

      if (type != 'TXT') {
        allMessages.removeAt(0);
      }

      allMessages.insert(
          0,
          // Messages(
          //   pid: element['user_id'].toString(),
          //   message: element['message'].toString(),
          //   user_type: element['user_type'].toString(),
          //   msg_type: element['type'].toString() == 'TXT'
          //       ? 'TXT'
          //       : element['type'].toString() == 'PDF'
          //           ? 'PDF'
          //           : 'IMG',
          //   sent: element['user_type'].toString() == 'patient' ? true : false,
          //   img_name: element['type'].toString() == 'PDF' ||
          //           element['type'].toString() == 'IMG'
          //       ? element['message']?['path'].split("/")[1]
          //       : "null",
          //   img_path: element['type'].toString() == 'PDF' ||
          //           element['type'].toString() == 'IMG'
          //       ? element['message']?['path']
          //       : "null",
          // ),

          Messages(
              pid: data['patient_id'].toString(),
              uid: data['doctor_id'].toString(),
              user_type: "patient",
              message: data2['message'].toString(),
              msg_type: type == 'TXT'
                  ? 'TXT'
                  : type == 'PDF'
                      ? 'PDF'
                      : 'IMG',
              img_name: type == 'PDF' || type == 'IMG'
                  ? _fileNameFromChatPath(data2['message']['path'])
                  : "null",
              img_path: type == 'PDF' || type == 'IMG'
                  ? data2['message']['path']
                  : "null",
              sent: true,
              created_at: data['createdAt'].toString(),
              updated_at: data['updatedAt'].toString()));

      // Messages(
      // pid: data['patient_id'].toString(),
      // uid: data['doctor_id'].toString(),
      // msg_type: data2['type'] == "PDF" ? "PDF" : "IMG",
      // img_name: data2['message']?['path'].split("/")[1],
      // img_path: data2['message']?['path'],
      // user_type: "patient",
      // sent: false));

      // print("Msgs Length: ${allMessages.length}");
      // _send(socketMessage);
      // onCallStateChange?.call(session!, CallState.NewMessages);

//
      // Session? session = _sessions[sessionId];
      // socketMessage["data"] = {
      //   "type": "message",
      //   "content": data2,
      //   "sourceId": sessionId
      // };

      // allMessages.insert(
      //     0,
      //     Messages(
      //         pid: data['patient_id'].toString(),
      //         uid: data['doctor_id'].toString(),
      //         msg_type: data2['type'] == "PDF" ? "PDF" : "IMG",
      //         img_name: data2['message']?['path'].split("/")[1],
      //         img_path: data2['message']?['path'],
      //         user_type: "patient",
      //         sent: false));

      print("Msgs Length : ${allMessages.length}");
      _send(socketMessage);
      onCallStateChange?.call(session!, CallState.NewMessages);
    } else {}
  }

  void accept(String sessionId) {
    var session = _sessions[sessionId];
    if (session == null) {
      return;
    }
    _createAnswer(session, 'video');
  }

  void reject(String sessionId) {
    var session = _sessions[sessionId];
    if (session == null) {
      return;
    }
    bye(session.sid);
  }

  void onMessage(message) async {
    print("onMessage: ${message}");
    var m = message;
    print("TYPE----------------:${m['type']}--------------------");

    switch (m['type']) {
      case 'CONNECTION':
        {
          _send({
            "status": 1,
            "type": "JOIN",
            "source": "ROOM",
            "sourceId": socketMessage['sourceId']
          });
        }
        break;
      case 'USER-JOINED':
        {
          if (onPeersUpdate != null) {
            dynamic event = {};
            event['self'] = data['patient_id'];
            event['peers'] = m['id'];
            onPeersUpdate?.call(event);
          }
        }
        break;
      case 'MESSAGE':
        {
          switch (m["data"]?["type"]) {
            case 'offer':
              {
                var peerId = m["id"];
                var description = m["data"]['sessionDescription'];
                var media = 'video';
                var sessionId = m['sourceId'];
                var session = _sessions[sessionId];
                var newSession = await _createSession(session,
                    peerId: peerId,
                    sessionId: sessionId,
                    media: media,
                    screenSharing: false);
                print('Session ID Offer : $sessionId');
                _sessions[sessionId] = newSession;
                await newSession.pc?.setRemoteDescription(RTCSessionDescription(
                    description['sdp'], description['type']));
                // await _createAnswer(newSession, media);

                if (newSession.remoteCandidates.length > 0) {
                  newSession.remoteCandidates.forEach((candidate) async {
                    print("OnNewCandidate: ");
                    await newSession.pc?.addCandidate(candidate);
                  });
                  newSession.remoteCandidates.clear();
                }
                onCallStateChange?.call(newSession, CallState.CallStateNew);

                onCallStateChange?.call(newSession, CallState.CallStateRinging);
              }
              break;
            case 'answer':
              {
                var description = m["data"]['sessionDescription'];
                var sessionId = m['sourceId'];
                print('Session ID: $sessionId');
                var session = _sessions[sessionId];
                print("Session: ${session}");
                session?.pc?.setRemoteDescription(RTCSessionDescription(
                    description['sdp'], description['type']));
                onCallStateChange?.call(session!, CallState.CallStateConnected);
              }
              break;
            case 'iceCandidate':
              {
                var peerId = m['id'];
                var candidateMap = m["data"]['candidate'];
                var sessionId = m['sourceId'];
                var session = _sessions[sessionId];
                RTCIceCandidate candidate = RTCIceCandidate(
                    candidateMap['candidate'],
                    candidateMap['sdpMid'],
                    candidateMap['sdpMLineIndex']);

                if (session != null) {
                  if (session.pc != null) {
                    try {
                      await session.pc?.addCandidate(candidate);
                    } catch (e) {
                      print(e.toString());
                    }
                  } else {
                    session.remoteCandidates.add(candidate);
                  }
                } else {
                  _sessions[sessionId] = Session(pid: peerId, sid: sessionId)
                    ..remoteCandidates.add(candidate);
                }
              }
              break;
            case 'message':
              print("message inside message");
              var sessionId = m['sourceId'];
              var session = _sessions[sessionId];

              final contentType = m['data']?['content']?['type'];
              if (_apiChatTypeIsTxt(contentType)) {
                allMessages.insert(
                    0,
                    Messages(
                        pid: data['patient_id'].toString(),
                        uid: data['doctor_id'].toString(),
                        message: m['data']?['content']?['message'],
                        user_type: "doctor",
                        sent: true,
                        created_at: data['createdAt'].toString(),
                        updated_at: data['updatedAt'].toString()));
              } else if (_apiChatTypeIsImg(contentType) ||
                  _apiChatTypeIsPdf(contentType)) {
                allMessages.insert(
                    0,
                    Messages(
                        pid: data['patient_id'].toString(),
                        uid: data['doctor_id'].toString(),
                        msg_type: _apiChatTypeIsPdf(contentType) ? "PDF" : "IMG",
                        img_name: _fileNameFromChatPath(_mapPathByKeys(
                            m['data'], ['content', 'message', 'path'])),
                        img_path: _mapPathByKeys(
                            m['data'], ['content', 'message', 'path']),
                        user_type: "doctor",
                        sent: false,
                        created_at: data['createdAt'].toString(),
                        updated_at: data['updatedAt'].toString()));
              }
              onCallStateChange?.call(session!, CallState.NewMessages);
              break;
          }
        }
        break;

      case 'LEAVE':
        {
          var sessionId = m['sourceId'];
          print('bye: ' + sessionId);
          var session = _sessions.remove(sessionId);
          if (session != null) {
            onCallStateChange?.call(session, CallState.CallStateBye);
            _closeSession(session);
          }
        }
        break;
      case 'bye':
        {
          var sessionId = m['sourceId'];
          print('bye: ' + sessionId);
          var session = _sessions.remove(sessionId);
          if (session != null) {
            onCallStateChange?.call(session, CallState.CallStateBye);
            _closeSession(session);
          }
        }
        break;
      case 'keepalive':
        {
          print('keepalive response!');
        }
        break;
      default:
        break;
    }
  }

  //Old changes
  // Future<void> sendMessage(appId, sessionId, data2, type) async {
  //   try {
  //     print("Dataa2: ${data2} ,Type:${type}");
  //     print("Dataa MSG: ${data2['message']}");
  //     print("Dataa2 TYPE: ${data2['type']}");

  //     Session? session = _sessions[sessionId];
  //     socketMessage["data"] = {
  //       "type": "message",
  //       "content": data2,
  //       "sourceId": sessionId
  //     };

  //     if (type == 'TXT') {
  //       allMessages.insert(
  //           0,
  //           Messages(
  //               pid: data['patient_id'].toString(),
  //               uid: data['doctor_id'].toString(),
  //               message: data2['message'],
  //               user_type: "patient",
  //               sent: true));
  //     } else if (type == 'IMG' || type == 'PDF') {
  //       allMessages.removeAt(0);
  //       allMessages.insert(
  //           0,
  //           Messages(
  //               pid: data['patient_id'].toString(),
  //               uid: data['doctor_id'].toString(),
  //               msg_type: data2['type'] == "PDF" ? "PDF" : "IMG",
  //               img_name: data2['message']?['path'].split("/")[1],
  //               img_path: data2['message']?['path'],
  //               user_type: "patient",
  //               sent: false));
  //     }

  //     print("Msgs Length: ${allMessages.length}");

  //     _send(socketMessage);
  //     onCallStateChange?.call(session!, CallState.NewMessages);
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }

  //New Changes to be done
  Future<void> sendMessage(sessionId, appId, data2, type) async {
    try {
      print("Dataa2: ${data2} ,Type:${type}, appId: ${appId}");

      await sendMessageApi(appId, data2, sessionId, type);

      // if (type == 'TXT') {
      // } else if (type == 'IMG' || type == 'PDF') {
      //   await sendMessageApi(appId, data2, sessionId, type);
      // }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> connect() async {
    print("Connect in Signaling");
    var url = '$_url';
    _socket = SimpleWebSocket(url);

    print('connect to $url');

    _socket?.onOpen = () {
      print('onOpen');
      _send({
        "status": 1,
        "type": "JOIN",
        "source": "ROOM",
        "sourceId": socketMessage['sourceId']
      });
      onSignalingStateChange?.call(SignalingState.ConnectionOpen);
    };

    navigator.mediaDevices.ondevicechange = (event) async {
      print('++++++ ondevicechange ++++++');
      _mediaDevicesList = await navigator.mediaDevices.enumerateDevices();
      print("list of devices ${_mediaDevicesList}");
      for (var i = 0; i < _mediaDevicesList!.length; i++) {
        print(
            "devices form list ${_mediaDevicesList![i].toString()};...'deviceId: ${_mediaDevicesList![i].deviceId}");
      }
    };

    //receive data
    _socket?.onMessage = (message) {
      print('Received data: ' + message);
      onMessage(json.decode(message));
    };

    _socket?.onClose = (int? code, String? reason) {
      print('Closed by server [$code => $reason]!');
      onSignalingStateChange?.call(SignalingState.ConnectionClosed);
    };

    await _socket?.connect();
  }

  Future<MediaStream> createStream(String media, bool userScreen) async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'mandatory': {
          'minWidth':
              '640', // Provide your own width, height and frame rate here
          'minHeight': '480',
          'minFrameRate': '30',
        },
        'facingMode': 'user',
        'optional': [],
      }
    };

    // print(
    //     "Stream Details: ${navigator.mediaDevices.enumerateDevices().toString()}");

    MediaStream stream = userScreen
        ? await navigator.mediaDevices.getDisplayMedia(mediaConstraints)
        // : await navigator.mediaDevices.getUserMedia(mediaConstraints);
        : await navigator.mediaDevices.getUserMedia(mediaConstraints);

    onLocalStream?.call(stream);
    return stream;
  }

  CreatingLocalView(
      {required String media, required bool screenSharing}) async {
    print("CreatingLocalView");
    _localStream = await createStream(media, screenSharing);

    print(_iceServers);
    RTCPeerConnection pc = await createPeerConnection({
      ..._iceServers,
      ...{'sdpSemantics': sdpSemantics}
    }, _config);

    _localStream!.getTracks().forEach((track) {
      pc.addTrack(track, _localStream!);
    });
  }

  Future<Session> _createSession(Session? session,
      {required String peerId,
      required String sessionId,
      required String media,
      required bool screenSharing}) async {
    var newSession = session ?? Session(sid: sessionId, pid: peerId);

    // if (media != 'data')
    // [CreatingLocalView] already acquired a stream; release it before a second getUserMedia.
    await _disposeLocalMedia();

    _localStream = await createStream(media, screenSharing);

    print(_iceServers);
    RTCPeerConnection pc = await createPeerConnection({
      ..._iceServers,
      ...{'sdpSemantics': sdpSemantics}
    }, _config);
    if (media != 'data') {
      switch (sdpSemantics) {
        case 'plan-b':
          pc.onAddStream = (MediaStream stream) {
            onAddRemoteStream?.call(newSession, stream);
            _remoteStreams.add(stream);
          };
          await pc.addStream(_localStream!);
          break;
        case 'unified-plan':
          // Unified-Plan
          pc.onTrack = (event) {
            print("InEvent${event.track.kind}");
            if (event.track.kind == 'video') {
              print("Streams Length Inside: ${event.streams.length}");
              onAddRemoteStream?.call(newSession, event.streams[0]);
            }
          };
          _localStream!.getTracks().forEach((track) {
            pc.addTrack(track, _localStream!);
          });
          break;
      }
    }

    pc.onIceConnectionState = ((state) {
      print("IceConnectionState: " + state.toString());
      // RTCIceConnectionState.RTCIceConnectionStateDisconnected
      // RTCIceConnectionState.RTCIceConnectionStateFailed
    });
    pc.onIceGatheringState = ((gatheringState) {
      print("onIceGatheringState: " + gatheringState.toString());
    });

    // print("Remote Streams Length: ${pc.getRemoteStreams().length}");
    // print("Configuration: ${pc.getConfiguration}");
    // print("Stats: ${pc.getStats().asStream()}");

    pc.onIceCandidate = (candidate) async {
      await Future.delayed(const Duration(seconds: 1), () {
        socketMessage["data"] = {
          "type": "iceCandidate",
          "candidate": {
            "sdpMLineIndex": candidate.sdpMLineIndex,
            "sdpMid": candidate.sdpMid,
            "candidate": candidate.candidate
          },
          "sourceId": socketMessage['sourceId'],
        };
        _send(socketMessage);
      });
    };

    pc.onRemoveStream = (stream) {
      onRemoveRemoteStream?.call(newSession, stream);
      _remoteStreams.removeWhere((it) {
        return (it.id == stream.id);
      });
    };

    newSession.pc = pc;
    return newSession;
  }

// For Video Call
  Future<void> _createOffer(Session session, String media) async {
    try {
      RTCSessionDescription s = await session.pc!.createOffer(_dcConstraints);
      await session.pc!.setLocalDescription(s);
      socketMessage["data"] = {
        "type": "offer",
        "sessionDescription": {"sdp": s.sdp, "type": s.type},
        "sourceId": session.sid
      };
      _send(socketMessage);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _createAnswer(Session session, String media) async {
    try {
      RTCSessionDescription s = await session.pc!.createAnswer(_dcConstraints);
      await session.pc!.setLocalDescription(s);
      socketMessage["data"] = {
        "type": "answer",
        "sessionDescription": {"sdp": s.sdp, "type": s.type},
        "sourceId": session.sid
      };
      _send(socketMessage);
    } catch (e) {
      print(e.toString());
    }
  }

  _send(data) {
    _socket?.send(json.encode(data));
  }

  /// Stops every track so Android/iOS release camera/mic immediately.
  Future<void> _stopTracksOnStream(MediaStream? stream) async {
    if (stream == null) return;
    for (final t in stream.getTracks()) {
      try {
        await t.stop();
      } catch (_) {}
    }
  }

  Future<void> _disposeLocalMedia() async {
    final stream = _localStream;
    if (stream == null) return;
    await _stopTracksOnStream(stream);
    try {
      await stream.dispose();
    } catch (_) {}
    _localStream = null;
  }

  Future<void> _disposeRemoteStreams() async {
    final copy = List<MediaStream>.from(_remoteStreams);
    _remoteStreams.clear();
    for (final stream in copy) {
      await _stopTracksOnStream(stream);
      try {
        await stream.dispose();
      } catch (_) {}
    }
  }

  Future<void> _cleanSessions() async {
    await _disposeRemoteStreams();
    await _disposeLocalMedia();
    for (final sess in _sessions.values) {
      try {
        await sess.pc?.close();
      } catch (_) {}
      try {
        await sess.dc?.close();
      } catch (_) {}
    }
    _sessions.clear();
  }

  // void _closeSessionByPeerId(String peerId) {
  //   var session;
  //   _sessions.removeWhere((String key, Session sess) {
  //     var ids = key.split('-');
  //     session = sess;
  //     return peerId == ids[0] || peerId == ids[1];
  //   });
  //   if (session != null) {
  //     _closeSession(session);
  //     onCallStateChange?.call(session, CallState.CallStateBye);
  //   }
  // }

  Future<void> _closeSession(Session session) async {
    await _disposeRemoteStreams();
    await _disposeLocalMedia();
    try {
      await session.pc?.close();
    } catch (_) {}
    try {
      await session.dc?.close();
    } catch (_) {}
    // Navigation is handled by [ConsultationVideoCallScreen] (feedback + exit).
  }
}

class Messages {
  String? pid;
  String? uid;
  String? message;
  String? user_type;
  String? msg_type;
  String? img_path;
  String? img_name;
  bool? sent;
  String? created_at;
  String? updated_at;

  Messages(
      {this.pid,
      this.uid,
      this.message,
      this.user_type,
      this.msg_type,
      this.img_path,
      this.img_name,
      this.sent,
      this.created_at,
      this.updated_at});

  Map<String, dynamic> toMap() {
    return {
      'patient_id': pid,
      'uid': uid,
      'message': message,
      'user_type': user_type,
      'msg_type': msg_type,
      'img_path': img_path,
      'img_name': img_name,
      'sent': sent,
      'created_at': created_at,
      'updated_at': updated_at,
    };
  }

  factory Messages.fromMap(Map<String, dynamic> map) {
    // if (map == null) return null;

    return Messages(
        pid: map['patient_id'],
        uid: (map['uid']),
        message: map['message'],
        user_type: map['user_type'],
        img_path: map['img_path'],
        img_name: map['img_name'],
        msg_type: map['msg_type'],
        sent: map['sent'],
        created_at: map['createdAt'],
        updated_at: map['updatedAt']);
  }

  String toJson() => json.encode(toMap());

  factory Messages.fromJson(String source) =>
      Messages.fromMap(json.decode(source));
}
