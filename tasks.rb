#
# arduino-tasks
#
# Copyright (c) 2014 Dave Sieh
# See LICENSE.txt for details.
#

#
# Methods to assist in the production of git commands for
# processing the libraries.
#
module GitHelpers

  def clone_library(library)
    "git clone #{library.git_repository_uri} #{library.name}"
  end

  def fetch_branch(library)
    "git fetch origin #{library.git_branch}:#{library.git_branch}"
  end

  def checkout_branch(library)
    "git checkout #{library.git_branch}"
  end

end

#
# Methods to generate the necessary tasks to get the dependency libraries
# put where INO can get at them.
#
module ArduinoTasks
  include GitHelpers # Bring in the helpers

  #
  # Factory method to make it easier to create library definitions
  # Params are the same as the initializer for ArduinoLibrary
  #
  def library(name, repository_name=nil, git_branch=nil)
    ArduinoLibrary.new name, repository_name, git_branch
  end

  #
  # This is the main entry point for your Rake file. All you need to
  # do is put together a list of the libraries you need for your
  # project and pass them here and this method will generate all the
  # required Rake tasks to put your libraries where you need them
  #
  # Params: 
  #   env - An ArduinoEnvironment instance. Tells us where to put things
  #   libraries - An array of ArduinoLibrary instances. Describes the libraries we need
  #   dependent_task - The name of the task for which all the libraries are dependencies
  #
  def create_all_library_tasks(env, libraries, dependent_task)
    libraries.each do | library |
      create_library_tasks(env, library, dependent_task)
    end
  end

  def create_library_tasks(env, library, dependent_task)

    # Create the directory task for the source of the library
    directory env.source_library_dir(library.name) do
      system "cd ..; #{clone_library(library)}"
      if library.branch?
        system("cd #{env.source_library_dir(library.name)}; #{fetch_branch(library)}; #{checkout_branch(library)}") 
      end
    end

    directory env.dependent_library_dir(library.name) => env.source_library_dir(library.name) do
      cp_r env.source_library_dir(library.name), env.lib_dir
    end

    task dependent_task => env.dependent_library_dir(library.name)

  end

end

#
# This class provides a means of describing the Arduino directory
# environment to the task builder.
#
class ArduinoEnvironment
  attr_reader :base_dir

  LIB_DIR = "lib"

  #
  # base_dir defines where the source libraries should be cloned. Relative to
  # the Rakefile location.
  #
  def initialize(base_dir)
    @base_dir = base_dir
  end
  
  #
  # Returns the path to a cloned library
  #
  def source_library_dir(lib)
    File.join base_dir, lib
  end

  #
  # Returns the path to the library within the ino project.
  #
  def dependent_library_dir(lib)
    File.join LIB_DIR, lib
  end

  # 
  # Returns the directory in which ino project libraries are placed.
  #
  def lib_dir
    LIB_DIR
  end

end

#
# This class allows you to specify the particulars of a library to be
# used for your ino project.
#
class ArduinoLibrary
  attr_accessor :name, :repository_name, :git_branch
  
  #
  # Params:
  #   name - the name of the library as it will appear in an #include <...> statement.
  #   repository_name - the name of the git repository from which to clone the library. If
  #                     not specified, the repository_name is assumed to be 'name'.
  #   git_branch - the git branch to be checked out. If not specified, assumes 'master'
  #
  def initialize(name, repository_name=nil, git_branch=nil)
    @name = name
    @repository_name = repository_name
    @git_branch = git_branch
  end

  def git_repository_uri
    "git@github.com:FellowRoboticists/#{git_repository_name}.git"
  end

  def git_repository_name
    repository_name.nil? ? name : repository_name
  end

  def branch?
    ! git_branch.nil?
  end

end
