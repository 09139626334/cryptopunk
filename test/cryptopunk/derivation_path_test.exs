defmodule Cryptopunk.DerivationPathTest do
  use ExUnit.Case

  alias Cryptopunk.DerivationPath

  describe "parse/1" do
    test "parses path" do
      path = "m/44'/2'/0'/0/1"

      assert {:ok,
              %DerivationPath{
                account: 0,
                address_index: 1,
                change: 0,
                coin_type: 2,
                purpose: 44,
                type: :private
              }} = DerivationPath.parse(path)
    end

    test "fails to parse invalid string" do
      assert {:error, :invalid_path} = DerivationPath.parse("invalid")
    end

    test "fails is the level is not hardened" do
      path = "m/44'/2 /0'/0/1"

      assert {:error, {:invalid_level, :coin_type}} = DerivationPath.parse(path)
    end
  end
end
