class Vector2
  attr_reader :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end

  # Multiplicação com Numeric ou outro Vector2
  def *(other)
    case other
    when Numeric
      Vector2.new(@x * other, @y * other)
    when Vector2
      # Produto escalar (dot product)
      (@x * other.x) + (@y * other.y)
    else
      raise TypeError, "Multiplicação não suportada entre Vector2 e #{other.class}"
    end
  end

  # Multiplicação do tipo Numeric * Vector2
  def coerce(other)
    if other.is_a?(Numeric)
      [self, other]
    else
      raise TypeError, "Coerce falhou: #{other.class} não pode ser usado com Vector2"
    end
  end

  def to_s
    "(#{@x}, #{@y})"
  end
end

# Exemplo de uso:
v = Vector2.new(3, 4)
puts v * 2     # => (6, 8)
puts v * 2.5   # => (7.5, 10.0)
puts v * v     # => 25
puts 2 * v     # => (6, 8)
puts 2.5 * v   # => (7.5, 10.0)
