class String
  def unindent
    first_line_spaces = self[/\A\s*/]
    gsub(/^#{first_line_spaces}/, '')
  end

  def hexdecode
    scan(/../).map(&:hex).map(&:chr).join
  end
end
