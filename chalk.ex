defmodule Chalk do
  defstruct content: []

  defimpl String.Chars do
    def to_string(%Chalk{} = chalk) do
      Chalk.to_string(chalk)
    end
  end

  defimpl Inspect do
    def inspect(%Chalk{} = chalk, _) do
      Chalk.to_string(chalk)
    end
  end

  @colors [
    :black,
    :red,
    :green,
    :yellow,
    :blue,
    :magenta,
    :cyan,
    :white
  ]

  @start [
    color: 30,
    bg: 40,
    bright_color: 90,
    bright_bg: 100,
    reset: 20
  ]

  @modifiers [
    bold: {1, 1},
    faint: 2,
    italic: 3,
    underline: 4,
    blink: 5,
    rapid_blink: {6, -1},
    invert: 7,
    hide: 8,
    strike: 9
  ]

  @reset 0
  @set_color 38
  @reset_color 39
  @set_bg 48
  @reset_bg 49

  def init(text) when is_bitstring(text) do
    %Chalk{content: text}
  end

  for {name, code} <- Enum.with_index(@colors) do
    # colors
    def unquote(:"#{name}")(%Chalk{content: content}) do
      %Chalk{
        content: [
          unquote("\e[#{code + @start[:color]}m"),
          content,
          unquote("\e[#{@reset_color}m")
        ]
      }
    end

    def unquote(:"#{name}")(text) do
      unquote("\e[#{code + @start[:color]}m") <> text <> unquote("\e[#{@reset_color}m")
    end

    # bg_colors
    def unquote(:"bg_#{name}")(%Chalk{content: content}) do
      %Chalk{
        content: [unquote("\e[#{code + @start[:bg]}m"), content, unquote("\e[#{@reset_bg}m")]
      }
    end

    def unquote(:"bg_#{name}")(text) do
      unquote("\e[#{code + @start[:bg]}m") <> text <> unquote("\e[#{@reset_bg}m")
    end

    # bright colors
    def unquote(:"bright_#{name}")(%Chalk{content: content}) do
      %Chalk{
        content: [
          unquote("\e[#{code + @start[:bright_color]}m"),
          content,
          unquote("\e[#{@reset_color}m")
        ]
      }
    end

    def unquote(:"bright_#{name}")(text) do
      unquote("\e[#{code + @start[:bright_color]}m") <> text <> unquote("\e[#{@reset_color}m")
    end

    # bright bg_colors
    def unquote(:"bright_bg_#{name}")(%Chalk{content: content}) do
      %Chalk{
        content: [
          unquote("\e[#{code + @start[:bright_bg]}m"),
          content,
          unquote("\e[#{@reset_bg}m")
        ]
      }
    end

    def unquote(:"bright_bg_#{name}")(text) do
      unquote("\e[#{code + @start[:bright_bg]}m") <> text <> unquote("\e[#{@reset_bg}m")
    end
  end

  for {name, code} <- @modifiers do
    def unquote(:"#{name}")(%Chalk{content: content}) do
      %Chalk{
        content: [
          unquote(
            "\e[#{case code do
              {v, _} -> v
              _ -> code
            end}m"
          ),
          content,
          unquote(
            "\e[#{case code do
              {k, v} -> k + v
              _ -> code
            end + @start[:reset]}m"
          )
        ]
      }
    end

    def unquote(:"#{name}")(text) do
      unquote(
        "\e[#{case code do
          {v, _} -> v
          _ -> code
        end}m"
      ) <>
        text <>
        unquote(
          "\e[#{case code do
            {k, v} -> k + v
            _ -> code
          end + @start[:reset]}m"
        )
    end
  end

  def rgb(%Chalk{content: content}, r, g, b) do
    %Chalk{
      content: [
        "#{unquote("\e[#{@set_color};2;")}#{r};#{g};#{b}m",
        content,
        unquote("\e[#{@reset_bg}m")
      ]
    }
  end

  def rgb(text, r, g, b) do
    "#{unquote("\e[#{@set_color};2;")}#{r};#{g};#{b}m" <> text <> unquote("\e[#{@reset_bg}m")
  end

  def bg_rgb(%Chalk{content: content}, r, g, b) do
    %Chalk{
      content: [
        unquote("\e[#{@set_bg};2;"),
        "#{r};#{g};#{b}m",
        content,
        unquote("\e[#{@reset_bg}m")
      ]
    }
  end

  def bg_rgb(text, r, g, b) do
    "#{unquote("\e[#{@set_bg};2;")}#{r};#{g};#{b}m" <> text <> unquote("\e[#{@reset_bg}m")
  end

  def hex(text, color) do
    {r, g, b} = Chalk.Utils.hex_to_rgb(color)
    rgb(text, r, g, b)
  end

  def bg_hex(text, color) do
    {r, g, b} = Chalk.Utils.hex_to_rgb(color)
    bg_rgb(text, r, g, b)
  end

  def to_string(%Chalk{content: text}) do
    IO.iodata_to_binary(text)
  end
end
