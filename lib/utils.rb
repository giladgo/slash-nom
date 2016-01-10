class Utils

  def self.emoji?(str)
    str.end_with?(':') and str.start_with?(':')
  end

  def self.unemojify(emoji)
    self.emoji?(emoji) ? emoji[1..-2] : emoji
  end

end
