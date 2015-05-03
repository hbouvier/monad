defmodule OptionTest do
  use ExUnit.Case, async: true
  require Monad
  require Option

  test "Option.some wrap the value" do
    option = Option.some("thing")
    refute option == "thing"
    refute option == Option.none
    assert option == Option.some("thing")
    case option do
      Option.some(thing) -> assert thing == "thing"
    end
  end

  test "Option.get unwrap the value" do
    option = Option.some("thing")
    assert option |> Monad.get == "thing"
  end

  test "Option.none behave has the absence of a value" do
    option = Option.none
    refute option == Option.some("thing")
    assert option == Option.none
    case option do
      Option.some(thing) -> raise "Must never match, but got '#{thing}'"
      Option.none -> assert option == Option.none
    end
  end

  test "Option.some of nil behave has none (or the absence of a value)" do
    assert Option.some(nil) == Option.none
  end

  test "Option.none is empty?" do
    assert Option.none |> Option.empty? == true
  end

  test "Option.some is not empty?" do
    assert Option.some("value") |> Option.empty? == false
  end

  test "Option.get_or_else of a value return the unwrapped value" do
    option = Option.some("thing")
    assert Option.get_or_else(option, "not this") == "thing"
    refute Option.get_or_else(option, "not this") == "not this"
  end

  test "Option.get_or_else of none will return the default value" do
    assert Option.get_or_else(Option.none, "default") == "default"
    catch_error(Option.none |> Monad.get)
  end

  test "Option.or_else of a Some(7) and None returns Some(7)" do
    assert Option.some(7) |> Option.or_else(Option.none) |> Monad.get == 7
  end

  test "Option.or_else of Some(1) and Some(2) returns Some(1)" do
    assert Option.some(1) |> Option.or_else(Option.some(2)) |> Monad.get == 1
  end

  test "Option.or_else of None and Some(2) returns Some(2)" do
    assert Option.none |> Option.or_else(Option.some(2)) |> Monad.get == 2
  end

  test "Option.or_else of None and None returns None" do
    assert Option.none |> Option.or_else(Option.none) |> Option.empty? == true
  end

  test "Option.map on a value call the transformation function and wrap the result in an Option" do
    assert "something" == Monad.map(Option.some("thing"), fn(value)-> "some#{value}" end) |> Monad.get
  end

  test "Option.map on none return none without calling the transformation function" do
    assert Monad.map(Option.none, fn(_)-> raise "Must never be executed" end) == Option.none
  end

  test "map a list of Options" do
    list = [Option.some(1), Option.none, Option.some(2), Option.some("the end"), Option.none]
    |> Monad.map(&(&1))
    assert list == [Option.some(1), Option.none, Option.some(2), Option.some("the end"), Option.none]
  end


  test "Option.flat_map on a value some call the transformation funtion an return the result as is (no wrapping)" do
    assert Option.some("something") |> Monad.flat_map(fn(value) -> Option.some("#{value} else") end) == Option.some("something else")
  end

  test "flat_map Option.none return none without calling the transformation function" do
    assert Option.none |> Monad.flat_map(fn(_value) -> raise "should not execute" end) == Option.none
  end

  test "flat_map a list of Options" do
    list = [Option.some(1), Option.none, Option.some(2), Option.some("the end"), Option.none]
    |> Monad.flat_map(&(&1))
    assert list == [1, 2, "the end"]
  end

  test "flat_map a list of Option.none" do
    list = [Option.none, Option.none]
    |> Monad.flat_map(&(&1))
    assert list == []
  end

  # test "Option.flat_map fails when the transformation function does not return the result wrapped in an Option" do
  #   # catch_error some("something") |> flat_map(fn(value) -> "#{value} else" end)
  #   assert_raise(
  #     OptionException,
  #     "Option.flat_map: Transformation function return type is an Option. '\"something else\"' is not an Option.",
  #     fn -> Option.some("something") |> Monad.flat_map(fn(value) -> "#{value} else" end) end
  #   )
  # end
end
