defmodule Notes.Storage do
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
