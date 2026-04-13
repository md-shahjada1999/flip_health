import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class SimpleWebSocket {
  String _url;

  var _socket;
  Function()? onOpen;
  Function(dynamic msg)? onMessage;
  Function(int? code, String? reaso)? onClose;
  SimpleWebSocket(this._url);

  connect() async {
    try {
      _socket = await WebSocketChannel.connect(
        Uri.parse(_url),
      );
      onOpen?.call();

      _socket.stream.listen((data) {
        onMessage?.call(data);
      }, onDone: () {
        print("onDone");
        // onClose?.call(_socket.closeCode, _socket.closeReason);
      });
      return _socket;
    } catch (e) {
      print("onError");
      onClose?.call(500, e.toString());
    }
  }

  send(data) {
    if (_socket != null) {
      _socket.sink.add(data);
      print('send: $data');
    }
  }

  close() {
    if (_socket != null)
      _socket.sink.close(status.goingAway, 'bye bye socket.');
  }
}
