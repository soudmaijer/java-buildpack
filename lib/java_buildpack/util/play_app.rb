# Encoding: utf-8
# Cloud Foundry Java Buildpack
# Copyright (c) 2013 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'java_buildpack/util'
require 'java_buildpack/util/play_utils'
require 'java_buildpack/util/shell'

module JavaBuildpack::Util

  # Encapsulate inspection and modification of Play applications.
  class PlayApp
    include JavaBuildpack::Util::Shell

    # Returns the version of this Play application
    #
    # @return [String, nil] the version of the Play application
    attr_reader :version

    # Creates a Play application based on the given application directory.
    #
    # @param [String] app_dir the application directory
    def initialize(app_dir)
      @app_dir = app_dir
      @play_root = PlayUtils.root(app_dir)
      @version = @play_root ? PlayUtils.version(@play_root) : nil
    end

    # Ensures this Play application is executable.
    def set_executable
      shell "chmod +x #{PlayUtils.start_script @play_root}"
    end

    # Replaces the bootstrap class of this Play application.
    #
    # @param [String] bootstrap_class the replacement bootstrap class name
    def replace_bootstrap(bootstrap_class)
      update_file JavaBuildpack::Util::PlayUtils.start_script(@play_root), /play\.core\.server\.NettyServer/, bootstrap_class
    end

    # Adds the given JARs to this Play application's classpath.
    #
    # @param [Array<String>] libs the JAR paths
    def add_libs_to_classpath(libs)
      if JavaBuildpack::Util::PlayUtils.lib_play_jar @play_root
        add_libs_to_dist_classpath(libs)
      else
        add_libs_to_staged_classpath(libs)
      end
    end

    # Returns the path of the Play start script relative to the application directory.
    #
    # @return [String] the path of the Play start script relative to the application directory
    def start_script_relative
      "./#{Pathname.new(JavaBuildpack::Util::PlayUtils.start_script(@play_root)).relative_path_from(Pathname.new(@app_dir)).to_s}"
    end

    private

    def add_libs_to_staged_classpath(libs)
      # Staged applications add all the JARs in the staged directory to the classpath, so add symbolic links to the staged directory.
      # Note: for staged applications, @app_dir = @play_root
      link_libs_to_classpath_directory(JavaBuildpack::Util::PlayUtils.staged(@play_root), libs)
    end

    def link_libs_to_classpath_directory(classpath_directory, libs)
      JavaBuildpack::Container::ContainerUtils.relative_paths(@play_root, libs).each do |lib|
        shell "ln -nsf ../#{lib} #{classpath_directory}"
      end
    end

    def add_libs_to_dist_classpath(libs)
      # Dist applications either list JARs in a classpath variable (e.g. in Play 2.1.3) or on a -cp parameter (e.g. in Play 2.0),
      # so add to the appropriate list.
      # Note: for dist applications, @play_root is an immediate subdirectory of @app_dir, so @app_dir is equivalent to @play_root/..
      script_dir_relative_path = Pathname.new(@app_dir).relative_path_from(Pathname.new(@play_root)).to_s

      additional_classpath = JavaBuildpack::Container::ContainerUtils.relative_paths(@app_dir, libs).map do |lib|
        "$scriptdir/#{script_dir_relative_path}/#{lib}"
      end

      result = update_file JavaBuildpack::Util::PlayUtils.start_script(@play_root), /^classpath=\"(.*)\"$/, "classpath=\"#{additional_classpath.join(':')}:\\1\""
      unless result
        link_libs_to_classpath_directory(JavaBuildpack::Util::PlayUtils.lib(@play_root), libs)
      end
    end

    def update_file(file_name, pattern, replacement)
      content = File.open(file_name, 'r') { |file| file.read }
      result = content.gsub! pattern, replacement

      File.open(file_name, 'w') do |file|
        file.write content
        file.fsync
      end

      result
    end

  end

end
