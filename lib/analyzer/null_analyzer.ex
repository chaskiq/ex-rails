defmodule ActiveStorage.Analyzer.NullAnalyzer do
  def accept?(_blob) do
    true
  end

  def analyze_later? do
    false
  end

  def metadata do
    %{}
  end
end
