class Category < ActiveRecord::Base
  has_many :products, dependent: :destroy
  
  def filter_groups
    filters = []
    filter_groups = FilterValue.joins(sub_products: :product).where(products: {category_id: self.id}).order(filter_name_id: :asc).uniq.group_by(&:filter_name_id)
    filter_groups.each do |index, value|
      filter_name = FilterName.find(index).name
      filters << {:name => filter_name, :items => value }
    end
    filters
  end

  def products(filters)
    if filters.length > 0 
      subs = SubProduct
              .joins(:filter_values)
              .where('filter_values.id' => filters)
              .group('1,2')
              .having("COUNT(filter_values.id) =#{filters.length}")
              .uniq
              .map(&:product_id)
      Product.where(:id => subs, :category_id => self.id).uniq
    else
      Product.where('category_id' => self.id)
    end
  end

end
