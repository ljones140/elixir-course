defmodule HangmanImplGameTest do
  use ExUnit.Case

  alias Hangman.Impl.Game

  test "new game returns struct" do
    game = Game.new_game()

    assert game.turns_left == 7
    assert game.game_state == :initializing
    assert length(game.letters) > 0
  end

  test "new game returns word as list" do
    word = "wombat"
    game = Game.new_game(word)

    assert game.letters == String.codepoints(word)
    assert Enum.all?(game.letters, &String.match?(&1, ~r/^[a-z]+$/))
  end
end
