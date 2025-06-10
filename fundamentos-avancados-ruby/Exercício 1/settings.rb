class Settings
  def initialize
    @configurations = {}
    @aliases = {}
    @readonly = {}
  end

  def add(name, value, alias: nil, readonly: false)
    name = name.to_sym
    @configurations[name] = value
    @readonly[name] = readonly

    # Define método de leitura
    define_singleton_method(name) { @configurations[name] }

    # Define método de escrita se não for somente leitura
    unless readonly
      define_singleton_method("#{name}=") do |new_value|
        @configurations[name] = new_value
      end
    else
      define_singleton_method("#{name}=") do |_|
        raise "Erro: configuração '#{name}' é somente leitura"
      end
    end

    # Cria alias, se fornecido
    if binding.local_variable_get(:alias)
      alias_name = binding.local_variable_get(:alias).to_sym
      @aliases[alias_name] = name

      define_singleton_method(alias_name) { @configurations[name] }

      unless readonly
        define_singleton_method("#{alias_name}=") do |new_value|
          @configurations[name] = new_value
        end
      else
        define_singleton_method("#{alias_name}=") do |_|
          raise "Erro: configuração '#{alias_name}' é somente leitura (aponta para '#{name}')"
        end
      end
    end
  end

  def method_missing(method_name, *args)
    method_sym = method_name.to_sym

    # Getter
    if @configurations.key?(method_sym)
      return @configurations[method_sym]
    end

    # Alias
    if @aliases.key?(method_sym)
      return @configurations[@aliases[method_sym]]
    end

    # Setter dinâmico via method_missing
    if method_name.to_s.end_with?("=")
      config_name = method_name.to_s.chomp("=").to_sym
      real_name = @aliases[config_name] || config_name

      if @configurations.key?(real_name)
        if @readonly[real_name]
          raise "Erro: configuração '#{real_name}' é somente leitura"
        else
          return @configurations[real_name] = args.first
        end
      end
    end

    puts "Configuração '#{method_name}' não existe."
  end

  def respond_to_missing?(method_name, include_private = false)
    name = method_name.to_s.chomp("=").to_sym
    @configurations.key?(name) || @aliases.key?(name) || super
  end

  def all
    @configurations.dup
  end
end


# ------------------------------------------------------------------------------------------
settings = Settings.new

settings.add(:timeout, 30, alias: :espera)
settings.add(:mode, "production")
settings.add(:api_key, "SECRET", readonly: true)

puts settings.timeout     # => 30
puts settings.espera      # => 30
puts settings.mode        # => "production"
puts settings.api_key     # => "SECRET"

settings.timeout = 60
puts settings.timeout     # => 60

puts settings.respond_to?(:timeout)   # => true
puts settings.respond_to?(:retry)     # => false

puts settings.retry       # => "Configuração 'retry' não existe."

begin
  settings.api_key = "HACKED"
rescue => e
  puts e.message          # => Erro: configuração 'api_key' é somente leitura
end

puts settings.all         # => {:timeout=>60, :mode=>"production", :api_key=>"SECRET"}
