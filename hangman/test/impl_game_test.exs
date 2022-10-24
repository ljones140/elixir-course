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

    assert MapSet.equal?(game.used, MapSet.new(["x", "y"]))
  end

  test "we recognise letter in a word" do
    game = Game.new_game("wombat")

    {game, tally} = Game.make_move(game, "w")
    assert tally.game_state == :good_guess

    {_, tally} = Game.make_move(game, "o")
    assert tally.game_state == :good_guess
  end

  test "we recognise a letter not in the word" do
    game = Game.new_game("wombat")

    {game, tally} = Game.make_move(game, "x")
    assert tally.game_state == :bad_guess

    {game, tally} = Game.make_move(game, "w")
    assert tally.game_state == :good_guess

    {_, tally} = Game.make_move(game, "y")
    assert tally.game_state == :bad_guess
  end

  test "can handle a sequence of moves" do
    [
      # guess | state     turns  letters                     used
      ["a", :bad_guess, 6, ["_", "_", "_", "_", "_"], ["a"]],
      ["a", :already_used, 6, ["_", "_", "_", "_", "_"], ["a"]],
      ["e", :good_guess, 6, ["_", "e", "_", "_", "_"], ["a", "e"]],
      ["x", :bad_guess, 5, ["_", "e", "_", "_", "_"], ["a", "e", "x"]]
    ]
    |> test_sequence_of_moves()
  end

  test "can handle a winning game" do
    [
      # guess | state     turns  letters                     used
      ["a", :bad_guess, 6, ["_", "_", "_", "_", "_"], ["a"]],
      ["a", :already_used, 6, ["_", "_", "_", "_", "_"], ["a"]],
      ["e", :good_guess, 6, ["_", "e", "_", "_", "_"], ["a", "e"]],
      ["x", :bad_guess, 5, ["_", "e", "_", "_", "_"], ["a", "e", "x"]],
      ["l", :good_guess, 5, ["_", "e", "l", "l", "_"], ["a", "e", "l", "x"]],
      ["o", :good_guess, 5, ["_", "e", "l", "l", "o"], ["a", "e", "l", "o", "x"]],
      ["y", :bad_guess, 4, ["_", "e", "l", "l", "o"], ["a", "e", "l", "o", "x", "y"]],
      ["h", :won, 4, ["h", "e", "l", "l", "o"], ["a", "e", "h", "l", "o", "x", "y"]]
    ]
    |> test_sequence_of_moves()
  end

  test "can handle a losing game" do
    [
      # guess | state     turns  letters                     used
      ["a", :bad_guess, 6, ["_", "_", "_", "_", "_"], ["a"]],
      ["b", :bad_guess, 5, ["_", "_", "_", "_", "_"], ["a", "b"]],
      ["c", :bad_guess, 4, ["_", "_", "_", "_", "_"], ["a", "b", "c"]],
      ["d", :bad_guess, 3, ["_", "_", "_", "_", "_"], ["a", "b", "c", "d"]],
      ["e", :good_guess, 3, ["_", "e", "_", "_", "_"], ["a", "b", "c", "d", "e"]],
      ["f", :bad_guess, 2, ["_", "e", "_", "_", "_"], ["a", "b", "c", "d", "e", "f"]],
      ["g", :bad_guess, 1, ["_", "e", "_", "_", "_"], ["a", "b", "c", "d", "e", "f", "g"]],
      ["h", :good_guess, 1, ["h", "e", "_", "_", "_"], ["a", "b", "c", "d", "e", "f", "g", "h"]],
      ["i", :lost, 0, ["h", "e", "_", "_", "_"], ["a", "b", "c", "d", "e", "f", "g", "h", "i"]]
    ]
    |> test_sequence_of_moves()
  end

  def test_sequence_of_moves(script) do
    game = Game.new_game("hello")
    Enum.reduce(script, game, &check_one_move/2)
  end

  defp check_one_move([guess, state, turns, letters, used], game) do
    {game, tally} = Game.make_move(game, guess)

    assert tally.game_state == state
    assert tally.turns_left == turns
    assert tally.letters == letters
    assert tally.used == used

    game
  end
end
