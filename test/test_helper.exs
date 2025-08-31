ExUnit.start()

# Configure test environment
Application.put_env(:notes, :test_mode, true)

# Ensure test files are cleaned up
ExUnit.configure(
  exclude: :pending,
  seed: 0,
  trace: false
)
