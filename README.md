# Codelation Pages

A extension of Rails routes mapper for automatically registering static pages.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "codelation_pages"
```

Install the Codelation Pages gem with Bundler:

```bash
bundle install
```

## Usage

**Example:** Creating an "About Us" page.

### Views

All static pages are served by the `PagesController`, so the HTML/ERB files live in
`app/views/pages`. The `PagesController` is a generated controller,
so you won't find it as a file in the code. If you define the controller,
it will be used instead of the generated controller.

If I want my about page to live at `http://example.com/about-us`,
I would create the view file: `app/views/pages/about_us.html.erb`.
The link helper will be available as `about_us_path`.

Files with the name `index.html.erb` will be served at the root path.
Example: `app/views/features/index.html.erb` will live at `http://example.com/features`.
The link helper will be available as `features_path`.

#### Subfolders

You can also create pages within subfolders, so if wanted to create a
"Features > Overview" page that lives at `http://example.com/features/overview`,
I would create the view file: `app/views/pages/features/overview.html.erb`.
The link helper will be available as `features_overview_path`.

Files within subfolders will not be served by the `PagesController`. They will
be served by a generated controller matching the name of the folder. In the case of our
"Features > Overview" page, the controller would be the `Pages::FeaturesController`.

### Routes

Add `draw_static_pages` to `config/routes.rb`:

```ruby
RailsProject::Application.routes.draw do
  draw_static_pages
end
```

## IMPORTANT

**You will need to restart your Rails server after adding new page files.***

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
