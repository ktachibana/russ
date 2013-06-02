class Object
  def if_true
    self && yield(self)
  end
end
