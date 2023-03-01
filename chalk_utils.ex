defmodule Chalk.Utils do
  def hex_to_rgb(<<"#", hex::binary>>) do
    hex_to_rgb(hex)
  end

  def hex_to_rgb(<<hex_red::binary-size(2), hex_green::binary-size(2), hex_blue::binary-size(2)>>) do
    {hex_to_decimal(hex_red), hex_to_decimal(hex_green), hex_to_decimal(hex_blue)}
  end

  def hex_to_rgb(<<hex_red::binary-size(1), hex_green::binary-size(1), hex_blue::binary-size(1)>>) do
    {r, g, b} = {hex_to_decimal(hex_red), hex_to_decimal(hex_green), hex_to_decimal(hex_blue)}
    {r * 17, g * 17, b * 17}
  end

  defp hex_to_decimal(<<v, v2>>) do
    hex_to_decimal(v) * 16 + hex_to_decimal(v2)
  end

  defp hex_to_decimal(<<v>>), do: hex_to_decimal(v)
  defp hex_to_decimal(v) when v > 96 and v < 103, do: v - 87
  defp hex_to_decimal(v) when v > 47 and v < 58, do: v - 48
end
