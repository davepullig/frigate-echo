require 'yaml'

class Config
  def self.load(config_path)
    deep_symbolize(YAML.load_file(config_path))
  end

  def self.deep_symbolize(obj)
    case obj
    when Hash
      obj.each_with_object({}) { |(k, v), h| h[k.to_sym] = deep_symbolize(v) }
    when Array
      obj.map { |v| deep_symbolize(v) }
    else
      obj
    end
  end
end