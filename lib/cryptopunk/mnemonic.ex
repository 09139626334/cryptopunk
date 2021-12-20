defmodule Cryptopunk.Mnemonic do
  @word_number_to_entropy_bits %{12 => 128, 15 => 160, 18 => 192, 21 => 224, 24 => 256}
  @word_numbers Map.keys(@word_number_to_entropy_bits)
  @words :cryptopunk
         |> :code.priv_dir()
         |> Path.join("words")
         |> File.stream!()
         |> Stream.map(&String.trim/1)
         |> Enum.to_list()

  @spec create(non_neg_integer()) :: String.t() | no_return
  def create(word_number \\ Enum.max(@word_numbers))

  def create(word_number) when word_number not in @word_numbers do
    raise ArgumentError,
      message:
        "Number of words #{inspect(word_number)} is not supported, please use one of the #{inspect(@word_numbers)} "
  end

  def create(word_number) do
    entropy_bits = Map.fetch!(@word_number_to_entropy_bits, word_number)

    entropy_bits
    |> create_entropy()
    |> append_checksum(entropy_bits)
    |> to_mnemonic()
  end

  defp create_entropy(entropy_bits) do
    entropy_bits
    |> div(8)
    |> :crypto.strong_rand_bytes()
  end

  defp append_checksum(entropy, entropy_bits) do
    checksum_size = div(entropy_bits, 32)
    <<checksum::bits-size(checksum_size), _::bits>> = ExKeccak.hash_256(entropy)

    entropy <> checksum
  end

  defp to_mnemonic(bytes) do
    words =
      for <<chunk::size(11) <- bytes>> do
        Enum.at(@words, chunk)
      end

    Enum.join(words, " ")
  end
end
