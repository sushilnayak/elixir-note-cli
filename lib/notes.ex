defmodule Notes do
  alias Notes.Storage

  def add_note(note, file \\ "notes.json") do
    notes = Storage.get_notes(file)
    new_note = %{"content" => note, "id" => next_id(notes)}
    Storage.save_notes(notes ++ [new_note], file)

    {:ok, new_note}
  end

  def find_note(id, file \\ "notes.json") do
    case Storage.get_notes(file) |> Enum.find(&(&1["id"] == id)) do
      nil -> {:error, :not_found}
      note -> {:ok, note}
    end
  end

  def list_notes(file \\ "notes.json") do
    Storage.get_notes(file)
  end

  defp next_id([]), do: 1

  defp next_id(notes) do
    Enum.max(notes |> Enum.map(& &1["id"])) + 1
  end
end
