defmodule NotesTest do
  use ExUnit.Case
  doctest Notes

  @test_file "test_notes.json"

  setup do
    try do
      File.rm(@test_file)
    rescue
      File.Error -> :ok
    end

    on_exit(fn ->
      try do
        File.rm(@test_file)
      rescue
        File.Error -> :ok
      end
    end)

    :ok
  end

  describe "add_note/2" do
    test "adds a new note with auto-incremented id" do
      new_note = Notes.add_note("Test note", @test_file)

      assert {:ok, %{"content" => "Test note", "id" => 1}} = new_note
    end

    test "increments id correctly for existing notes" do
      # Test with existing notes
      Notes.add_note("First note", @test_file)
      Notes.add_note("Second note", @test_file)
      new_note = Notes.add_note("Third note", @test_file)

      assert {:ok, %{"content" => "Third note", "id" => 3}} = new_note
    end
  end

  describe "find_note/2" do
    test "finds note by id" do
      Notes.add_note("Test note", @test_file)
      result = Notes.find_note(1, @test_file)
      assert {:ok, %{"id" => 1, "content" => "Test note"}} = result
    end

    test "returns error for non-existent id" do
      result = Notes.find_note(999, @test_file)
      assert {:error, :not_found} = result
    end
  end

  describe "list_notes/1" do
    test "returns all notes" do
      Notes.add_note("First note", @test_file)
      Notes.add_note("Second note", @test_file)
      notes = Notes.list_notes(@test_file)
      assert length(notes) == 2
      assert Enum.any?(notes, &(&1["content"] == "First note"))
      assert Enum.any?(notes, &(&1["content"] == "Second note"))
    end
  end

  describe "next_id/1" do
    test "returns 1 for empty list" do
      new_note = Notes.add_note("Test", @test_file)
      assert {:ok, %{"id" => 1}} = new_note
    end

    test "increments from max id" do
      Notes.add_note("First note", @test_file)
      Notes.add_note("Second note", @test_file)
      new_note = Notes.add_note("Test", @test_file)
      assert {:ok, %{"id" => 3}} = new_note
    end
  end
end