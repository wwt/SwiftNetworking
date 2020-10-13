# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

def shared_pods
  pod 'Swinject'
end

target 'NetworkExample' do
  use_frameworks!

  shared_pods

  target 'NetworkExampleTests' do
    shared_pods
    pod 'Cuckoo'
    pod 'OHHTTPStubs/Swift'
    pod 'Fakery'
  end

end
