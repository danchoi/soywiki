
class String
  # not Windows compatible 
  def to_file_path
    self.gsub(".", "/")
  end

  def to_page_title
    self.gsub("/", ".")
  end

  def short_page_title
    self.to_page_title.split('.')[1]
  end

  def namespace
    self.to_page_title.split('.')[0]
  end
end


