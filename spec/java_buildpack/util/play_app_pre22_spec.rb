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

require 'spec_helper'
require 'java_buildpack/container/container_utils'
require 'java_buildpack/util/play_app_pre22'

module JavaBuildpack::Util

  describe PlayAppPre22 do

    let(:play_app_pre22) { StubPlayAppPre22.new 'test-dir' }

    it 'should fail if methods are unimplemented' do
      JavaBuildpack::Container::ContainerUtils.stub(:relative_paths).and_return(['./test-jar'])
      JavaBuildpack::Container::ContainerUtils.should_receive(:relative_paths).with('test-dir', ['test.jar'])
      app = play_app_pre22
      app.stub(:shell)
      app.should_receive(:shell).with('ln -nsf .././test-jar test-dir/lib')
      app.test_link_libs_from_classpath_dir ['test.jar']
    end

  end

  class StubPlayAppPre22 < PlayAppPre22

    def initialize(app_dir)
      super(app_dir)
      @play_root = app_dir
    end

    def test_link_libs_from_classpath_dir(libs)
      link_libs_from_classpath_dir(libs)
    end
  end

end
