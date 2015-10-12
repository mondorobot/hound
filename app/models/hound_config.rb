class HoundConfig
  CONFIG_FILE = ".hound.yml"
  BETA_LANGUAGES = %w(
    python
    swift
  )
  LANGUAGES = %w(
    coffeescript
    go
    haml
    javascript
    python
    ruby
    scss
    swift
  )

  attr_reader_initialize :commit

  def content
    @content ||= parse(commit.file_content(CONFIG_FILE))
  end

  def enabled_for?(name)
    supported_language?(name) || configured?(name)
  end

  def fail_on_violations?
    !!(content["fail_on_violations"])
  end

  private

  def parse(file_content)
    Config::Parser.yaml(file_content) || {}
  end

  def supported_language?(name)
    key = normalize_key(name)

    (LANGUAGES - BETA_LANGUAGES).include?(key) && configured?(key)
  end

  def configured?(name)
    key = normalize_key(name)

    content[key] &&
      (content[key]["enabled"] || content[key]["Enabled"])
  end

  def normalize_key(key)
    key.downcase.sub("_", "")
  end
end
