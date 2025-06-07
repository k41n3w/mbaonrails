class SalesReport
  include Enumerable

  def initialize(sales)
    @sales = sales
  end

  def each(&block)
    @sales.each(&block)
  end

  def total_by_category
    each.with_object(Hash.new(0)) do |sale, totals|
      totals[sale[:category]] += sale[:amount]
    end
  end

  def top_sales(n)
    @sales.sort_by { |sale| -sale[:amount] }.first(n)
  end

  def grouped_by_category
    each.group_by { |sale| sale[:category] }
        .transform_values { |sales| sales.map { |sale| sale[:product] } }
  end

  def above_average_sales
    average = map { |sale| sale[:amount] }.sum.to_f / count
    result = select { |sale| sale[:amount] > average }
    puts "O valor médio é: R$#{'%.2f' % average}"
    result
  end
end

sales = [
  { product: "Notebook", category: "Eletrônicos", amount: 3000 },
  { product: "Celular", category: "Eletrônicos", amount: 1500 },
  { product: "Cadeira", category: "Móveis", amount: 500 },
  { product: "Mesa", category: "Móveis", amount: 1200 },
  { product: "Headphone", category: "Eletrônicos", amount: 300 },
  { product: "Armário", category: "Móveis", amount: 800 }
]

report = SalesReport.new(sales)

puts "Total por categoria:"
puts report.total_by_category

puts "\nTop 3 vendas:"
puts report.top_sales(3)

puts "\nAgrupado por categoria:"
puts report.grouped_by_category

puts "\nVendas acima da média:"
puts report.above_average_sales
