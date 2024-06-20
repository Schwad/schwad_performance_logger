
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "schwad_performance_logger/version"

Gem::Specification.new do |spec|
  spec.name          = "schwad_performance_logger"
  spec.version       = SchwadPerformanceLogger::VERSION
  spec.authors       = ["Nick Schwaderer"]
  spec.email         = ["nicholas.schwaderer@gmail.com"]

  spec.summary       = %q{Track your memory and time performance in console, csv and/or logs.}
  spec.homepage      = "https://github.com/Schwad/schwad_performance_logger"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "get_process_mem"
  spec.add_dependency "benchmark-ips"
  spec.add_dependency "memory_profiler"

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
