import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../../../data/fileshare_repository.dart';
import '../../../data/friends_repository.dart';
import '../../../data/settings.dart';
import 'events.dart' as home_events;
import 'state.dart' as home_state;

class HomeBloc extends Bloc<home_events.HomeEvent, home_state.HomeState> {
  final FileShareRepository _fileShareRepository;
  final FriendsRepository _friendsRepository;

  HomeBloc(
    this._fileShareRepository,
    this._friendsRepository,
  ) : super(home_state.HomeState(
          name: Settings.name.value,
          defaultName: Settings.name.defaultValue ?? '',
          serverAddress: _getServerAddress(),
          defaultServerAddress: _getDefaultServerAddress(),
        )) {
    on<home_events.PageLoaded>((final event, final emit) async {
      await _friendsRepository.init();

      emit(state.copyWith(
        friends: () => _friendsRepository.getFriends(),
      ));
    });
    on<home_events.StartFileTransfer>((final event, final emit) async {
      if (event.friend.uuid == null) {
        return;
      }

      final FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result?.files.single.path == null) {
        return;
      }

      final PlatformFile file = result!.files.single;

      (await _fileShareRepository.startFileShare(
        targetUuid: event.friend.uuid!,
        filePath: file.path!,
      ))
          ?.listen(
        (final event) => add(home_events.ReceiveFileChunk(event)),
        onDone: () => add(const home_events.CancelFileTransfer()),
      );

      emit(state.copyWith(
        fileTransferState: () => home_state.FileTransferState(
          otherUserUuid: event.friend.uuid!,
          sendOrReceive: true,
          fileInfo: home_state.FileInfo(
            name: file.name,
            path: file.path!,
            size: file.size,
          ),
        ),
      ));
    });
    on<home_events.ReceiveFile>((final event, final emit) async {
      if (event.friend.uuid == null) {
        return;
      }

      (await _fileShareRepository.connectToFileShare(
        sourceUuid: event.friend.uuid!,
        onFileInfo: (
          final fileName,
          final fileSize,
        ) async {
          add(home_events.SetIncomingFileInfo(fileName, fileSize));
        },
      ))
          ?.listen(
        (final event) => add(home_events.ReceiveFileChunk(event)),
        onDone: () => add(const home_events.CancelFileTransfer()),
      );

      emit(state.copyWith(
        fileTransferState: () => home_state.FileTransferState(
          otherUserUuid: event.friend.uuid!,
          sendOrReceive: false,
        ),
      ));
    });
    on<home_events.SetIncomingFileInfo>((final event, final emit) async {
      String? path;

      if (Platform.isWindows) {
        path = await FilePicker.platform.saveFile(
          dialogTitle: 'Save file',
          fileName: event.fileName,
        );
      } else if (Platform.isAndroid) {
        final String? downloadsPath = (await getExternalStorageDirectories(
                type: StorageDirectory.downloads))?[0]
            .path;

        if (downloadsPath != null) {
          path = join(
            downloadsPath,
            event.fileName,
          );
        }
      }

      if (path == null) {
        return;
      }

      final File file = File(path);

      if (await file.exists()) {
        await file.delete();
      }

      emit(state.copyWith(
        fileTransferState: () => state.fileTransferState?.copyWith(
          fileInfo: () => home_state.FileInfo(
            name: event.fileName,
            path: path!,
            size: event.fileSize,
          ),
        ),
      ));

      _fileShareRepository.receiveFile();
    });
    on<home_events.ReceiveFileChunk>((final event, final emit) async {
      if (state.fileTransferState?.fileInfo?.path == null) {
        return;
      }

      if (!state.fileTransferState!.sendOrReceive) {
        await File(state.fileTransferState!.fileInfo!.path).writeAsBytes(
          event.chunk,
          mode: FileMode.append,
        );
      }

      emit(state.copyWith(
        fileTransferState: () => state.fileTransferState!.copyWith(
          fileInfo: () => state.fileTransferState!.fileInfo!.copyWith(
            bytesTransferred: () =>
                (state.fileTransferState!.fileInfo!.bytesTransferred ?? 0) +
                event.chunk.length,
          ),
        ),
      ));
    });
    on<home_events.CancelFileTransfer>((final event, final emit) async {
      emit(state.copyWith(
        fileTransferState: () => null,
      ));

      await _fileShareRepository.cancel();
    });
    on<home_events.RemoveFriend>((final event, final emit) async {
      if (!await _friendsRepository.removeFriend(event.friend)) {
        emit(state.copyWith(
          snackBarMessage: () =>
              home_state.SnackBarMessage.failedToRemoveFriend,
        ));

        return;
      }

      emit(state.copyWith(
        friends: () => List.of(
            state.friends.where((final element) => element != event.friend)),
      ));
    });
    on<home_events.CopyFriendInformation>((final event, final emit) async {
      await Clipboard.setData(ClipboardData(
        text: jsonEncode(event.friend.toMap()),
      ));

      emit(state.copyWith(
        snackBarMessage: () =>
            home_state.SnackBarMessage.friendInformationCopied,
      ));
    });
    on<home_events.SetActionState>(
      (final event, final emit) => emit(state.copyWith(
        actionState: () =>
            state.actionState == event.state ? null : event.state,
      )),
    );
    on<home_events.CopyFriendString>((final event, final emit) async {
      await Clipboard.setData(ClipboardData(
        text: base64Encode(
          utf8.encode(
            jsonEncode({
              Settings.uuid.key: Settings.uuid.value,
              Settings.name.key: Settings.name.value,
            }),
          ),
        ),
      ));

      emit(state.copyWith(
        snackBarMessage: () => home_state.SnackBarMessage.friendStringCopied,
      ));
    });
    on<home_events.AddFriendFromString>((final event, final emit) async {
      Friend friend;

      try {
        friend = Friend.fromMap(
          jsonDecode(
            utf8.decode(
              base64Decode(
                (await Clipboard.getData(Clipboard.kTextPlain))?.text ?? 'e30=',
              ),
              allowMalformed: true,
            ),
          ),
        );
      } on FormatException catch (_) {
        friend = Friend();
      }

      await _friendsRepository.addFriend(friend);

      emit(
        state.copyWith(friends: () => List.from(state.friends)..add(friend)),
      );
    });
    on<home_events.SetName>((final event, final emit) => emit(state.copyWith(
          name: () => event.name,
        )));
    on<home_events.SaveName>((final event, final emit) async => await Settings
        .name
        .save((state.name ?? '').isEmpty ? null : state.name));
    on<home_events.SetServerAddress>(
        (final event, final emit) => emit(state.copyWith(
              serverAddress: () => event.address,
            )));
    on<home_events.SaveServerAddress>((final event, final emit) async =>
        await _saveServerAddress(
            (state.serverAddress ?? '').isEmpty ? null : state.serverAddress));
  }

  static String? _getServerAddress() => kDebugMode
      ? Settings.debugServerAddress.value
      : Settings.productionServerAddress.value;

  static String _getDefaultServerAddress() =>
      (kDebugMode
          ? Settings.debugServerAddress.defaultValue
          : Settings.productionServerAddress.defaultValue) ??
      'ERROR';

  static Future<void> _saveServerAddress(final String? address) async =>
      await (kDebugMode
          ? Settings.debugServerAddress.save(address)
          : Settings.productionServerAddress.save(address));
}
