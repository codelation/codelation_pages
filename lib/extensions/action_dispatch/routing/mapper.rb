module ActionDispatch::Routing
  # Hacking on ActionDispatch::Routing::Mapper provides additional methods for defining
  # routes. These include being able to organize routes into multiple files and
  # a whole lot of magic for generating routes and controllers for static pages.
  class Mapper
    # Method for organizing the routes file into multiple files
    # @see http://blog.arkency.com/2015/02/how-to-split-routes-dot-rb-into-smaller-parts/
    def draw(routes_name)
      instance_eval(File.read(Rails.root.join("config/routes/#{routes_name}.rb")))
    end

    # Method for drawing the routes for static pages automatically.
    # Any .html.erb file in `app/views/pages` will be served as the dasherized file name.
    # @example
    #   about_us.html.erb will be served at http:/example/about-us
    #   and the link helper will be available as `about_us_path`
    def draw_static_pages
      draw_routes
      generate_controller
      draw_sub_pages
    end

  private

    # Returns a controller for serving statis files. The view path is
    # set so the view files can all be in the `pages` directory.
    def controller(directory_name = "")
      Class.new(ApplicationController) do
        # Defines where the controller will look for the view files.
        def self.controller_path
          controller_path = name.gsub("Controller", "").underscore
          controller_path == "pages" ? "pages" : File.join("pages", controller_path)
        end
      end
    end

    # Draws the routes for static pages within sub folders.
    # Any .html.erb file in a folder within `app/views/pages` will be served as
    # the dasherized folder name and file name.
    # @example
    #   about_us/team.html.erb will be served at http:/example/about-us/team
    #   and the link helper will be available as `about_us_team_path`
    def draw_sub_pages
      files = Dir["#{Rails.root.join('app', 'views', 'pages')}/*"]
      directories = files.select {|file| File.directory? file }
      directories.each do |directory|
        directory_name = File.basename(directory)
        draw_routes(directory_name)
        generate_controller(directory_name)
      end
    end

    # Draw the route using the directory and file name.
    # @param directory_name [String]
    def draw_routes(directory_name = "")
      page_files = Dir["#{Rails.root.join('app', 'views', 'pages', directory_name)}/*.html.erb"]
      page_files.each do |file_name|
        page = File.basename(file_name, ".html.erb")
        controller_name = directory_name.blank? ? "pages" : directory_name.underscore
        path_name = directory_name.blank? ? page : "#{directory_name.underscore}_#{page}"
        get "#{directory_name}/#{page}".dasherize, to: "#{controller_name}##{page}", as: path_name
      end
    end

    # Generate a controller using the directory and file name if it doesn't exist.
    # @param directory_name [String]
    def generate_controller(directory_name = "pages")
      controller_class_name = "#{directory_name.camelize}Controller"
      controller_exists = Object.const_defined?(controller_class_name)
      Object.const_set(controller_class_name, controller(directory_name)) unless controller_exists
    end
  end
end
