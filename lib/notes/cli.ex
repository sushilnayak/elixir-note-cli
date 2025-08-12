defmodule Notes.Cli do
  alias Notes

  def main(args) do
    case parse_args(args) do
      {:add, content} ->
        IO.puts("Adding content : #{content}")

      {:list, _} ->
        IO.puts("Listing content")

      {:find, id} ->
        IO.puts("Finding content for id : #{id}")

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
end
