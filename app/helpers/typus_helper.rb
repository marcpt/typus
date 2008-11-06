module TypusHelper

  ##
  # Applications list on the dashboard
  #
  def applications

    if Typus.applications.empty?
      return display_error("There are not defined applications in config/typus.yml")
    end

    html = ""

    Typus.applications.each do |app|

      available = []

      Typus.application(app).each do |resource|
        available << resource if @current_user.resources.include?(resource)
      end

      if !available.empty?

        html << <<-HTML
          <table>
            <tr>
              <th colspan="2">#{app}</th>
            </tr>
        HTML

        available.each do |model|
          description = Typus.module_description(model)
          html << "<tr class=\"#{cycle('even', 'odd')}\">\n"
          html << "<td>#{link_to model.titleize.pluralize, "/admin/#{model.tableize}"}<br /><small>#{description}</small></td>\n"
          html << "<td class=\"right\"><small>"
          html << "#{link_to 'Add', "/admin/#{model.tableize}/new"}" if @current_user.can_perform?(model, 'create')
          html << "</small></td>\n"
          html << "</tr>"
        end

        html << <<-HTML
          </table>
        HTML

      end

    end

    return html

  end

  ##
  # Resources (wich are not models) on the dashboard.
  #
  def resources

    available = []

    Typus.resources.each do |resource|
      available << resource if @current_user.resources.include?(resource)
    end

    if !available.empty?

      html = <<-HTML
        <table>
          <tr>
            <th colspan="2">Resources</th>
          </tr>
      HTML

      available.each do |resource|
        html << "<tr class=\"#{cycle('even', 'odd')}\">\n"
        html << "<td>#{link_to resource.titleize, "/admin/#{resource.tableize.singularize}"}</td>\n"
        html << "<td align=\"right\" style=\"vertical-align: bottom;\"></td>\n"
        html << "</tr>"
      end

      html << <<-HTML
        </table>
      HTML

    end

    return html rescue nil

  end

  def typus_block(name, location)
    render :partial => "admin/#{location}/#{name}" rescue nil
  end

  def display_error(error)
    "<div id=\"flash\" class=\"error\"><p>#{error}</p></div>"
  end

  def page_title
    crumbs = []
    crumbs << Typus::Configuration.options[:app_name]
    crumbs << @model.name.pluralize if @model
    crumbs << params[:action].titleize unless %w( index ).include?(params[:action])
    return crumbs.compact.map { |x| x }.join(" &rsaquo; ")
  end

  def header
    "<h1>#{Typus::Configuration.options[:app_name]} <small>#{link_to "View site", '/', :target => 'blank'}</small></h1>"
  end

  def login_info
    html = <<-HTML
      <ul>
        <li>Logged as #{link_to @current_user.full_name(true), :controller => 'admin/typus_users', :action => 'edit', :id => @current_user.id}</li>
        <li>#{link_to "Logout", typus_logout_url}</li>
      </ul>
    HTML
    return html
  end

  def display_flash_message
    flash_types = [ :error, :warning, :notice ]
    flash_type = flash_types.detect{ |a| flash.keys.include?(a) } || flash.keys.first
    if flash_type
      "<div id=\"flash\" class=\"%s\"><p>%s</p></div>" % [flash_type.to_s, flash[flash_type]]
    end
  end

  def display_error(error)
    log_error error
    "<div id=\"flash\" class=\"error\"><p>#{error}</p></div>"
  end

  ##
  #
  #
  def log_error(exception)
    ActiveSupport::Deprecation.silence do
        logger.fatal(
        "Typus Error:\n\n#{exception.class} (#{exception.message}):\n    " +
        exception.backtrace.join("\n    ") +
        "\n\n"
        )
    end
  end

end