module Ti
  class CLI < Thor
    include Utils

    STATUS_TYPES = {:success          => 0,
                    :general_error    => 1,
                    :not_supported    => 3,
                    :not_found        => 4,
                    :incorrect_usage  => 64,
                    }

    no_tasks {
    def cli_error(message, exit_status=nil)
      $stderr.puts message
      exit_status = STATUS_TYPES[exit_status] if exit_status.is_a?(Symbol)
      exit(exit_status || 1)
    end
    }

    ### TODO: When these commands list grows big, we need to move them into a seperate commands.rb file
    map %w(--version -v) => 'info'
    desc "info", "information about Ti."
    def info
      say "Version #{::Ti::VERSION}"
    end
    
    map %(n) => 'new'
    desc "new <name> <id> <platform>", "generates a new Titanium project."
    long_desc "Generates a new Titanium project. See 'ti help new' for more information.
              \n\nExamples:
              \n\nti new demo ==> Creates a new project with a default id (org.mycompany.demo) and sets the project platform to iphone.
              \n\nti new demo com.youwantit.dontyou ==> Creates a new project 'demo' with the id of 'com.youwantit.dontyou' to be used on the iphone.
              \n\nti new demo com.youwantit.dontyou ipad ==. Creates a new project 'demo' with the id 'com.youwantit.dontyou' for the ipad."
    def new(name, device_id='org.mycompany.demo', platform='iphone')
      ::Ti::Generate::Project.create(name, device_id, platform)
    end
    
    map %w(g) => 'generate'
    desc "generate <model/controller/view> <name>", "generate a new model or view with jasmine specs."
    def generate(type, name)
      case 
      when type =~ /model/i
        ::Ti::Generate::Model.create(name)
      when type =~ /view/i
        ::Ti::Generate::View.create(name)
      when type =~ /controller/i
        ::Ti::Generate::Controller.create(name)
      end
    end



    map %w(s) => 'scaffold'
    desc "scaffold <window/tabgroup/view> <domain> <name>", "generate a scaffold for Titanium elements."
    def scaffold(ti_type, domain, name)
      ::Ti::Generate::View.create(name, { 
        :domain   => domain, 
        :ti_type  => ti_type, 
        :app_name => get_app_name, 
        :name     => name })
    end

    map %w(c) => 'controller'
    desc "controller <name>", "generate a controller for Titanium"
    def controller(name)
      ::Ti::Generate::Controller.create(name, {
          :app_name => get_app_name, 
          :name     => name })
    end
    
    desc "compile <all/coffee/sass>", "compiles all CoffeeScripts"
    def compile(type)
      case
      when type =~ /all/i
        ::Ti::Compiler::CoffeeScripts.compile_all!
        ::Ti::Compiler::SASSScripts.compile
      when type =~ /coffee/i
        ::Ti::Compiler::CoffeeScripts.compile_all!
      when type =~ /sass/i
        ::Ti::Compiler::SASSScripts.compile
      end
    end

    map %w(b) => 'build'
    desc "build <all/iphone/android/ipad/desktop/>", "Build the project using Titanium"
    def build(platform)
      ::Ti::Builder::Titanium.build platform
    end

  end
end
