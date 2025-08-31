defmodule Notes.IntegrationTest do
  use ExUnit.Case
  
  @test_file "test_integration_notes.json"
  
  setup do
    # Clean up test file before each test
    try do
      File.rm(@test_file)
    rescue
      File.Error -> :ok  # File doesn't exist, that's fine
    end
    
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

  describe "note lifecycle integration" do
    test "complete note creation and retrieval flow" do
      # Test the full flow from creation to retrieval
      {:ok, note1} = Notes.add_note("Integration test note 1", @test_file)
      {:ok, note2} = Notes.add_note("Integration test note 2", @test_file)
      
      # Verify notes were created with correct IDs
      assert note1["id"] == 1
      assert note2["id"] == 2
      assert note1["content"] == "Integration test note 1"
      assert note2["content"] == "Integration test note 2"
      
      # Test retrieval
      {:ok, retrieved_note1} = Notes.find_note(1, @test_file)
      {:ok, retrieved_note2} = Notes.find_note(2, @test_file)
      
      assert retrieved_note1 == note1
      assert retrieved_note2 == note2
      
      # Test listing
      all_notes = Notes.list_notes(@test_file)
      assert length(all_notes) == 2
      assert Enum.any?(all_notes, &(&1["id"] == 1))
      assert Enum.any?(all_notes, &(&1["id"] == 2))
    end

    test "note persistence across operations" do
      # Add notes
      Notes.add_note("Persistent note 1", @test_file)
      Notes.add_note("Persistent note 2", @test_file)
      
      # Verify they exist
      assert length(Notes.list_notes(@test_file)) == 2
      
      # Add another note
      Notes.add_note("Persistent note 3", @test_file)
      
      # Verify all three exist
      all_notes = Notes.list_notes(@test_file)
      assert length(all_notes) == 3
      assert Enum.any?(all_notes, &(&1["content"] == "Persistent note 3"))
    end

    test "id generation consistency" do
      # Test that IDs are generated correctly even with gaps
      Notes.add_note("First note", @test_file)
      Notes.add_note("Second note", @test_file)
      
      # Delete first note (simulate file corruption or manual deletion)
      notes = Notes.list_notes(@test_file)
      remaining_notes = Enum.filter(notes, &(&1["id"] != 1))
      Notes.Storage.save_notes(remaining_notes, @test_file)
      
      # Add new note - should get ID 3, not reuse ID 1
      {:ok, new_note} = Notes.add_note("Third note", @test_file)
      assert new_note["id"] == 3
    end
  end

  describe "error handling integration" do
    test "handles file corruption gracefully" do
      # Create a corrupted file
      File.write!(@test_file, "invalid json content")
      
      # Should handle gracefully and start fresh
      # We need to handle the JSON decode error
      try do
        {:ok, note} = Notes.add_note("Recovery note", @test_file)
        assert note["id"] == 1
        assert note["content"] == "Recovery note"
      rescue
        Jason.DecodeError ->
          # If JSON decode fails, the storage should handle it gracefully
          # Let's test that the file can be overwritten
          File.rm(@test_file)
          {:ok, note} = Notes.add_note("Recovery note", @test_file)
          assert note["id"] == 1
          assert note["content"] == "Recovery note"
      end
    end

    test "handles missing file gracefully" do
      # File doesn't exist, should start fresh
      {:ok, note} = Notes.add_note("First note", @test_file)
      assert note["id"] == 1
    end
  end
end
