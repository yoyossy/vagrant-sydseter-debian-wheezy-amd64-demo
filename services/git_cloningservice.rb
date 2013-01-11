# git_cloningservice.rb
# define class CloningService
# == Module Git
# Module for Git ruby code
# == Class CloningService
# Clone all git repos you need 
# === src
# Where you keep your git repositories locally
# === repositories
# An array of the git repository names that you need access to
# === github
# The git location of your repositories
# Author: Johan Sydseter (mailto:johan.sydseter@startsiden.no)

require 'yaml'

module Git

  class CloningService
    attr_reader :src, :repositories, :github

    # Constructor
    def initialize(dir, prefix)
      config_file = "#{dir}/#{prefix}.local.yml"

      if !File.exists? config_file
        $stderr.puts "#{config_file} did not exist.
This file is where you configure vagrant to clone github \
repositories that you want to set up as shared folders.
The git cloning service created it by:

cp #{dir}/#{prefix}.yml #{config_file}

Please edit this file and specify a source folder and github url \
for your git repositories.\n"
          %x(cp #{dir}/#{prefix}.yml #{config_file});
      end

      if !File.readable? config_file
        $stderr.puts "#{config_file} is not readable.
Make sure your user has access to it:

chmod 775 #{config_file}\n"
          exit
      end

      vagrant_yaml = YAML.load_file(config_file) or
        raise "Could not parse yaml from #{config_file}"

      src = vagrant_yaml['vagrant']['src']

      if !File.directory? src
        $stderr.puts "#{src} is not a directory or does not exist.
This directory is where all the repositories will be \
cloned out from github. Makes sure this directory exist by creating it with:

mkdir -p #{src}.

You may want to edit the file: 

#{config_file}

If so, specify another directory.\n"
          exit
      end

      repositories = vagrant_yaml['vagrant']['repositories']
      
      if !repositories.kind_of?(Array)
        $stderr.puts 'Invalid yaml. Please make sure the repositories ' +     
          'configuration option is formated as an array in ' +
          "the following file:\n#{config_file}"
        exit
      end

      @src = src
      @repositories = repositories 
      @github = vagrant_yaml['vagrant']['github'].sub(/(\/)+$/,'')
    end

    # check that all git repos are cloned out
    def clone

      git_check
 
      self.repositories.each do |repository| 
        repo_path = "#{self.src}/#{repository}"
        git_url = "#{self.github}/#{repository}"

        if !File.directory? repo_path
          puts "clone #{git_url}"
          %x(git clone --recursive #{git_url} #{repo_path}) or 
            raise "Could not git clone #{repo_url} #{repo_path}"
        end
      end
    end

    ## Private methods
    private

    # Check that git is installed
    def git_check 
      %x(git --version) =~ (/^git version/) or 
        raise 'Could not exec git. Is git installed?'
    end
  end
end
