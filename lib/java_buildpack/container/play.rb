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

require 'java_buildpack/base_component'
require 'java_buildpack/container'
require 'java_buildpack/container/container_utils'
require 'java_buildpack/repository/configured_item'
require 'java_buildpack/util/application_cache'
require 'java_buildpack/util/play_app'
require 'pathname'

module JavaBuildpack::Container

  # Encapsulates the detect, compile, and release functionality for Play applications.
  class Play < JavaBuildpack::BaseComponent

    def initialize(context)
      super('Play Framework', context)

      @play_app = JavaBuildpack::Util::PlayApp.new(@app_dir)
    end

    def detect
      version = @play_app.version
      version ? id(version) : nil
    end

    def compile
      @play_app.set_executable
      @play_app.add_libs_to_classpath additional_libraries
      @play_app.replace_bootstrap BOOTSTRAP_CLASS_NAME
    end

    def release
      @java_opts << "-D#{KEY_HTTP_PORT}=$PORT"

      path_string = "PATH=#{File.join @java_home, 'bin'}:$PATH"
      java_home_string = ContainerUtils.space("JAVA_HOME=#{@java_home}")
      start_script_string = ContainerUtils.space(@play_app.start_script_relative)
      java_opts_string = ContainerUtils.space(ContainerUtils.to_java_opts_s(@java_opts))

      "#{path_string}#{java_home_string}#{start_script_string}#{java_opts_string}"
    end

    protected

    # The unique identifier of the component, incorporating the version of the dependency (e.g. +play-2.2.0+)
    #
    # @param [String] version the version of the dependency
    # @return [String] the unique identifier of the component
    def id(version)
      "play-#{version}"
    end

    private

    BOOTSTRAP_CLASS_NAME = 'org.cloudfoundry.reconfiguration.play.Bootstrap'.freeze

    KEY_HTTP_PORT = 'http.port'.freeze

  end

end
