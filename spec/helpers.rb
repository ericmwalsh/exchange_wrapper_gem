module Helpers

  def text_fixture(name)
    File.read(File.join(File.dirname(__FILE__), 'fixtures', name.to_s))
  end

  def rb_fixture(name)
    eval(text_fixture("#{name}.rb"))
  end

  def json_fixture(name)
    JSON.parse(text_fixture("#{name}.json"))
  end

end
