require "rails/generators/test_case"

class EmbeddedEngineGeneratorTest < Rails::Generators::TestCase
  destination File.expand_path("../tmp", __dir__)

  tests Rails::Generators::PluginGenerator

  setup do
    prepare_destination
    ::APP_PATH = File.expand_path("../tmp", __dir__)
  end

  teardown do
    remove_destination
    Object.send(:remove_const, :APP_PATH)
  end

  arguments ["my_engine", "--embedded"]

  test "generates a new engine" do
    assert_no_directory("my_engine")

    make_application

    capture(:stderr) do
      run_generator
    end

    assert_directory("my_engine")

    assert_file("my_engine/lib/my_engine/engine.rb") do |engine|
      assert_match(/class Engine < ::Rails::Engine/, engine)
    end
    assert_no_file("my_engine/Gemfile")
    assert_no_file("my_engine/MIT-LICENSE")
    assert_file("my_engine/my_engine.gemspec") do |gemspec|
      assert_no_match("MIT", gemspec)
      assert_match("spec.metadata[\"allowed_push_host\"] = \"false\"", gemspec)
      assert_no_match("source_code_uri", gemspec)
      assert_no_match("changelog_uri", gemspec)
    end
    assert_file("my_engine/.gitignore")
    assert_file("my_engine/README.md")

    assert_test_folder("my_engine/test")
  end

  test "generates a new engine inside a folder" do
    assert_no_directory("engines/my_engine")

    make_application

    capture(:stderr) do
      run_generator ["engines/my_engine", "--embedded"]
    end

    assert_directory("engines/my_engine")

    assert_file("engines/my_engine/lib/my_engine/engine.rb") do |engine|
      assert_match(/class Engine < ::Rails::Engine/, engine)
    end
    assert_no_file("engines/my_engine/Gemfile")
    assert_no_file("engines/my_engine/MIT-LICENSE")
    assert_file("engines/my_engine/my_engine.gemspec") do |gemspec|
      assert_no_match("MIT", gemspec)
      assert_match("spec.metadata[\"allowed_push_host\"] = \"false\"", gemspec)
      assert_no_match("source_code_uri", gemspec)
      assert_no_match("changelog_uri", gemspec)
    end
    assert_file("engines/my_engine/.gitignore")
    assert_file("engines/my_engine/README.md")

    assert_test_folder("engines/my_engine/test")
  end

  test "creates a context file" do
    make_application

    capture(:stderr) do
      run_generator
    end

    assert_file("config/application.rb") do |file|
      assert_includes(file, "Rails.load_embedded_engines(context: ENV[\"RAILS_CONTEXT\"] || :all)")
    end

    assert_file("config/contexts.yml") do |file|
      assert_match("all:", file)
      assert_match("- my_engine", file)
    end
  end

  test "creates a context file inside a folder" do
    make_application

    capture(:stderr) do
      run_generator ["engines/my_engine", "--embedded"]
    end

    assert_file("config/application.rb") do |file|
      assert_includes(file, "Rails.load_embedded_engines(context: ENV[\"RAILS_CONTEXT\"] || :all)")
    end

    assert_file("config/contexts.yml") do |file|
      assert_match("all:\n", file)
      assert_match("- my_engine", file)
    end
  end

  test "appends to context when embedded engines exist" do
    make_application do |file|
      file << "Rails.load_embedded_engines(context: :all)"
    end
    make_context_config

    capture(:stderr) do
      run_generator
    end

    assert_file("config/application.rb") do |file|
      assert_includes(file, "Rails.load_embedded_engines(context: :all)")
    end

    assert_file("config/contexts.yml") do |file|
      assert_match("all:\n", file)
      assert_match("- my_engine\n", file)
    end
  end

  test "appends to context when embedded engines exist when plugin is generated inside a folder" do
    make_application do |file|
      file << "Rails.load_embedded_engines(context: :all)"
    end
    make_context_config

    capture(:stderr) do
      run_generator  ["engines/my_engine", "--embedded"]
    end

    assert_file("config/application.rb") do |file|
      assert_includes(file, "Rails.load_embedded_engines(context: :all)")
    end

    assert_file("config/contexts.yml") do |file|
      assert_match("- my_engine", file)
    end
  end

  test "embedded engines gem is require: false" do
    make_application
    make_gemfile

    capture(:stderr) do
      run_generator
    end

    assert_file("Gemfile") do |file|
      assert_match("\ngem 'my_engine', path: 'my_engine', require: false", file)
    end
  end

  private
    DEFAULT_APPLICATION = <<~RUBY
    module SomeTest
      class Application < Rails::Application
      end
    end

    RUBY

    def make_application(content = DEFAULT_APPLICATION.dup)
      yield(content) if block_given?

      mkdir_p(File.join(destination_root, "config"))
      File.write(File.join(destination_root, "config", "application.rb"), content)
    end

    def make_gemfile
      File.write(File.join(destination_root, "Gemfile"), "source 'https://rubygems.org'")
    end

    def make_context_config
      content = <<~YAML
      all:
        - a
      YAML

      yield(content) if block_given?

      mkdir_p(File.join(destination_root, "config"))
      File.write(File.join(destination_root, "config", "contexts.yml"), content)
    end

    def remove_destination
      rm_rf destination_root unless ENV["DEBUG"]
    end

    def assert_test_folder(folder)
      assert_no_file("#{folder}/test_helper.rb")
      assert_no_directory("#{folder}/fixtures/files")

      assert_file("#{folder}/my_engine_test.rb")
      assert_directory("#{folder}/controllers")
      assert_directory("#{folder}/mailers")
      assert_directory("#{folder}/models")
      assert_directory("#{folder}/integration")
      assert_directory("#{folder}/helpers")

      assert_file("#{folder}/integration/navigation_test.rb")
    end
end
