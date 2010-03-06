class Range
  def random
    width = (self.last - self.first).to_i
    width -= 1  if self.exlude_end?
    self.first + width.rand
  end
end
