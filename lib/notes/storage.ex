defmodule Notes.Storage do
  @moduledoc """
  Handles persistent storage operations for notes.
  
  Provides functions to save and retrieve notes from JSON files.
  """
  
  def save_notes(notes, file) do
    File.mkdir_p(Path.dirname(file))
    File.write!(file, Jason.encode!(notes, pretty: true))
  end

  def get_notes(file) do
    case File.read(file) do
      {:ok, content} -> Jason.decode!(content)
      {:error, :enoent} -> []
    end
  end
end
