/// Tracks whether the user has left the welcome screen so we don't redirect / back to it after login.
bool welcomeCompleted = false;

void setWelcomeCompleted() {
  welcomeCompleted = true;
}
