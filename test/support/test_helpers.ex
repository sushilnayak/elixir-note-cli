defmodule Notes.TestHelpers do
  @moduledoc """
  Common test utilities and helpers for the Notes application.
  """

  @doc """
  Creates a temporary test file path that will be cleaned up.
  """
  def temp_file_path(prefix \\ "test_notes") do
    Path.join(System.tmp_dir!(), "#{prefix}_#{:rand.uniform(10000)}.json")
  end

  @doc """
  Cleans up test files and directories.
  """
  def cleanup_test_files do
    # Clean up common test files
    test_files = [
      "test_notes.json",
      "test_cli_notes.json",
      "test_integration_notes.json", 
      "test_acceptance_notes.json",
      "test_property_notes.json"
    ]
    
    Enum.each(test_files, fn file ->
      File.rm(file)
    rescue
      File.Error -> :ok  # File doesn't exist, that's fine
    end)
    
    # Clean up test directories
    test_dirs = ["test_dir"]
    Enum.each(test_dirs, fn dir ->
      File.rm_rf(dir)
    rescue
      File.Error -> :ok  # Directory doesn't exist, that's fine
    end)
  end

  @doc """
  Cleans up a specific test file safely.
  """
  def cleanup_test_file(file_path) do
    File.rm(file_path)
  rescue
    File.Error -> :ok  # File doesn't exist, that's fine
  end

  @doc """
  Creates sample test notes for testing.
  """
  def sample_notes do
    [
      %{"id" => 1, "content" => "First test note"},
      %{"id" => 2, "content" => "Second test note"},
      %{"id" => 3, "content" => "Third test note"}
    ]
  end

  @doc """
  Asserts that a file contains the expected JSON content.
  """
  def assert_file_content(file_path, expected_content) do
    assert File.exists?(file_path)
    content = File.read!(file_path)
    decoded = Jason.decode!(content)
    assert decoded == expected_content
  end

  @doc """
  Ensures test file is clean before test starts.
  """
  def ensure_clean_test_file(file_path) do
    cleanup_test_file(file_path)
    :ok
  end
end
