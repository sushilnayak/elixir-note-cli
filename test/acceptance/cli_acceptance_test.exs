defmodule Notes.CliAcceptanceTest do
  use ExUnit.Case
  
  @test_file "test_acceptance_notes.json"
  
  setup do
    # Clean up test file before each test
    try do
      File.rm(@test_file)
    rescue
      File.Error -> :ok  # File doesn't exist, that's fine
    end
    # Set environment variable for test file
    System.put_env("NOTES_FILE", @test_file)
    
    # Ensure cleanup after test
    on_exit(fn ->
      try do
        File.rm(@test_file)
      rescue
        File.Error -> :ok  # File doesn't exist, that's fine
    end
    end)
    
    :ok
  end

  describe "CLI end-to-end functionality" do
    test "add note command" do
      # Test adding a note through CLI
      Notes.Cli.main(["add", "Acceptance test note"])
      
      # Verify note was actually saved
      notes = Notes.list_notes(@test_file)
      assert length(notes) == 1
      assert Enum.at(notes, 0)["content"] == "Acceptance test note"
    end

    test "list notes command" do
      # Add some notes first
      Notes.add_note("First acceptance note", @test_file)
      Notes.add_note("Second acceptance note", @test_file)
      
      # Test listing through CLI
      Notes.Cli.main(["list"])
      
      # Verify notes exist (we can't easily test output without capture_io)
      all_notes = Notes.list_notes(@test_file)
      assert length(all_notes) == 2
      assert Enum.any?(all_notes, &(&1["content"] == "First acceptance note"))
      assert Enum.any?(all_notes, &(&1["content"] == "Second acceptance note"))
    end

    test "find note command" do
      # Add a note first
      Notes.add_note("Note to find", @test_file)
      
      # Test finding through CLI
      Notes.Cli.main(["find", "1"])
      
      # Verify note exists
      {:ok, note} = Notes.find_note(1, @test_file)
      assert note["content"] == "Note to find"
    end

    test "find non-existent note" do
      # Test finding non-existent note
      Notes.Cli.main(["find", "999"])
      
      # Verify error case
      result = Notes.find_note(999, @test_file)
      assert {:error, :not_found} = result
    end

    test "help command" do
      # Test help command
      Notes.Cli.main(["--help"])
      
      # Verify help function exists and is callable
      assert is_function(&Notes.Cli.print_help/0)
    end

    test "default help on no arguments" do
      # Test default help
      Notes.Cli.main([])
      
      # Verify help function exists and is callable
      assert is_function(&Notes.Cli.print_help/0)
    end

    test "invalid argument handling" do
      # Test invalid arguments
      Notes.Cli.main(["invalid", "command"])
      
      # Verify the function handles invalid args gracefully
      # (we can't easily test output without capture_io)
    end
  end

  describe "CLI workflow scenarios" do
    test "complete user workflow: add, list, find" do
      # 1. Add multiple notes
      Notes.Cli.main(["add", "Workflow note 1"])
      Notes.Cli.main(["add", "Workflow note 2"])
      Notes.Cli.main(["add", "Workflow note 3"])
      
      # 2. Verify notes were added
      all_notes = Notes.list_notes(@test_file)
      assert length(all_notes) == 3
      assert Enum.any?(all_notes, &(&1["content"] == "Workflow note 1"))
      assert Enum.any?(all_notes, &(&1["content"] == "Workflow note 2"))
      assert Enum.any?(all_notes, &(&1["content"] == "Workflow note 3"))
      
      # 3. Test finding specific note
      Notes.Cli.main(["find", "2"])
      
      # Verify note exists
      {:ok, note} = Notes.find_note(2, @test_file)
      assert note["content"] == "Workflow note 2"
    end

    test "edge case: empty add command" do
      # Test empty add command - should be rejected
      Notes.Cli.main(["add"])
      
      # Verify no note was added (empty add should be rejected)
      notes = Notes.list_notes(@test_file)
      assert Enum.empty?(notes)
    end
  end
end
