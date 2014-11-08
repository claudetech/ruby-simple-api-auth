class String
  def hexdecode
    scan(/../).map(&:hex).map(&:chr).join
  end
end
