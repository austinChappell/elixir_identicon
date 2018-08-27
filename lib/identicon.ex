defmodule Identicon do
  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_numbers
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
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
    grid =
      hex_list
      |> Enum.chunk_every(3, 3, :discard)
      |> Enum.map(&mirrow_row/1)
      |> List.flatten
      |> Enum.with_index
    
    %Identicon.Image{ image | grid: grid }
  end
  
  def mirrow_row(row) do
    [first, second | _tail] = row
    row ++ [second, first]
  end

  def filter_odd_numbers(%Identicon.Image{ grid: grid } = image) do
    grid = Enum.filter grid, fn({num, _idx}) ->
      rem(num, 2) == 0 
    end

    %Identicon.Image{ image | grid: grid }
  end

  def build_pixel_map(%Identicon.Image{ grid: grid } = image) do
    pixel_map = Enum.map grid, fn({_num, idx}) ->
      horiz = rem(idx, 5) * 50
      vert = div(idx, 5) * 50
      top_left = {horiz, vert}
      bottom_right = {horiz + 50, vert + 50}

      {top_left, bottom_right}
    end

    %Identicon.Image{ image | pixel_map: pixel_map }
  end

  def draw_image(%Identicon.Image{ color: color, pixel_map: pixel_map }) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

  def save_image(image, filename) do
    File.write("#{filename}.png", image)
  end

end
