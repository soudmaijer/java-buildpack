# Encoding: utf-8
# Cloud Foundry Java Buildpack
# Copyright 2013 the original author or authors.
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

require 'pathname'
require 'java_buildpack/util'

module JavaBuildpack::Util

  # Utilities for dealing with Groovy applications
  class GroovyUtils

    # Indicates whether a file has a +main()+ method in it
    #
    # @param [File] file the file to scan
    # @return [Boolean] +true+ if the file contains a +main()+ method, +false+ otherwise.
    def self.main_method?(file)
      file.read =~ /static void main\(/
    end

    # Indicates whether a file is a POGO
    #
    # @param [File] file the file to scan
    # @return [Boolean] +true+ if the file is a POGO, +false+ otherwise.
    def self.pogo?(file)
      file.read =~ /class [\w]+ [\s\w]*{/
    end

    # Indicates whether a file has a shebang
    #
    # @param [File] file the file to scan
    # @return [Boolean] +true+ if the file has a shebang, +false+ otherwise.
    def self.shebang?(file)
      file.read =~ /#!/
    end

    # Returns all the Ruby files in the given directory
    #
    # @param [String] root a directory to search
    # @return [Array] a possibly empty list of files
    def self.groovy_files(root)
      root_directory = Pathname.new(root)
      Dir[File.join root, GROOVY_FILE_PATTERN].reject { |file| File.directory? file }
      .map { |file| Pathname.new(file).relative_path_from(root_directory).to_s }.sort
    end

    private_class_method :new

    private

    GROOVY_FILE_PATTERN = '**/*.groovy'.freeze

  end

end
