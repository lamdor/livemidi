module MessageCatcher

  def message(*params)
    @sent_messages ||= []
    @sent_messages << params
  end

  def sent_messages
    @sent_messages
  end

end
