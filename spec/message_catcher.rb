module MessageCatcher

  def message(first, second, third)
    @sent_messages ||= []
    @sent_messages << [first, second, third]
  end

  def sent_messages
    @sent_messages
  end

end
