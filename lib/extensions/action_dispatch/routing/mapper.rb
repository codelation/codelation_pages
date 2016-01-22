module ActionDispatch
  module Routing
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

      # Returns an application controller for serving static files.
      def controller
        Class.new(ApplicationController) do
        end
      end

      # Returns whether or not a custom controller file exists.
      # @param directory_name [String]
      def custom_controller_exists(directory_name)
        return true if File.exist?(Rails.root.join("app", "controllers", "pages", "#{directory_name}_controller.rb"))
        Object.const_defined?("Pages::#{directory_name.camelize}Controller")
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
          controller_name = directory_name.blank? ? "pages" : "pages/#{directory_name}"

          if page == "index"
            path = directory_name.dasherize
            path_name = directory_name
          else
            path_name = directory_name.blank? ? page : "#{directory_name}_#{page}"
            path = "#{directory_name}/#{page}".dasherize
          end

          get path, to: "#{controller_name}##{page}", as: path_name.blank? ? "root" : path_name
        end
      end

      # Generate a controller using the directory and file name if it doesn't exist.
      # @param directory_name [String]
      def generate_controller(directory_name = "pages")
        if directory_name == "pages"
          generate_pages_controller
        else
          generate_custom_controller(directory_name)
        end
      end

      # Generates a controller based off the directory name if it
      # doesn't exist in the `Pages` module.
      # @param directory_name [String]
      def generate_custom_controller(directory_name)
        Object.const_set("Pages", Module.new) unless pages_module_exists
        controller_class_name = "#{directory_name.camelize}Controller"
        Pages.const_set(controller_class_name, controller) unless custom_controller_exists(directory_name)
      end

      # Generates the `PagesController` if it doesn't already exist
      def generate_pages_controller
        Object.const_set("PagesController", controller) unless pages_controller_exists
      end

      # Returns whether or not the PagesController file exists.
      def pages_controller_exists
        return true if File.exist?(Rails.root.join("app", "controllers", "pages_controller.rb"))
        Object.const_defined?("PagesControllers")
      end

      # Returns whether or not the pages module directory exists
      def pages_module_exists
        return true if File.exist?(Rails.root.join("app", "controllers", "pages"))
        Object.const_defined?("Pages")
      end
    end
  end
end
