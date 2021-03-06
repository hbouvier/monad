defmodule Option do
  @moduledoc """
  The Option monad is used to represent an Optional value. An Option can either be Some (wrapped value) or None to
  represent the absence of a value.
  """
  @type option :: {:some, any} | :none

  @some :some
  @none :none

  @doc """
  Represent the absence of a value (e.g. often represented by nil).
  """
  @spec none :: :none
  defmacro none, do: quote do: unquote(@none)

  @doc """
  Represent a value, wrapped in an Option.
  """
  @spec some(any) :: option
  defmacro some(nil), do: quote do: unquote(@none)
  defmacro some(value)  do
    case value do
      # {{:., [],  [{:__aliases__, [alias: false], [:Module]}, :function]}, [], ["params"]}
      {{:., [_|_], [{:__aliases__, [_|_], [_|_]}, atom]}, [_|_], [_|_]} when is_atom(atom) -> quote do
        case unquote(value) do
          nil -> unquote(@none)
          _ -> {unquote(@some), unquote(value)}
        end
      end
      _ -> quote do: {unquote(@some), unquote(value)}
    end
  end

  #defmacro some(value), do: quote do: {unquote(@some), unquote(value)}

  @doc """
  Test the value is absent (e.g. none).
  """
  @spec empty?(option) :: boolean
  def empty?(@none), do: true
  def empty?({@some, _}), do: false

  @doc """
  Returns the unwrapped value of the option or if no value (e.g.: none) return the default value
  """
  @spec get_or_else(option, any) :: any
	def get_or_else(@none, default), do: default
  def get_or_else({@some, value}, _default), do: value

  @doc """
  Returns the first_option if it is nonempty, otherwise return the next_option
  """
  @spec or_else(option, option) :: option
  def or_else(first_option = {@some, _value}, _next_option), do: first_option
  def or_else(@none, next_option), do: next_option
end