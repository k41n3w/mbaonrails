require "tty-table"

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
    select { |sale| sale[:amount] > average }
  end

  def print_sales_table
    print_table("Todas as Vendas", @sales)
  end

  def print_top_sales(n)
    top = top_sales(n)
    print_table("Top #{n} Vendas", top)
  end

  def print_above_average_sales
    average = map { |sale| sale[:amount] }.sum.to_f / count
    print_table("Vendas Acima da Média", above_average_sales)
  end

  def print_total_by_category
    data = total_by_category.map do |category, total|
      [category, "R$#{'%.2f' % total}"]
    end
    table = TTY::Table.new(["Categoria", "Total de Vendas"], data)
    puts table.render(:unicode)
  end

  def print_grouped_by_category
    data = grouped_by_category.map do |category, products|
      [category, products.join(", ")]
    end
    table = TTY::Table.new(["Categoria", "Produtos"], data)
    puts table.render(:unicode)
  end

  private

  def print_table(title, sales)
    puts "\n#{title}"
    headers = ["Produto", "Categoria", "Valor (R$)"]
    rows = sales.map do |sale|
      [sale[:product], sale[:category], "R$#{'%.2f' % sale[:amount]}"]
    end
    table = TTY::Table.new(headers, rows)
    puts table.render(:unicode)
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

report.print_sales_table
report.print_top_sales(3)
report.print_above_average_sales
report.print_total_by_category
report.print_grouped_by_category
