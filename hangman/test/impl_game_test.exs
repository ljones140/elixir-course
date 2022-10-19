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

  test "state does not change if game is complete" do
    for state <- [:won, :lost] do
      game = Game.new_game("wombat")
      game = Map.put(game, :game_state, state)
      {new_game, _tally} = Game.make_move(game, "x")
      assert new_game == game
    end
  end

  test "duplicate letter guessed" do
    game = Game.new_game()

    {game, _tally} = Game.make_move(game, "x")
    assert game.game_state != :already_used

    {game, _tally} = Game.make_move(game, "y")
    assert game.game_state != :already_used

    {game, _tally} = Game.make_move(game, "x")
    assert game.game_state == :already_used
  end

  test "record letters guessed" do
    game = Game.new_game()

    {game, _tally} = Game.make_move(game, "x")
    {game, _tally} = Game.make_move(game, "y")
    {game, _tally} = Game.make_move(game, "x")

    assert MapSet.equal?(game.used, MapSet.new(["x","y"]))
  end
end
