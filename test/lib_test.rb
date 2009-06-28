require File.dirname(__FILE__) + '/lib_test_helper'

TMP_DIR = File.expand_path(File.dirname(__FILE__) + '/../../tmp/libs')

class BuildTest
  include LibTestHelper

  def test_library_build(*names)
    options = names.last.is_a?(Hash) ? names.pop : {}
    verbose = options[:verbose]
    names = libs.keys if names.empty?
    names.delete(:rubinius)

    puts "Going to parse and rebuild Ruby files from the following #{names.size} libraries:\n\n#{names.join(', ')}\n\n"
    puts "Will report an o if the rebuilt code is not exactly the same as the original source."
    puts "Will report an x if the code can not be parsed by Ripper (most probably Ruby 1.9 incompatible)."
    puts "Let's go ...\n"
    errors = {}
    
    names.each do |name|
      # next if name < 'crap4r'
      puts "\n#{name}"

      lib = libs[name]
      lib[:exclude] ||= []
      lib[:exclude] << "/vendor/"         # don't parse various plugins or frozen rails twice
                    << "/simple_benches"  # looks like some pseudo code in merb
      
      errors[name] = []
      filenames(File.expand_path(lib[:path])).each do |filename|
        next if excluded?(lib, filename)
        src = read_src(filename, lib)
        p filename if verbose
        begin
          result = build(src, filename).to_ruby(true)
          if src == result
            putc '.'
          else
            errors[name] << filename + "\nresult differs from source:\n#{diff(src, result)}\n"
            verbose ? puts(diff(src, result)) : putc('o')
          end
        rescue Exception => e
          line = e.message
          line = filename + ': ' + line unless line.index(filename)
          errors[name] << line + "\n"
          putc e.is_a?(Ripper::RubyBuilder::ParseError) ? 'x' : 'e'
        end
      end
      
      # report(errors, name)
    end
    
    puts
    names.each { |name| report(errors, name, libs[name][:path]) }
  end

  def test_tmp_file
    filename = File.dirname(__FILE__) + '/fixtures/tmp.rb'
    src = read_src(filename)
    result = build(src, filename).to_ruby(true) || ''
    puts diff(src, result)
  end

  def test_this
    src = 'a+ a +a'
    result = build(src).to_ruby(true) || ''
    puts diff(src, result)
  end
  
  def libs
    @libs ||= begin
      Dir["#{TMP_DIR}/*"].inject({}) do |dirs, dir| 
        dirs[File.basename(dir).to_sym] = { :path => dir }
        dirs
      end
    end
  end
  
  def clone_libs
    urls = File.read(File.dirname(__FILE__) + '/libs.txt').split("\n")
    urls.each do |url| 
      # next if File.dir?(tmp_dir)
      puts `cd #{TMP_DIR}; git clone #{url}`
    end
  end
end

# LIBS = {
#   :self => {
#     :path => File.dirname(__FILE__) + '/../',
#     :exclude => []
#   },
#   :rails => {
#     :path => '~/Development/shared/rails/rails',
#     :erb => %r(/templates/|environment\.rb),
#     :exclude => []
#   },
#   :ruby => {
#     :path => '/usr/local/ruby19/lib/ruby/1.9.1'
#   },
#   :parse_tree => {
#     :path => '/usr/local/lib/ruby/gems/1.8/gems/ParseTree-3.0.2'
#   },
#   :capistrano => {
#     :path => '/usr/local/lib/ruby/gems/1.8/gems/capistrano-2.5.3'
#   },
#   :cucumber => {
#     :path => '/usr/local/lib/ruby/gems/1.8/gems/cucumber-0.3.11',
#     :erb => %r(/templates/|environment\.rb)
#   },
#   :rack => {
#     :path => '/usr/local/lib/ruby/gems/1.8/gems/rack-0.9.1'
#   },
#   :adva_cms => {
#     :path => '~/Development/projects/adva_cms/adva_cms/vendor/adva',
#     :erb => %r(/templates/|environment\.rb),
#     :exclude => []
#   }
# }

# BuildTest.new.clone_libs
BuildTest.new.test_library_build #(:active_shipping, :zentest)
# BuildTest.new.test_tmp_file