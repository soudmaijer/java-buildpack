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

require 'spec_helper'
require 'java_buildpack/util/play_app_factory'

module JavaBuildpack::Util

  describe PlayAppFactory do

    it 'should successfully create a Play 2.0 application' do
      PlayAppFactory.create 'spec/fixtures/container_play_2.0_dist'
    end

    it 'should successfully create a Play 2.1 application' do
      PlayAppFactory.create 'spec/fixtures/container_play_2.1_dist'
    end

    it 'should successfully create a Play 2.2 application' do
      PlayAppFactory.create 'spec/fixtures/container_play_2.2'
    end

    it 'should fail to create an application which is a hybrid of Play 2.1 and 2.2' do
      Dir.mktmpdir do |root|
        FileUtils.cp_r 'spec/fixtures/container_play_2.1_dist/.', root
        FileUtils.cp_r 'spec/fixtures/container_play_2.2/.', root

        expect { PlayAppFactory.create root }.to raise_error(/Play application in .* is recognized by more than one Play application class/)
      end
    end

  end

end
