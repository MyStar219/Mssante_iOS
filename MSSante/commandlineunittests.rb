#!/usr/bin/env ruby
if ENV['SL_RUN_UNIT_TESTS'] then
    launcher_path = "/usr/local/bin/ios-sim"
    test_bundle_path= File.join(ENV['BUILT_PRODUCTS_DIR'], "#{ENV['PRODUCT_NAME']}.#{ENV['WRAPPER_EXTENSION']}")
    
    environment = {
        'DYLD_INSERT_LIBRARIES' => "/../../Library/PrivateFrameworks/IDEBundleInjection.framework/IDEBundleInjection",
        'XCInjectBundle' => test_bundle_path,
        'XCInjectBundleInto' => ENV["TEST_HOST"]
    }
    
    environment_args = environment.collect { |key, value| "--setenv #{key}=\"#{value}\""}.join(" ")
    
    app_test_host = File.dirname(ENV["TEST_HOST"])
    cmd = "#{launcher_path} launch \"#{app_test_host}\" --timeout 120 #{environment_args} --args -SenTest All #{test_bundle_path}"
    
    passed = system(cmd)
    puts "Run unit tests! with results :"
    puts cmd
    puts passed
    exit(1) if !passed
    exit 0
    else
    puts "SL_RUN_UNIT_TESTS not set - Did not run unit tests!"
    exit 0

end