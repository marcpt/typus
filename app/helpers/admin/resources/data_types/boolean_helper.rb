module Admin::Resources::DataTypes::BooleanHelper

  def display_boolean(item, attribute)
    status = item.send(attribute).to_s
    item.class.typus_boolean(attribute).rassoc(status).first
  end

  def table_boolean_field(attribute, item)
    options = {
      controller: "/admin/#{item.class.to_resource}",
      action: 'toggle',
      id: item.id,
      field: attribute.gsub(/\?$/, '')
    }

    human_boolean = display_boolean(item, attribute)
    link_to Typus::I18n.t(human_boolean), options
  end

  def boolean_filter(filter)
    values  = @resource.typus_boolean(filter)
    attribute = @resource.human_attribute_name(filter)

    items = [[attribute.titleize, '']]
    array = values.map { |k, v| ["#{attribute}:#{Typus::I18n.t(k.humanize)}", v] }

    items + array
  end

end
