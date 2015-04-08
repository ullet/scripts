require 'rspec/given'
require_relative '../arguments'

describe Arguments do
  Given(:arguments) { Arguments.new(args_array) }

  context 'empty args array' do
    Given(:args_array) { [] }
    Then { arguments.valid? == false }
    Then { arguments[:path].nil? }
    Then { arguments[:options].empty? }
  end
  
  context 'missing path argument array' do
    Given(:args_array) { ['--alter'] }
    Then { arguments.valid? == false }
    Then { arguments[:path].nil? }
    Then { arguments[:options].empty? }
  end
  
  context 'just path argument' do
    Given(:args_array) { ['/some/path'] }
    Then { arguments.valid? == true }
    Then { arguments[:path] == '/some/path' }
    Then { arguments[:options].empty? }
  end
  
  context 'path then alter switch' do
    Given(:args_array) { ['/some/path', '--alter'] }
    Then { arguments.valid? == true }
    Then { arguments[:path] == '/some/path' }
    Then { arguments[:options] == { login: :alter } }
  end
  
  context 'alter switch then path' do
    Given(:args_array) { ['--alter', '/some/path'] }
    Then { arguments.valid? == true }
    Then { arguments[:path] == '/some/path' }
    Then { arguments[:options] == { login: :alter } }
  end
end
