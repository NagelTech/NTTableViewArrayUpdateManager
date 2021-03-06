Pod::Spec.new do |s|

  s.name         = "NTTableViewArrayUpdateManager"
  s.version      = "0.28"
  s.summary      = "Automates animated inserts, updates and deletes of a UITableView"
  s.homepage     = "https://github.com/NagelTech/NTTableViewArrayUpdateManager"
  s.license      = {:type => 'MIT', :file => 'LICENSE.txt'}
  s.author       = { "Ethan Nagel" => "eanagel@gmail.com" }
  s.platform     = :ios
  s.source       = { :git => "https://github.com/NagelTech/NTTableViewArrayUpdateManager.git", :tag => "v0.28" }
  s.source_files  = 'pod/*.{h,m}'

end
