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
require 'java_buildpack/framework'
require 'shellwords'

module JavaBuildpack::Framework

  # Encapsulates the functionality for contributing custom Java options to an application.
  class JavaOpts < JavaBuildpack::BaseComponent

    def initialize(context)
      super('JAVA_OPTS', context)
    end

    def detect
      @configuration.key?(CONFIGURATION_PROPERTY) ? @parsable_component_name : nil
    end

    def compile
      parsed_java_opts.each do |option|
        fail "Java option '#{option}' configures a memory region.  Use JRE configuration for this instead." if memory_option? option
      end
    end

    def release
      @java_opts.concat parsed_java_opts
    end

    private

    CONFIGURATION_PROPERTY = 'java_opts'.freeze

    def memory_option?(option)
      option =~ /-Xms/ || option =~ /-Xmx/ || option =~ /-XX:MaxMetaspaceSize/ || option =~ /-XX:MaxPermSize/ ||
          option =~ /-Xss/
    end

    def parsed_java_opts
      @configuration[CONFIGURATION_PROPERTY].shellsplit.map do |java_opt|
        java_opt.gsub(/([\s])/, '\\\\\1')
      end
    end

  end

end
