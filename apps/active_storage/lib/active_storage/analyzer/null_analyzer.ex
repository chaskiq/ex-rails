defmodule ActiveStorage.Analyzer.NullAnalyzer do
  use ActiveStorage.Analyzer

  def accept?(_blob) do
    true
  end

  def analyze_later? do
    false
  end

  def metadata(_blob) do
    %{}
  end
end
