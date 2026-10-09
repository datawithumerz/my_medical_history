/// Independent integration boundaries. No provider is configured in this build.
abstract interface class AccountSyncService {
  bool get isConnected;
  Future<void> sync();
}

abstract interface class DriveBackupService {
  bool get isConnected;
  Future<void> backUp();
  Future<void> restore();
}

class UnconfiguredAccountSync implements AccountSyncService {
  const UnconfiguredAccountSync();
  @override
  bool get isConnected => false;
  @override
  Future<void> sync() =>
      Future.error(StateError('Account sync is not connected.'));
}

class UnconfiguredDriveBackup implements DriveBackupService {
  const UnconfiguredDriveBackup();
  @override
  bool get isConnected => false;
  @override
  Future<void> backUp() =>
      Future.error(StateError('Google Drive is not connected.'));
  @override
  Future<void> restore() =>
      Future.error(StateError('Google Drive is not connected.'));
}
