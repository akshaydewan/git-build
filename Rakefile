require 'rubygems'
require 'bundler/setup'

require 'rake/clean'

distro = nil
fpm_opts = ""

if File.exist?('/etc/system-release') && File.read('/etc/redhat-release') =~ /centos|redhat|fedora|amazon/i
  distro = 'rpm'
  fpm_opts << " --rpm-user root --rpm-group root "
elsif File.exist?('/etc/os-release') && File.read('/etc/os-release') =~ /ubuntu|debian/i
  distro = 'deb'
  fpm_opts << " --deb-user root --deb-group root "
end

unless distro
  $stderr.puts "Don't know what distro I'm running on -- not sure if I can build!"
end

version = "1.9.1"
release = ENV['GO_PIPELINE_COUNTER'] || ENV['RELEASE'] || 1
name = "git-#{version}"

description_string = %Q{Git is a fast, scalable, distributed revision control system with an unusually rich command set that provides both high-level operations and full access to internals.}

jailed_root = File.expand_path('../jailed-root', __FILE__)

CLEAN.include("downloads")
CLEAN.include("jailed-root")
CLEAN.include("log")
CLEAN.include("pkg")

task :init do
  mkdir_p "log"
  mkdir_p "pkg"
  mkdir_p "downloads"
  mkdir_p "jailed-root"
end

task :download do
  cd 'downloads' do
    sh("git clone --quiet https://github.com/git/git git-#{version}")
    cd ("git-#{version}") do
      sh("git checkout v#{version}")
    end
  end
end

task :configure do
  cd "downloads" do
    cd "git-#{version}" do
      sh('make configure')
      sh "./configure --prefix=/opt/local/git/#{version} > #{File.dirname(__FILE__)}/log/configure.#{version}.log 2>&1"
    end
  end
end

task :make do
  num_processors = %x[nproc].chomp.to_i
  num_jobs       = num_processors + 1

  cd "downloads/git-#{version}" do
    sh("make -j#{num_jobs} > #{File.dirname(__FILE__)}/log/make.#{version}.log 2>&1")
  end
end

task :make_install do
  rm_rf  jailed_root
  mkdir_p jailed_root
  cd "downloads/git-#{version}" do
    sh("make install DESTDIR=#{jailed_root} > #{File.dirname(__FILE__)}/log/make-install.#{version}.log 2>&1")
  end
end


task :dist do
  require 'erb'
  class RpmSpec
    attr_accessor :version, :release
    def initialize(version, release)
      @version      = version
      @release      = release
    end

    def get_binding
      binding
    end
  end

  ERB.new(File.read(File.expand_path('../git.spec.erb', __FILE__)), nil , '-').tap do |template|
    File.open("/tmp/git.spec", 'w') do |f|
      attrs = RpmSpec.new(version, release)
      f.puts(template.result(attrs.get_binding))
    end
    at_exit {rm_rf "/tmp/git.spec"}
  end

  mkdir_p "#{jailed_root}/usr/local/bin"

  cd "#{jailed_root}/usr/local/bin" do
    Dir["../../../opt/local/git/#{version}/bin/*"].each do |bin_file|
      ln_sf bin_file, File.basename(bin_file)
    end
  end

  if distro == 'rpm'
    output_dir = File.expand_path('../target-rpms', __FILE__)
    at_exit {rm_rf output_dir}
    cd jailed_root do
      puts "*** Building RPM..."
      rpmbuild_cmd = []
      rpmbuild_cmd << "rpmbuild /tmp/git.spec"
      rpmbuild_cmd << "--verbose"
      rpmbuild_cmd << "--buildroot #{jailed_root}"
      rpmbuild_cmd << "--define '_tmppath #{jailed_root}/../rpm_tmppath'"
      rpmbuild_cmd << "--define '_topdir #{output_dir}'"
      rpmbuild_cmd << "--define '_rpmdir #{output_dir}'"
      rpmbuild_cmd << "-bb"

      sh rpmbuild_cmd.join(" ")
    end
    sh("mv target-rpms/x86_64/*.rpm pkg/")
  else
    cd "pkg" do
      sh(%Q{
           bundle exec fpm -s dir -t #{distro} --name git-#{version} -a x86_64 --version "#{version}" -C #{jailed_root} --verbose #{fpm_opts} --maintainer snap-ci@thoughtworks.com --vendor snap-ci@thoughtworks.com --url http://snap-ci.com --description "#{description_string}" --iteration #{release} --license 'GPLv2' .
      })
    end
  end
end

desc "build git rpm"
task :default => [:clean, :init, :download, :configure, :make, :make_install, :dist]
