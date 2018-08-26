defmodule Identicon do
  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
  end

  def pick_color(%Identicon.Image{ hex: [r, g, b | _tail] } = image) do
    %Identicon.Image{ image | color: { r, g, b } }
  end

  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end

  def build_grid(%Identicon.Image{ hex: hex_list } = image) do
    hex_list
    |> Enum.chunk(3)
    |> mirrow_row
  end
  
  def mirrow_row(lists) do
    for list <- lists do
      rev_list = Enum.reverse(list)
      front = Enum.take(list, length(list) - 1)
      Enum.concat(front, rev_list)
    end
  end
end