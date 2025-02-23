class SettingsState {
  final bool darkMode;
  final bool notificationsEnabled;
  final bool isLoading;
  final String? errorMessage;

  SettingsState({
    this.darkMode = false,
    this.notificationsEnabled = true,
    this.isLoading = false,
    this.errorMessage,
  });

  SettingsState copyWith({
    bool? darkMode,
    bool? notificationsEnabled,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SettingsState(
      darkMode: darkMode ?? this.darkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
