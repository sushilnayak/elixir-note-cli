defmodule Notes.Cli do
  alias Notes

  def main(args) do
    case parse_args(args) do
      {:add, content} ->
        case Notes.add_note(content, get_notes_file()) do
          {:ok, note} ->
            IO.puts("New Note added with id=#{note["id"]} and content:#{note["content"]}")
        end

      {:list, _} ->
        IO.puts("--- All Notes ---")

        Enum.each(Notes.list_notes(get_notes_file()), fn note ->
          IO.puts("#{note["id"]} - #{note["content"]}")
        end)

        IO.puts("-----------------")

      {:find, id} ->
        case Notes.find_note(id, get_notes_file()) do
          {:error, :not_found} -> IO.puts("Note with id #{id} not found")
          {:ok, note} -> IO.inspect(note, label: "Found note ##{id}")
        end

      {:help} ->
        print_help()

      {_} ->
        IO.puts("Invalid arguemnt, try --help")
        print_help()
    end
  end

  defp parse_args(["add" | content]) when content != [], do: {:add, Enum.join(content, " ")}
  defp parse_args(["find", id_str]), do: {:find, String.to_integer(id_str)}
  defp parse_args(["list"]), do: {:list, nil}
  defp parse_args(["--help"]), do: {:help}
  defp parse_args([]), do: {:help}
  defp parse_args(_), do: {:error}

  defp print_help do
    IO.puts("""
    Usage:
      notes add <content>    # Adds a new note
      notes find <id>        # Finds a note by its ID
      notes list             # Lists all notes
    """)
  end

  defp get_notes_file do
    System.get_env("NOTES_FILE") || "notes.json"
  end
end
